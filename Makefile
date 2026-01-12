SKYNET = skynet/skynet
LUACLIB = luaclib/lkcp.so

all : $(SKYNET) $(LUACLIB)

$(SKYNET):
	git submodule update --init &&  make linux -j16 -Cskynet

$(LUACLIB):
	make -j16 -Cluaclib
	
cleanskynet:
	make cleanall -Cskynet

cleanluaclib:
	make clean -Cluaclib

clean: cleanluaclib

cleanall: cleanskynet cleanluaclib