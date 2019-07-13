
# Notes: normalization is a crucial step in the preprocessing of the results. 
# Here, we use the `scran` package to compute size factors that we will 
# use to compute the normalized log-expression values.

# It has been shown that the scran method works best if the size factors
# are computed within roughly homogeneous cell populations; hence, it is 
# beneficial to run a quick clustering on the raw data to compute better
# size factors. This ensures that we do not pool cells that are very different. 
# Note taat this is not the final clustering to identify cell sub-populations.



# **Ruxoi**: add code to load in SCE object here
library(HDF5Array)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full/hca_bonemarrow", 
                                        "hca_bonemarrow_preprocessed"),  prefix="")

library(mbkmeans)
set.seed(1234)

# we only need to time this step for mbkmeans (clustering on the full dataset)
time <- system.time(clusters <- mbkmeans(counts(sce), clusters=10, 
                                 batch_size = 100))
temp_table <- data.frame("hca_bonemarrow", dim(counts(sce))[2], dim(counts(sce))[1], "01_full cluster", "", time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

# **Ruxoi**: add code to save cluster labels here
saveRDS(clusters, file = here("main/case_studies/data/full/hca_bonemarrow", "hca_bonemarrow_cluster_full.rds"))


