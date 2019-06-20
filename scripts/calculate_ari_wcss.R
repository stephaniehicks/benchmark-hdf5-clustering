#' @title calculate_ari
calculate_ari <- function(sim_object){
  ari <- mclust::adjustedRandIndex(
    sim_object$sim_data$true_cluster_id, 
    as.numeric(sim_object$cluster_output$cluster))
  return(ari)
}

#' @title calculate_wcss
calculate_wcss <- function(sim_object){
  wcss <- sum(sim_object$cluster_output$withinss)
  return(wcss)
}