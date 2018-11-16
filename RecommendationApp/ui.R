############################################################
# Title: Data Analytics App Demo for the Atos Innovatos 2017 event
# File: UI.R
# 
# Author: Marcel van den Bosch <marcel.vandenbosch@atos.net>
# Date: 07-Mar-2017
#
# Copyright 2017: Atos Consulting & Atos Codex
# 
# Description: In this app we demonstrate the use of
# analytics in a semiconductor manufacturing case
############################################################

# Load required libraries (please install them with install.packages()  if missing )
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinysky)
library(data.table)
library(DT)

# Include helper files
source('functions.R')

loadMovieCache()

# Add URL prefix for loading additional resource, such as images
addResourcePath('resources',"www")

# Custom ShinyJS hack code to let the boxes collapse automatically
jscode <- "shinyjs.collapse = function(boxid) { $('#' + boxid).closest('.box').find('[data-widget=collapse]').click(); }";


ui <- dashboardPage(
  dashboardHeader(title = "Movie Recommender Demo"),
  dashboardSidebar(
    
    sidebarMenu(id = "tab",
                conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                 tags$div("Loading...",id="loadmessage")    
                ),
                tags$div(tags$p(" ")),
                tags$div(align="center",
                         img(src="resources/atos_codex_logo.png", align="center")
                ),tags$div(tags$p(" ")),
                
                # List of menu items in our app
                menuItem("Welcome", tabName = "welcome", icon = icon("home")),
                menuItem("Dataset", tabName = "dataset", icon = icon("database")),
                menuItem("Recommender", tabName = "recommender", icon = icon("filter"))#,
)),
dashboardBody(
  useShinyjs(),
  extendShinyjs(text = jscode),
  tags$head(tags$meta(`http-equiv`="X-UA-Compatible",content="IE=edge"),     #   <meta http-equiv="X-UA-Compatible" content="IE=edge">
            tags$style(type="text/css", "
             #loadmessage {
                       position: fixed;
                       bottom: 0px;
                       left: 0px;
                       width: 100%;
                       padding: 5px 0px 5px 0px;
                       text-align: center;
                       font-weight: bold;
                       font-size: 100%;
                       color: #000000;
                       background-color: #85c1e9;
                       z-index: 105;
                       }
                       ")),
    tabItems(
      
      # Start of welcome tab
      tabItem(tabName = "welcome",
              fluidRow(
                
                box(title = "Welcome to the Atos-Google ASL: Movie Recommender Demo", status = "primary", solidHeader = TRUE,width = 12,
                    tags$div(class="header", checked=NA,
                             tags$p(" "),
                             tags$p("Goal:"),
                             tags$p("1. Build personalized recommendation models to recommend movies to users based on
movie ratings data from MovieLens 20M dataset. At the end of this project, customers
will learn:"),tags$p("2. A Cloud Dataflow pipeline to preprocess the dataset into TFRecord."),tags$p("
3. How to train a DNN softmax model with GPU."),tags$p("
4. How to train a matrix factorization model using hyperparameter tuning."),tags$p("
5. Model deployment and AppEngine UI for prediction."),tags$p("
6. Bonus: Experimenting different models and extra datasets")
                             ),tags$div(tags$p(" "))
                    )
                ),
              fluidRow(
                
                box(title = "About the dataset", status = "primary", solidHeader = TRUE,width = 12,
                    tags$div(class="header", checked=NA,
                             tags$p(" "),
                             tags$p("URL: https://grouplens.org/datasets/movielens/20m/"),
                             tags$p(" "),
                             tags$p("Stable benchmark dataset. 20 million ratings and 465,000 tag applications applied to 27,000 movies by 138,000 users. Includes tag genome data with 12 million relevance scores across 1,100 tags. Released 4/2015; updated 10/2016 to update links.csv and add tag genome data.")
                    ),tags$div(tags$p(" "))
                )
              )
              
 
      ),
      ## End of Welcome tab

      # Start of data load tab
      tabItem(tabName = "dataset",
              fluidRow(
                box(title = "What is this?", status = "primary", solidHeader = TRUE,width = 12,
                    tags$p("In the boxes below you can select from which data source you want to load the data for the demo. To demonstrate the 
                            portability of data products, we included several connectors.")
                )),
              fluidRow(
                
                box(title = "Local Data", status="primary", solidHeader = TRUE,width = 6, height = "325px",
                    tags$div(class="header", checked=NA,
                             tags$div(tags$p(" ")),
                             tags$div(align="center",
                                      img(src="resources/icon_disk.png", align="center"),
                                      tags$div(tags$p(" ")),
                                      actionButton('btnLoadLocal', label="Load Data from local disk", icon = icon("ok", lib = "glyphicon"), align="center")
                             ),tags$div(tags$p(" "))
                    )
                ),
                box(title = "Local from GCP Bucket", status="primary", solidHeader = TRUE,width = 6, height = "325px",
                    tags$div(class="header", checked=NA,
                             tags$div(tags$p(" ")),
                             tags$div(align="center",
                                      img(src="resources/cloud-storage.png", align="center"),
                                      tags$div(tags$p(" ")),
                                      textInput("gcp_bucket", "Bucket name:", "marcel-movierecommender"),
                                      tags$div(tags$p(" ")),
                                      actionButton('btnLoadGCP', label="Load Data from GCP Bucket", icon = icon("ok", lib = "glyphicon"), align="center")
                             ),tags$div(tags$p(" "))
                    )
                )
              )
              
              ),
              # End of data load
            
      # Start of welcome tab
      tabItem(tabName = "recommender",
              fluidRow(
                box(title = "Select your favorite movies", status = "primary", solidHeader = TRUE,width = 12,
                    tags$div(class="header", checked=NA,
                             tags$div(class="header", checked=NA,
                                      tags$p(" "),
                                      tableOutput('dfInputMovies'),
                                      
                             tags$p("  "),
                             textInput.typeahead(
                               id="input_movies"
                               ,placeholder="Please type your favorite movie name here"
                               ,local=movies_df
                               ,valueKey = "title"
                               ,tokens=c(1:length(movies_df$title))
                               ,template = HTML("<p>{{title}}</p>")
                             ),
                             actionButton('btnAddMovie', label="Add Example", icon = icon("ok", lib = "glyphicon"), align="center")
                             
                    ),tags$div(tags$p(" "))
                )
              )),
              fluidRow(
                box(title = "Recommender", status = "primary", solidHeader = TRUE,width = 12,
                    tags$div(class="header", checked=NA,
                             tags$p(" ")
                    ),
                    sliderInput("num_k", "No of recommendations:",
                                min = 1, max = 10,
                                value = 5,width = '250px'),tags$div(tags$p(" ")),
              radioButtons(inputId = 'rec_method', label = 'Method:', choices = list('Means' =1 ,'Sums' =2), selected = 2),
              actionButton('btnRecommender', label="Give me a recommendation!", icon = icon("ok", lib = "glyphicon"), align="center"),
              tags$div(tags$p(" "))
                )
              ),
              fluidRow(
                box(title = "Results", status = "primary", solidHeader = TRUE,width = 12,
                    tags$div(class="header", checked=NA,
                             tags$p(" "),
                             tableOutput('dfOutputMovies')
                    ),actionButton('btnReset', label="Clear", icon = icon("ok", lib = "glyphicon"), align="center"),
                    tags$div(tags$p(" "))
                )
              )              
      )#,
      ## End of Recommender tab tab
    )
  )# End of body
) # end of page