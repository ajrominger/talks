convert fig_detCDF.png -fuzz 30% -transparent black foo.png
convert foo.png -fuzz 30% -fill black -opaque white foo2.png
convert foo2.png -fuzz 10% -transparent '#76140C' foo3.png
convert foo3.png -fuzz 30% -transparent '#EF8232' foo4.png
convert foo4.png -fuzz 30% -transparent '#A5FB88' foo5.png
convert foo5.png -fuzz 30% -transparent '#358CF7' foo6.png
convert foo6.png -fuzz 10% -transparent '#000E89' fig_detCDF_final.png

rm foo.png foo2.png foo3.png foo4.png foo5.png foo6.png
