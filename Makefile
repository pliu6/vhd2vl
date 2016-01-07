
vhd2vl: vhd2vl
	make -C src
	mv src/vhd2vl .

clean:
	make -C src clean
