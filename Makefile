################################
### FreeSwitch headers files ###
FS_INCLUDES=/opt/include
FS_MODULES=/opt/mod
################################

### END OF CUSTOMIZATION ###
PROC?=$(shell uname -m)

CC=gcc 
CFLAGS=-fPIC -O3 -fomit-frame-pointer -fno-exceptions -Wall -std=c99 -pedantic
ifeq (${PROC},x86_64)
	CFLAGS+=-m64 -mtune=generic
else
	CFLAGS+=-m32 -march=i686
endif

INCLUDES=-I/usr/include -Ibcg729/include -I$(FS_INCLUDES)
LDFLAGS=-lm -Wl,-static -Lbcg729/src/.libs -lbcg729 -Wl,-Bdynamic 

all : mod_bcg729.o
	$(CC) $(CFLAGS) $(INCLUDES) -shared -Xlinker -x -o mod_bcg729.so mod_bcg729.o $(LDFLAGS)

mod_bcg729.o: bcg729 mod_bcg729.c
	$(CC) $(CFLAGS) $(INCLUDES) -c mod_bcg729.c

clone_bcg729:
	if [ ! -d bcg729 ]; then \
		git clone https://github.com/voxbox-io/bcg729.git; \
	fi

bcg729: clone_bcg729
	cd bcg729 && sh autogen.sh && CFLAGS=-fPIC ./configure && make && cd ..
	
clean:
	rm -f *.o *.so *.a *.la; cd bcg729 && make clean; cd ..

distclean: clean
	rm -fR bcg729

install: all
	/usr/bin/install -c mod_bcg729.so $(INSTALL_PREFIX)/$(FS_MODULES)/mod_bcg729.so
