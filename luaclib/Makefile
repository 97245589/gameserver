CC = gcc
CXX = g++
CXXFLAGS = -std=c++17
DY_LIB = -shared

LUA_DIR = ../skynet/3rd/lua
SKYNET_DIR = ../skynet/skynet-src

COMMON_FLAGS = -O2 -fPIC -I$(LUA_DIR)

all : lfs.so lzstd.so lutil.so lkcp.so

lfs.so : lfs/lfs.c
	$(CC) -o $@ $^ $(COMMON_FLAGS) $(DY_LIB)

lzstd.so : lzstd/lzstd.c
	$(CC) -o $@ $^ $(COMMON_FLAGS) $(DY_LIB) -lzstd 

lutil.so : lutil/*.cc
	$(CXX) -o $@ $^ $(COMMON_FLAGS) $(DY_LIB) $(CXXFLAGS)

lkcp.so: kcp/*.c kcp/*.cc
	$(CXX) -o $@ $^ $(COMMON_FLAGS) $(DY_LIB) $(CXXFLAGS) -I$(SKYNET_DIR)

.PHONY : clean
clean:
	rm *.so