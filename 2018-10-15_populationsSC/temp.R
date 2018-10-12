library(igraph)

x <- read.table('eco_service_net.txt', header = TRUE, row.names = 1, sep = '\t')
x[is.na(x)] <- 0
x <- as.matrix(x)
colnames(x) <- rownames(x) <- gsub(' ', '\n', rownames(x))

g <- graph_from_adjacency_matrix(x)


plot(g, 
     vertex.label.color = 'white', 
     vertex.size = 20, 
     vertex.color = c(rep(hsv(0.4, 0.4, 0.7), length(V(g)) - 1), hsv(0.6, 0.8, 0.8)), 
     edge.arrow.size = 0.5)
