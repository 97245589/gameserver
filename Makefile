SKYNET = skynet/skynet
LUACLIB = LUACLIB

all : $(SKYNET) $(LUACLIB)

$(SKYNET):
	make linux -j16 -Cskynet

$(LUACLIB): luaclib/Makefile
	make -j16 -Cluaclib
	
cleanskynet:
	make cleanall -Cskynet

cleanluaclib:
	make clean -Cluaclib

clean: cleanluaclib

cleanall: cleanskynet cleanluaclib