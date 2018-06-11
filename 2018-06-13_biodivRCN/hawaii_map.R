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


# chrono ages
chronoAge <- read.csv('../Haw_St_ageCode.csv',stringsAsFactors=FALSE)
chronoAge$age.low <- chronoAge$age.low * c(yr = 10^-6, ka = 10^-3, Ma = 10^0)[chronoAge$unit]
chronoAge$age.hi <- chronoAge$age.hi * c(yr = 10^-6, ka = 10^-3, Ma = 10^0)[chronoAge$unit]
chronoAge <- chronoAge[,-4]
chronoAge <- rbind(chronoAge, cbind(code = c(13:14), age.low = c(2, 4), age.hi = c(4, 6)))
chronoAge$age.mid <- (chronoAge$age.low + chronoAge$age.hi) / 2

geoPoly@data$AGE_GROUP <- as.integer(as.character(geoPoly@data$AGE_GROUP))
geoCol <- c('black', rev(colorRampPalette(viridis::magma(20))(max(geoPoly@data$AGE_GROUP))))

# jpeg('2018-06-13_biodivRCN/assets/fig/hawaii.jpg', width = 1200, height = 1000)
par(mar = rep(0, 4), bg = 'transparent')
plot(geoPoly, col=geoCol[geoPoly$AGE_GROUP+1], border=geoCol[geoPoly$AGE_GROUP+1])
plot(islands, add=TRUE)
# dev.off()
