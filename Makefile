CC = gcc
export CC
CXX = g++
export CXX
CXXFLAGS = -std=c++17
export CXXFLAGS
THREAD_NUM = 16
export THREAD_NUM

SKYNET = skynet/skynet
3RD = 3rd/zstd/zstd
LUACLIB = luaclib/lfs.so

all : $(SKYNET) $(3RD) $(LUACLIB) 

$(SKYNET):
	make linux -j$(THREAD_NUM) -Cskynet

$(3RD):
	make -j$(THREAD_NUM) -C3rd

$(LUACLIB):
	make -j$(THREAD_NUM) -Cluaclib
	
cleanskynet:
	make cleanall -Cskynet

clean3rd:
	make clean -C3rd

cleanluaclib:
	make clean -Cluaclib

clean: cleanluaclib

cleanall: cleanskynet clean3rd cleanluaclib 