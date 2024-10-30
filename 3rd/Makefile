ZSTD = zstd/zstd

all : $(ZSTD)

$(ZSTD):
	cd ./zstd && make -j16

clean_zstd:
	cd ./zstd && make clean

.PHONY : clean
clean: clean_zstd
