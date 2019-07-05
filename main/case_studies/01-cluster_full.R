
# Notes: normalization is a crucial step in the preprocessing of the results. 
# Here, we use the `scran` package to compute size factors that we will 
# use to compute the normalized log-expression values.

# It has been shown that the scran method works best if the size factors
# are computed within roughly homogeneous cell populations; hence, it is 
# beneficial to run a quick clustering on the raw data to compute better
# size factors. This ensures that we do not pool cells that are very different. 
# Note taat this is not the final clustering to identify cell sub-populations.



# **Ruxoi**: add code to load in SCE object here


library(mbkmeans)
set.seed(1234)

# we only need to time this step for mbkmeans (clustering on the full dataset)
system.time(clusters <- mbkmeans(counts(sce), clusters=10, 
                                 batch_size = 100))

# **Ruxoi**: add code to save cluster labels here