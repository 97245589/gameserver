SKYNET = skynet/skynet
3RD = 3rd/zstd/zstd
LUACLIB = luaclib/test

all : $(SKYNET) $(3RD) $(LUACLIB) 

$(SKYNET):
	make linux -j16 -Cskynet

$(3RD):
	make -j16 -C3rd

$(LUACLIB):
	make -j16 -Cluaclib
	
cleanskynet:
	make cleanall -Cskynet

clean3rd:
	make clean -C3rd

cleanluaclib:
	make clean -Cluaclib

clean: cleanluaclib

cleanall: cleanskynet clean3rd cleanluaclib 