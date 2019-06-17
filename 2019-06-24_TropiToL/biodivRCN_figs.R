library(sp)
library(maptools)
library(rgdal)
library(rgeos)

geoPoly <- readOGR(path.expand('~/Dropbox/hawaiiDimensions/geoData/env_data/geol'), 
                       'Haw_St_geo_20070426_region')

## get island outlines
islands <- gUnionCascaded(geoPoly)
islands <- SpatialPolygons(list(
    Polygons(islands@polygons[[1]]@Polygons[sapply(islands@polygons[[1]]@Polygons, 
                                                   function(p) !p@hole & p@area > 1e+07)
                                            ], ID=1)), 
    proj4string = CRS(proj4string(geoPoly)))


## interpolate it using function from here:
## http://gis.stackexchange.com/questions/24827/how-to-smooth-the-polygons-in-a-contour-map/24929#24929

splinePoly <- function(xy, vertices, k = 3, ...) {
    ## xy is an n by 2 matrix with n >= k.
    
    ## Wrap k vertices around each end.
    n <- dim(xy)[1]
    if (k >= 1) {
        data <- rbind(xy[(n-k+1):n,], xy, xy[1:k, ])
    } else {
        data <- xy
    }
    
    ## Spline the x and y coordinates.
    data.spline <- spline(1:(n+2*k), data[,1], n=vertices, ...)
    x <- data.spline$x
    x1 <- data.spline$y
    x2 <- spline(1:(n+2*k), data[,2], n=vertices, ...)$y
    
    ## Retain only the middle part.
    return(cbind(x1, x2)[k < x & x <= n+k, ])
}

## order of island names in `islands`
isNames <- c('kahoolawe', 'molokai', 'lanai', 'maui', 'niihau', 'kauai', 'oahu', 'hawaii')

## polygon areas (not actual sizes of islands)
isSizes <- sapply(islands@polygons[[1]]@Polygons, function(p) p@area)


isPoly <- lapply(islands@polygons[[1]]@Polygons, function(p) {
    xy <- coordinates(p)
    n <- round(0.1 * nrow(xy))
    Polygons(srl = list(Polygon(splinePoly(xy, n))), 
             ID = which(p@area == isSizes))
})

islands <- SpatialPolygonsDataFrame(SpatialPolygons(isPoly, 
                                                    proj4string = CRS(proj4string(islands))), 
                                    data = data.frame(island = isNames))

geoPoly@data$AGE_GROUP <- as.integer(as.character(geoPoly@data$AGE_GROUP))
geoCol <- c('black', 
            rev(colorRampPalette(viridis::magma(20, begin = 0.3))(max(geoPoly@data$AGE_GROUP))))



png('2018-06-13_biodivRCN/assets/fig/hawaii.png', width = 1200/1.25, height = 1000/1.25, 
    bg = 'transparent') # rgb(215, 215, 215, maxColorValue = 255)
par(mar = rep(0, 4), bg = 'transparent')
plot(geoPoly, col=geoCol[geoPoly$AGE_GROUP+1], border=geoCol[geoPoly$AGE_GROUP+1])
plot(islands, add=TRUE)
dev.off()


# hypotheses

png('2018-06-13_biodivRCN/assets/fig/hyp.png', width = 960/2, height = 800/3.5, 
    bg = 'transparent')

# parameters through time
n <- 50
x <- seq(-5, 5, length.out = n)
y <- 1/(1 + exp(-x))

par(mar = c(2, 2, 0, 0) + 0.1, mgp = c(0.5, 0, 0), bg = 'transparent', cex = 2, 
    mfrow = c(1, 2))

plot(x, y, type = 'n', xlab = 'Time', ylab = 'Rates', axes = FALSE)
box()

segments(x[-n], y[-n], x[-1], y[-1], col = rev(viridis::magma(n - 1, begin = 0.3)), lwd = 4)
segments(x[-n], 0.6 - 0.25*y[-n], x[-1], 0.6 - 0.25*y[-1], 
         col = rev(viridis::magma(n - 1, begin = 0.3)), lwd = 4)

text(c(1.9, -1.5), c(0.9, 0.65), labels = c('Speciation', 'Immigration'), 
     pos = c(2, 2))

# comp v. imm

plot(1:2, type = 'n', axes = FALSE, frame.plot = TRUE, xlim = c(0.75, 2.25), 
     ylim = c(0.75, 2.25), 
     xlab = 'Predicted diversity', ylab = 'Observed diversity')
abline(0, 1, lty = 2, col = 'gray', lwd = 2)

set.seed(2)
x <- seq(1, 1.45, length.out = 8) + runif(8, -0.05, 0.05)
y <- x - runif(8, 0.1, 0.35)
points(x, y, col = hsv(0.6, 0.6, 0.4), pch = 16)

set.seed(4)
x <- seq(1.55, 2, length.out = 8) + runif(8, -0.05, 0.05)
y <- x + runif(8, 0.1, 0.35)
points(x, y, col = hsv(0.1, 1, 0.8), pch = 16)

text(1.35, 1.4, labels = '1:1 line', srt = 45, col = 'gray50', cex = 0.8, adj = c(0.5, 0))
text(1.25, 0.8, labels = 'Immigration-driven', col = hsv(0.6, 0.6, 0.4), 
     adj = c(0, 0.5), cex = 0.9)
text(1.75, 2.2, labels = 'Competition-driven', col = hsv(0.1, 1, 0.8), 
     adj = c(1, 0.5), cex = 0.9)

dev.off()


## mega db

mutateDNA <- function(x) {
    y <- x
    y[x == 'A'] <- 'T'
    y[x == 'T'] <- 'A'
    y[x == 'C'] <- 'G'
    y[x == 'G'] <- 'C'
    
    return(y)
}

dnaSeq <- sample(c('A', 'T', 'C', 'G'), 20, replace = TRUE)
dnaSeqs <- matrix(rep(dnaSeq, 5), nrow = 5, byrow = TRUE)
for(i in 2:nrow(dnaSeqs)) {
    dnaSeqs[i, ] <- dnaSeqs[i - 1, ]
    
    n <- rpois(1, 2)
    if(n == 0) {
        n <- 1
    } else if(n > length(dnaSeq)) {
        n <- 4
    }
    
    j <- sample(length(dnaSeq), n)
    
    dnaSeqs[i, j] <- mutateDNA(dnaSeqs[i, j])
}

dnaCol <- c(A = hsv(0.5, 0.7, 1), 
            T = hsv(0.01, 1, 0.5), 
            C = hsv(0.7, 1, 0.7), 
            G = hsv(0.1, 1, 1))

pdf('2018-06-13_biodivrcn/assets/fig/db_dna.pdf', width = 3, height = 3)
par(mar = rep(0.1, 4))
plot(1, xlim = c(1, ncol(dnaSeqs)), ylim = c(1, nrow(dnaSeqs)), 
     type = 'n', axes = FALSE)
y <- seq(2, 4, length.out = 5)

for(i in 1:nrow(dnaSeqs)) {
    text(1:ncol(dnaSeqs), y[i], labels = dnaSeqs[i, ], col = dnaCol[dnaSeqs[i, ]])
}
dev.off()


library(ape)
set.seed(1)
tre <- rphylo(10, 0.9, 0.7)

pdf('2018-06-13_biodivrcn/assets/fig/db_tre.pdf', width = 3, height = 3)
par(mar = c(0, 0, 0, 1) + 0.5, xpd = NA)
plot(tre, show.tip.label = FALSE)
tiplabels(pch = 16, cex = runif(10, 0.5, 2), adj = 0.6)
dev.off()

library(pika)

pdf('2018-06-13_biodivrcn/assets/fig/db_abund.pdf', width = 3, height = 3)
par(mar = c(2, 2, 0, 0) + 0.5, mgp = c(0.75, 0, 0))
x <- sad(rfish(50, 0.01), keepData = TRUE)
plot(x, ptype = 'rad', log = 'y', axes = FALSE)
box()
dev.off()


pdf('2018-06-13_biodivrcn/assets/fig/db_geo.pdf', width = 3, height = 3)
par(mar = rep(0.1, 4))
plot(1)
x <- seq(par('usr')[1], par('usr')[2], length.out = 50)
col <- viridis::viridis(8)
for(i in 8:1) {
    polygon(c(x, x[length(x)], x[1]), c(-x^2 + 0.8 + i/3, 0, 0), 
            col = col[i], border = col[i])
}

xy <- matrix(runif(200, 0.6, 1.4), ncol = 2)
xy <- xy[xy[, 2] < -xy[, 1]^2 + 0.8 + 5/3 & xy[, 2] > -xy[, 1]^2 + 0.8 + 3/3, ]
points(xy, pch = 16)
dev.off()
