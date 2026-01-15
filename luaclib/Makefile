LUA_DIR := ../skynet/3rd/lua
3RDPATH = ../3rd
3RDFLAG := -I$(3RDPATH) -L$(3RDPATH) -Wl,-rpath,$(3RDPATH):3rd
COMMON_FLAGS := -O2 -fPIC -shared -I$(LUA_DIR) $(3RDFLAG) -std=c++17 -lzstd

all : lgame.so

GAME_SRCS := $(shell find ./ -name "*.cc")
lgame.so : $(GAME_SRCS)
	g++ -o $@ $^ $(COMMON_FLAGS)

.PHONY : clean
clean:
	find . -type f \( -name "*.o" -o -name "*.so" \) | xargs rm -f