SKYNET = skynet/skynet
LUACLIB = clib/dummy

all : $(SKYNET) $(LUACLIB)

$(SKYNET):
	make linux -j16 -Cskynet

$(LUACLIB):
	make -j16 -Cclib
	
cleanskynet:
	make cleanall -Cskynet

cleanluaclib:
	make clean -Cclib

clean: cleanluaclib

cleanall: cleanskynet cleanluaclib