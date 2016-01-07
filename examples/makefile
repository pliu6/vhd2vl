VHD2VL=../src/vhd2vl
DIFF=diff

all: based.v bigfile.v clk.v counters.v\
		 expr.v for.v generate.v generic.v\
		 genericmap.v gh_fifo_async16_sr.v ifchain.v makefile test.v

%.v: %.vhd
	$(VHD2VL) $< $@
	$(DIFF) $@ ../translated_examples/$@

clean:
	-rm *.v
