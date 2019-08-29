convert fig_beta-METE.png -fuzz 30% -transparent black foo.png
convert foo.png -fuzz 30% -fill black -opaque white fig_beta-METE_final.png

rm foo.png
