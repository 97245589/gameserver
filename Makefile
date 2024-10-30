SKYNET = skynet/skynet
LUACLIB = luaclib/lfs.so
3RD = 3rd/test

all : $(SKYNET) $(LUACLIB) $(3RD)

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