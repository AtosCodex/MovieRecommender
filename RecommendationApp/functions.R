


resolveTitle <- function(embeddedIdx)
{
  
  return(movies_df[movies_df$movieId==item_map[embeddedIdx,],]$title)
}

loadMovieCache <- function()
{
  movies_df <<- read.csv('data/movies.csv',stringsAsFactors = FALSE)
}

resolveTitle <- function(embeddedIdx)
{
  cat('item map index:',embeddedIdx)
  #return(movies_df[movies_df$movieId==item_map[embeddedIdx,],]$title)
  return(movies_df[item_map[embeddedIdx,],]$title)
}

loadData <- function(downLoad = FALSE, bucket_name = 'marcel-movierecommender')
{
  if (downLoad == TRUE)
  {
    library(googleAuthR)
    library(googleCloudStorageR)
    options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/devstorage.full_control")
    gar_gce_auth()
    
    ## get your project name from the API console
    proj <- "wiklabs-gcp-911bcf9b2822f412"
    options(googleAuthR.verbose = 0)
    
    
  my_bucket <- gcs_get_bucket(bucket_name)
  
  objects <- gcs_list_objects(bucket=bucket_name)
  
  gcs_get_object('row',bucket=bucket_name,
                 saveToDisk = 'data/row.out', overwrite = TRUE)
  gcs_get_object('col',bucket=bucket_name,
                 saveToDisk = 'data/col.out', overwrite = TRUE)
  
  gcs_get_object('user',bucket=bucket_name,
                 saveToDisk = 'data/user.out', overwrite = TRUE)
  
  gcs_get_object('item',bucket=bucket_name,
                 saveToDisk = 'data/item.out', overwrite = TRUE)
  
  gcs_get_object('movies.csv',bucket=bucket_name,
                 saveToDisk = 'data/movies.csv', overwrite = TRUE)
  }
  # output_row <<- read.csv('data/row.out',header=F)
  # output_col <<- read.csv("data/col.out",header=F)
  # user_map <<- read.csv("data/user.out",header=F)
  # item_map <<- read.csv("data/item.out",header=F)
  
  output_row <<- data.frame(fread('data/row.out',header=F))
  output_col <<- data.frame(fread("data/col.out",header=F))
  user_map <<- data.frame(fread("data/user.out",header=F))
  item_map <<- data.frame(fread("data/item.out",header=F))
  
  
  movies_df <<- read.csv('data/movies.csv',stringsAsFactors = FALSE)
  
  #movietitle_list <<- unique(movies_df$title)
  
  return(TRUE)
  
}


  
