#' @title calculate_acc
calculate_acc <- function(i, sim_object){
  ari <- mclust::adjustedRandIndex(
    sim_object[[i]]$true_cluster, 
    as.numeric(sim_object[[i]]$cluster_output))
  wcss <- sum(sim_object[[i]]$cluster_wcss)
  
  output_list <- list(ari=ari, wcss=wcss)
  return(output_list)
}