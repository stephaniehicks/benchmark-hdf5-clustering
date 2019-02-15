#' Simulate a data from mixture of k (default is 3) 
#' cell types using bivariate normal distributions 
#' in 2-D biological space. Each cell type has a 
#' different x/y center and a different SD. 
#' 
#' Then we project the data to a D dimensional space 
#' to mimic high-dimensional expression data. 
#'
#' @param n_cells the number of cells to simulate
#' @param n_genes the number of genes to simulate
#' @param x_mus the x centers of the k subtypes 
#' (default is k=3)
#' @param x_sds the x standard deviations of the k 
#' subtypes (default is k=3)
#' @param y_mus the y centers of the k subtypes 
#' (default is k=3)
#' @param y_sds the x standard deviations of the k 
#' subtypes (default is k=3)
#' 
#' @return a list with (1) the true cluster labels 
#' (2) the true 2D dimensional data in 2D with 
#' \code{n_cells} and (2) the observed data with
#' \code{n_cells} rows and \code{n_genes} columns
#' 
#' @example 
#' simulate_gauss_mix(n_cells=10, n_genes=5)
#' 
#' @author Stephanie Hicks
#' 
simulate_gauss_mix <- function(n_cells, n_genes,
                               k = 3, x_mus = c(0,5,5), 
                               x_sds = c(1,0.1,1), 
                               y_mus = c(5,5,0), 
                               y_sds = c(1,0.1,1), 
                               prop1 = c(0.3,0.5,0.2))
{ 
  
  if(k != length(x_mus)){stop("k is not same as length of x_mus")} 
  if(k != length(x_sds)){stop("k is not same as length of x_sds")} 
  if(k != length(y_mus)){stop("k is not same as length of y_mus")} 
  if(k != length(y_sds)){stop("k is not same as length of y_sds")} 
  if(k != length(prop1)){stop("k is not same as length of prop1")} 
  
  comp1 <- sample(seq_len(k), prob=prop1, size=n_cells, replace=TRUE)
  
  # Sampling locations for cells in each component
  samples1 <- cbind(rnorm(n=n_cells, mean=x_mus[comp1],sd=x_sds[comp1]),
                    rnorm(n=n_cells, mean=y_mus[comp1],sd=y_sds[comp1]))
  
  # Random projection to D dimensional space, to mimic high-dimensional expression data.
  proj <- matrix(rnorm(n_genes*n_cells), nrow=n_genes, ncol=2)
  A1 <- samples1 %*% t(proj)
  
  # Add normally distributed noise.
  A1 <- A1 + rnorm(n_genes*n_cells)
  rownames(A1) <- paste0("Cell", seq_len(n_cells), "-1")
  colnames(A1) <- paste0("Gene", seq_len(n_genes))

  list("true_center" = cbind("x" = x_mus, "y" = y_mus),
       "true_cluster_id" = comp1,
       "true_data" = samples1, 
       "obs_data" = A1)
}


#' Helper function to calculate the adjusted 
#' Rand Index metric to assess accuracy
#' 
#' @param sim_object list object from the 
#' \code{bench_accuracy()} function
#' 
#' @importFrom plyr ldply
#' @importFrom mclust adjustedRandIndex
#' 
#' @return a data frame with the number of rows
#' equal to the length of the list object from 
#' \code{sim_object}. 
#' 
bench_accuracy_calculate_ari <- function(sim_object){
  out <- plyr::ldply(sim_object, function(xx){
    ari_kmeans <- mclust::adjustedRandIndex(
            xx$sim_data$true_cluster_id, 
            as.numeric(xx$kmeans_output$cluster))
    ari_mbkmeans <- mclust::adjustedRandIndex(
            xx$sim_data$true_cluster_id,
            xx$mbkmeans_output$Clusters)
  c(ari_kmeans=ari_kmeans, ari_mbkmeans=ari_mbkmeans) 
  })
  return(out)
}


#' Helper function to calculate the within 
#' cluster sum of squares to assess accuracy
#' 
#' @param sim_object list object from the 
#' \code{bench_accuracy()} function
#' 
#' @importFrom plyr ldply
#' 
#' @return a data frame with the number of rows
#' equal to the length of the list object from 
#' \code{sim_object}. 
#' 
bench_accuracy_extract_wcss <- function(sim_object){
  out <- plyr::ldply(sim_object, function(xx){
    wcss_kmeans <- sum(xx$kmeans_output$withinss)
    wcss_mbkmeans <- sum(xx$mbkmeans_output$WCSS_per_cluster)
    c(wcss_kmeans =wcss_kmeans, wcss_mbkmeans = wcss_mbkmeans )
  })
  return(out)
}




