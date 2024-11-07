ZSTD = zstd/zstd

all : $(ZSTD)

$(ZSTD):
	cd ./zstd && make -j$(THREAD_NUM) 

install:
	cp ./zstd/lib/zstd.h ./lib \
	&& cp ./zstd/lib/libzstd.so.1.3.8 ./lib/libzstd.so

clean_zstd:
	cd ./zstd && make clean

.PHONY : clean
clean: clean_zstd
