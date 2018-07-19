pdf('2018-07_gordon/fig_angioAge.pdf', width = 5, height = 2)

par(xpd = NA, mar = c(2.5, 2.5, 1, 1.5), lwd = 2, cex = 1.5, mgp = c(1.5, 0.5, 0))
plot(1, xlim = c(10^9, 1) / 10^6, ylim = c(0, 0.6), axes = FALSE, type = 'n', 
     xlab = 'Millions of years ago', ylab = '')
axis(1)

arrows(x0 = c(10^9, 180 * 10^6) / 10^6, y0 = 0.4, y1 = 0)
text(c(10^9, 180 * 10^6) / 10^6, c(0.6, 0.6), 
     labels = c('Time needed\nfor equilibrium', 'Age of\nangiosperms'))

dev.off()
