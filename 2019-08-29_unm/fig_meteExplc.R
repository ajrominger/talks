Ebreak <- cumsum(sort(0.03 + (1-0.03*12)*rmultinom(1,1000,rexp(11))[,1]/1000,decreasing=TRUE))
Ebreak <- c(0,Ebreak,1)

indAt <- seq(0.1,0.9,length=12)
sppAt <- seq(0.3,0.7,by=0.2)

pdf(file='fig_meteExplc.pdf', width=6,height=3.5)

par(mar=c(4,0,0,0)+0.1,bg="transparent",fg="black",col.axis="black")
plot(1,type="n",xlim=c(0.4, 1), ylim=c(0,1),xlab="",axes=FALSE)

rect(0.9,0,1,1,col=hsv(0.42,0.6,0.6),border=NA)
segments(x0=0.9,x1=1,y0=Ebreak[2:12],col=hsv(0.42,0.6,0.8),lwd=2)

rect(0.65,indAt,0.75,indAt+0.03,col=hsv(0.6,0.3,0.7),border=NA)

for(i in 1:12) {
  polygon(x=c(0.75,0.75,0.9,0.9),
          y=c(indAt[i],indAt[i]+0.03,Ebreak[i+1],Ebreak[i]),
          col=hsv(0.42,0.6,0.8),border=hsv(0.42,0.6,0.8),lwd=0.2)
  
  if(i < 3) {
    polygon(x=c(0.65,0.65,0.45),
            y=c(indAt[i],indAt[i]+0.03,sppAt[1]),
            col=hsv(0.6,0.3,0.8),border=hsv(0.6,0.3,0.8))
  } else if(i < 7) {
    polygon(x=c(0.65,0.65,0.45),
            y=c(indAt[i],indAt[i]+0.03,sppAt[2]),
            col=hsv(0.6,0.3,0.8),border=hsv(0.6,0.3,0.8))
  } else {
    polygon(x=c(0.65,0.65,0.45),
            y=c(indAt[i],indAt[i]+0.03,sppAt[3]),
            col=hsv(0.6,0.3,0.8),border=hsv(0.6,0.3,0.8))
  }
}

points(rep(0.45,3),sppAt,cex=4,pch=21,bg=hsv(0.05,0.7,0.8))

axis(1,at=c(0.45,0.7,0.95),labels=c('Species','Individuals','Energy'))

dev.off()


pdf(file = 'fig_maxEntExplc1.pdf', width = 4, height = 3)

par(mar = c(2, 2, 0, 0) + 0.5, mgp = c(0.75, 0.75, 0))
plot(1, type = 'n', xlab = '', ylab = 'Probability', axes = FALSE, frame.plot = TRUE, 
     xlim = c(-1, 1), ylim = c(0, dnorm(0, 0, 0.25)), cex.lab = 1.6)
axis(1, at = c(-0.75, 0.75), labels = letters[1:2], cex.axis = 1.6)

segments(x0 = c(-0.75, -0.75, 0.75), x1 = c(-0.75, 0.75, 0.75), 
         y0 = c(0, 1, 0), y1 = c(1, 1, 1), col = '#A62A17', lwd = 4)

dev.off()

pdf(file = 'fig_maxEntExplc2.pdf', width = 4, height = 3)

par(mar = c(2, 2, 0, 0) + 0.5, mgp = c(0.75, 0.75, 0))
plot(1, type = 'n', xlab = '', ylab = 'Probability', axes = FALSE, frame.plot = TRUE, 
     xlim = c(-1, 1), ylim = c(0, dnorm(0, 0, 0.25)), cex.lab = 1.6)
axis(1, at = c(-0.75, 0.75), labels = letters[1:2], cex.axis = 1.6)

segments(x0 = c(-0.75, -0.75, 0.75), x1 = c(-0.75, 0.75, 0.75), 
         y0 = c(0, 1, 0), y1 = c(1, 1, 1), col = '#A62A17', lwd = 4)
curve(dnorm(x, 0, 0.25) - dnorm(0.75, 0, 0.25), add = TRUE, from = -0.75, to = 0.75, 
      col = 'gray40', lwd = 4)

dev.off()


xy <- matrix(runif(200), ncol = 2)

pdf('fig_scatter1.pdf', width = 3, height = 3)
par(mar = c(1, 1, 0, 0))
plot(xy, col.axis = 'transparent', xlab = '', ylab = '')
dev.off()

pdf('fig_scatter2.pdf', width = 3, height = 3)
par(mar = c(1, 1, 0, 0))
plot(xy, col.axis = 'transparent', xlab = '', ylab = '', 
     col = socorro::quantCol(xy[, 2], rev(rainbow(100, end = 0.8))))
dev.off()
