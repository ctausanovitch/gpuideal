build_and_install:
	echo "#define COMBINED_1_2__" > ideal.cu
	cat ideal.cu gpuideal/src/ideal1D.cu gpuideal/src/ideal2D.cu > gpuideal/src/ideal.cu
	sudo docker run -v /home/jeff/gpuideal:/opt/gpuideal -it test
	sudo R CMD INSTALL gpuideal

document:
	sudo R -e 'roxygen2::roxygenise("gpuideal")'

test:
	Rscript gpuideal_test/testit.R

test2d:
	Rscript gpuideal_test/testit2d.R

clean:
	rm -f gpuideal/src/*.o
	rm -f gpuideal/src/*.so
	rm -f gpuideal/R/*~
	rm -f gpuideal/src/*~
