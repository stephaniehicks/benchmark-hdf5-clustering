

set.seed(1234)
train_idx <- sample(colnames(sce), 15000)
test_idx <- setdiff(colnames(sce), train_idx)
train <- reducedDim(sce, "PCA")[train_idx,]
test <- reducedDim(sce, "PCA")[test_idx,]

system.time(wcss <- lapply(10:20, function(k) {
  cl <- kmeans(train, centers = k, nstart = 10)
  sum(compute_wcss(cl$cluster, cl$centers, test))
}))


plot(10:20, sapply(wcss, function(x) sum(x$WCSS_per_cluster)),
     type="b",
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")



## Visualization
set.seed(1234)
library(RColorBrewer)
system.time(sce <- runTSNE(sce, use_dimred = "PCA",
                           external_neighbors=TRUE, 
                           BNPARAM = BiocNeighbors::AnnoyParam(),
                           nthreads = 6,
                           BPPARAM = BiocParallel::MulticoreParam(6)))
pal <- c(brewer.pal(9, "Set1"), brewer.pal(8, "Set2"))

plot(reducedDim(sce, "TSNE"), pch=19, col=pal[clusters2$Clusters], 
     xlab="Dim 1", ylab = "Dim2")

saveRDS(reducedDim(sce, "TSNE"), file="tsne.rds")


set.seed(1234)
library(uwot)
system.time(um <- umap(reducedDim(sce, "PCA"), nn_method = "annoy",
                       approx_pow = TRUE, n_threads = 6))

plot(um, pch=19, col=pal[clusters2$Clusters], 
     xlab="Dim 1", ylab = "Dim2")

saveRDS(um, file="umap.rds")


# Marker genes
markers <- c("IL7R", #CD4
             "CD14",
             "LYZ", #CD14
             "MS4A1", #B cells
             "CD8A", #CD8
             "FCGR3A", #Monocytes
             "MS4A7",
             "GNLY",
             "NKG7", #NK cells
             "FCER1A", #Dendritic
             "CST3",
             "PPBP",
             "PF4", #megakaryocyte
             "CD3D"
)
means <- apply(counts(sce[which(rowData(sce)$Symbol %in% markers),]), 1, tapply, clusters2$Clusters, mean)
colnames(means) <- rowData(sce[colnames(means),])$Symbol

library(pheatmap)
pheatmap(log2(t(means)+1), scale = "row", cluster_cols = FALSE)

library(ggplot2)
df <- data.frame(t(log2(counts(sce[which(rowData(sce)$Symbol %in% markers),])+1)), UMAP1=um[,1], UMAP2=um[,2])
colnames(df)[1:ncol(means)] <- colnames(means)
ggplot(df, aes(x = UMAP1, y = UMAP2, color = CD3D)) +
  geom_point() + scale_color_continuous(low = "blue", high = "yellow")



