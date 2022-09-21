# gict-task

Create a page with a header, navbar and footer. 

On the page, have two tabs:

1. On the first tab have a simple form with the fields: full names, email, phone and address. Have a submit button that will make a JSON post request to [the URL](http://developers.gictsystems.com/api/dummy/submit/) Show the returned responses in an alert(eg green for success, yellow for validation error etc.). Make sure you validate all the fields accordingly before submitting the form. The page should not refresh upon submitting the form. 

2. On the second tab create a table to show the list of items (it should refresh the list after 10 seconds without reloading the page) from the JSON generated by [this URL](http://developers.gictsystems.com/api/dummy/items/) with an authorization header with the value Bearer ALDJAK23423JKSLAJAF23423J23SAD3. Make sure to add an edit button to each row. 
    
Once completed create a GitHub repository and share the link with us so that we can have a look.

Please send the results to richard.rajwayi@gictsystems.com

## How I went about the task

- Add edit + delete btns to DT [link](https://www.r-bloggers.com/2021/01/adding-action-buttons-in-rows-of-dt-data-table-in-r-shiny/)

- Handle http requests using [httr](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html)
