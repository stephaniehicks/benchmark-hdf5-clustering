#' @title simulate_gauss_mix
#' #' Simulate a data from mixture of k (default is 3) 
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
k <- sim_center
set.seed(123)
x_mus <- sample(c(-5, 0, 5), k, replace=TRUE)
set.seed(1234)
x_sds <- sample(c(0.1, 0.5, 1), k, replace=TRUE)
set.seed(321)
y_mus <- sample(c(-5, 0, 5), k, replace=TRUE)
set.seed(1234)
y_sds <- sample(c(0.1, 0.5, 1), k, replace=TRUE)


simulate_gauss_mix <- function(n_cells, n_genes,
                               k, x_mus = x_mus, 
                               x_sds = x_sds, 
                               y_mus = y_mus, 
                               y_sds = y_sds, 
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
