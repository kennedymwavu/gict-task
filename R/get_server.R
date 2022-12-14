#' GET server module
#'
#' @param id module id
#' @param get_url GET url
#' @param header_authorization Header authorization
#'
#' @noRd
get_server <- function(id, get_url, header_authorization) {
  moduleServer(
    id = id, 
    module = function(input, output, session) {
      ns <- NS(id)
      
      # autoinvalidator to reload table every 10 seconds:
      autoinvalidator <- reactiveTimer(intervalMs = 10 * 1000, session = session)
      
      rv_table <- reactiveValues(
        tbl = NULL, 
        dt_row = NULL,
        add_or_edit = NULL,
        edit_button = NULL,
        keep_track_id = NULL
      )
      
      observeEvent(autoinvalidator(), {
        # GET request:
        r <- httr::GET(
          url = get_url, 
          httr::add_headers(Authorization = header_authorization)
        )
        
        newtable <- lapply(httr::content(r), as.data.frame) |> 
          do.call(what = 'rbind')
        
        # create btns:
        btns <- create_buttons(ns = ns, btn_ids = seq_len(nrow(newtable)))
        
        # add the btns as a column to newtable:
        newtable$Buttons <- btns
        
        rv_table$tbl <- newtable
        
        # update keep track id:
        rv_table$keep_track_id <- nrow(newtable) + 1
      })
      
      output$table <- DT::renderDT({
        # column names: don't include the last column name `Buttons`:
        cnms <- colnames(rv_table$tbl)
        touse <- c(cnms[-length(cnms)], '')
        
        DT::datatable(
          data = rv_table$tbl, 
          rownames = FALSE, 
          colnames = touse, 
          escape = FALSE, 
          selection = 'single', 
          class = c('display', 'nowrap'), 
          options = list(
            processing = FALSE, 
            scrollX = TRUE, 
            lengthChange = FALSE, 
            columnDefs = list(
              list(
                className = 'dt-center', targets = '_all'
              )
            )
          )
        )
      })
      
      proxy <- DT::dataTableProxy('table')
      
      shiny::observe({
        DT::replaceData(
          proxy = proxy,
          data = rv_table$tbl,
          resetPaging = FALSE,
          rownames = FALSE
        )
      })
      
      # delete----
      observeEvent(input$current_id, {
        req(
          isTruthy(input$current_id) & 
            stringr::str_detect(input$current_id, pattern = 'delete')
        )
        
        rv_table$dt_row <- which(
          stringr::str_detect(
            rv_table$tbl$Buttons, 
            pattern = paste0('\\b', input$current_id, '\\b')
          )
        )
        
        rv_table$tbl <- rv_table$tbl[-rv_table$dt_row, ]
      })
      
      # edit----
      # when edit button is clicked, modal dialog shows current editable row 
      # filled out:
      observeEvent(input$current_id, {
        req(
          isTruthy(input$current_id) & 
            stringr::str_detect(input$current_id, pattern = 'edit')
        )
        
        rv_table$dt_row <- which(
          stringr::str_detect(
            rv_table$tbl$Buttons, pattern = paste0('\\b', input$current_id, '\\b')
          )
        )
        
        df <- rv_table$tbl[rv_table$dt_row, ]
        
        modal_dialog(
          ns = ns, ID = df$ID, Message = df$Message, Age = df$Age, edit = TRUE
        )
        
        rv_table$add_or_edit <- NULL
      })
      
      # when final edit button is clicked, table will be changed:
      observeEvent(input$final_edit, {
        req(
          isTruthy(input$current_id) & 
            stringr::str_detect(input$current_id, pattern = "edit") & 
            is.null(rv_table$add_or_edit)
        )
        
        rv_table$edited_row <- data.frame(
          ID = input$id, 
          Message = input$msg, 
          Age = input$age, 
          Buttons = rv_table$tbl$Buttons[rv_table$dt_row]
        )
        
        rv_table$tbl[rv_table$dt_row, ] <- rv_table$edited_row
      })
      
      # add----
      observeEvent(input$add_row, {
        modal_dialog(ns = ns, ID = '', Message = '', Age = '', edit = FALSE)
        
        rv_table$add_or_edit <- 1
      })
      
      observeEvent(input$final_edit, {
        req(rv_table$add_or_edit == 1)
        
        add_row <- data.frame(
          ID = input$id, 
          Message = input$msg, 
          Age = input$age, 
          Buttons = create_buttons(ns = ns, btn_ids = rv_table$keep_track_id)
        )
        
        rv_table$tbl <- rbind(rv_table$tbl, add_row)
        
        rv_table$keep_track_id <- rv_table$keep_track_id + 1
      })
      
      # remove modal when requested:
      observeEvent(input$dismiss_modal, {
        removeModal()
      })
      
      observeEvent(input$final_edit, {
        removeModal()
      })
    }
  )
}
