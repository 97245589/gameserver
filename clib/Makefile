3RDPATH := ../3rd
3RDFLAG := -L$(3RDPATH) -Wl,-rpath,$(3RDPATH):3rd
COMMON_FLAGS := -O2 -fPIC -I../skynet/3rd/lua -I$(3RDPATH)
CXX_FLAGS := $(COMMON_FLAGS) -std=c++17
LINK := -s -shared

all : lgame.so

GAMESRC_CC := $(shell find ./game -name "*.cc")
GAMESRC_C := $(shell find ./game -name "*.c")
GAME_O := $(GAMESRC_CC:.cc=.o) $(GAMESRC_C:.c=.o)

lgame.so : $(GAME_O)
	g++ -o $@ $^ $(3RDFLAG) $(LINK)

%.o : %.cc
	g++ -o $@ -c $< $(CXX_FLAGS)

%.o : %.c
	gcc -o $@ -c $< $(COMMON_FLAGS)

.PHONY : clean
cleano:
	find . -type f -name "*.o" | xargs rm -f

cleanso:
	find . -type f -name "*.so" | xargs rm -f

clean: cleano cleanso