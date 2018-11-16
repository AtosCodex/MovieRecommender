# Load required libraries (please install them with install.packages()  if missing )
library(shiny)
library(shinydashboard)
library(shinyjs)
#devtools::install_github("AnalytixWare/ShinySky")
library(shinysky)
library(data.table)
library(DT)
library(RANN)

# Include helper files
source('functions.R')

# Add URL prefix for loading additional resource, such as images
addResourcePath('resources',"www")

# Custom ShinyJS hack code to let the boxes collapse automatically
jscode <- "shinyjs.collapse = function(boxid) { $('#' + boxid).closest('.box').find('[data-widget=collapse]').click(); }";

# Define variables for having the datasat globally
assign("data", NULL, envir = .GlobalEnv);
assign("data.labels", NULL, envir = .GlobalEnv);
assign("inputMovies", NULL, envir = .GlobalEnv);
#loadData()

#

server <- function(input, output,session) {
  
  observeEvent(input$btnLoadLocal, {
    
    loadData()
    
    cat("Local load click!")
    
  })
  
  observeEvent(input$btnLoadGCP, {
    
    loadData(downLoad = TRUE, bucket_name = input$gcp_bucket)
    
    cat("Local load click!")
    
  })
  
  
  
  
  observeEvent(input$btnAddMovie, {
    
    if (is.null(inputMovies) == TRUE)
    {
    lookup_id <- movies_df[movies_df$title==as.character(input$input_movies),]$movieId;
    inputMovies <<- data.frame("Your_Movies" = as.character(input$input_movies),"id" = lookup_id)
    }  else {
    lookup_id <- movies_df[movies_df$title==as.character(input$input_movies),]$movieId
    inputMovies <<- rbind(inputMovies,data.frame("Your_Movies" = as.character(input$input_movies),"id" = lookup_id))
    }
    
    output$dfInputMovies <- renderTable(inputMovies)

    
  })
  
  observeEvent(input$btnReset, {
    
    inputMovies <<- NULL;
    output$dfInputMovies <- renderTable(inputMovies)
    
  })
  
  observeEvent(input$btnRecommender, {
    
    if (exists('output_col') == TRUE )
    {

  movie_embeds <- output_col;
  new_movies_ids <- inputMovies$id;
  cat("Running for movie ids:",new_movies_ids)
  
  if (input$rec_method == 2)
  {
    user_representation = matrix(colSums(rbindlist(lapply(new_movies_ids,function(x) { movie_embeds[x,]  }))),nrow=1)
  } else {
    user_representation = matrix(colMeans(rbindlist(lapply(new_movies_ids,function(x) { movie_embeds[x,]  }))),nrow=1)  
  }

  nearest <- nn2(movie_embeds,user_representation,k=input$num_k)
  cat("Nearest found:",nearest$nn.idx)

  results <- lapply(as.vector(nearest$nn.idx), function(x) { resolveTitle(x) })

  output$dfOutputMovies <- renderTable(data.frame("Recommended_Movies" = as.character(results)))
}

  })

}