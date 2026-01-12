LUA_DIR := ../skynet/3rd/lua
3RDFLAG := -I$(3RDPATH) -L$(3RDPATH) -Wl,-rpath,$(3RDPATH):3rd
COMMON_FLAGS := -O2 -fPIC -shared -I$(LUA_DIR)

all : lgame.so

GAME_SRCS := $(shell find ./ -name "*.cc")
GAME_OBJS := $(GAME_SRCS:.cc=.o)
lgame.so : $(GAME_OBJS)
	g++ -o $@ $^ $(COMMON_FLAGS) -std=c++17

%.o : %.cc
	g++ -o $@ -c $< $(COMMON_FLAGS) -std=c++17

.PHONY : clean
clean:
	find . -type f \( -name "*.o" -o -name "*.so" \) | xargs rm -f