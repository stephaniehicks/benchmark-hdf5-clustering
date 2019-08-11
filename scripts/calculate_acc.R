#' @title calculate_acc
calculate_acc <- function(i, sim_object, method){
  ari <- mclust::adjustedRandIndex(
    sim_object[[i]]$true_cluster, 
    as.numeric(sim_object[[i]]$cluster_output))
  wcss <- sum(sim_object[[i]]$cluster_wcss)

  if (!(method == "kmeans")){
    best_iter <- sim_object[[i]]$best_init
    iters <- sim_object[[i]]$iters[best_iter]
    ifault <- "NA"
  }else{
    iters <- sim_object[[i]]$iteration
    ifault <- sim_object[[i]]$ifault
  }
  
  output_list <- list(ari=ari, wcss=wcss, iters = iters, fault = ifault)
  return(output_list)
}