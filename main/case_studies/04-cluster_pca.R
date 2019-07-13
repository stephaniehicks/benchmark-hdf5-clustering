# Cluster with mbkmeans on the PCs

# regular mbkmeans and kmeans
# load in pca.rds for kmeans
# benchmark both memory and time

set.seed(1234)
system.time(wcss <- lapply(10:20, function(k) {
  cl <- mbkmeans(sce, reduceMethod = "PCA", clusters = k,
                 batch_size = 3000, num_init=10, max_iters=100,
                 calc_wcss = TRUE)
}))

set.seed(1234)
system.time(mbkmeans(sce, reduceMethod = "PCA", clusters = 10,
                 batch_size = 3000, num_init=10, max_iters=100,
                 calc_wcss = TRUE)
            )