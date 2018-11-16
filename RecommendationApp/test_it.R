library(RANN)
library(data.table)
set.seed(123) 

movie_embeds <- output_col;

new_movies_ids <- c(140,340,5002)

user_representation = matrix(colSums(rbindlist(lapply(new_movies_ids,function(x) { movie_embeds[x,]  }))),nrow=1)
  
nearest <- nn2(movie_embeds,user_representation,k=5)

resolveTitle <- function(embeddedIdx)
{

  return(movies_df[movies_df$movieId==item_map[embeddedIdx,],]$title)
}

lapply(as.vector(nearest$nn.idx), function(x) { resolveTitle(x) })


