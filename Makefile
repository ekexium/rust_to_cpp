pes_parent_dir:=$(shell pwd)/$(lastword $(MAKEFILE_LIST))
cur_makefile_path := $(shell dirname $(pes_parent_dir))

all: target/cxx target/cxx/app

pre-build: target/cxx target/cxx/libtikv_client_rust.a target/cxx/tikv_client_glue.cc target/cxx/tikv_client_glue.h

clean:
	cargo clean

run: target/tikv-test
	LD_LIBRARY_PATH=LD_LIBRARY_PATH:$(cur_makefile_path)/target/cxx $(cur_makefile_path)/target/tikv-test

target/cxx:
	mkdir -p $(cur_makefile_path)/target/cxx

<<<<<<< HEAD
target/tikv-test: target/cxx/libtikv_client.a example/main.cpp
	c++ $(cur_makefile_path)/example/main.cpp -o $(cur_makefile_path)/target/tikv-test -std=c++17 -g -I$(cur_makefile_path)/target/cxx -I$(cur_makefile_path)/include -L$(cur_makefile_path)/target/cxx -ltikv_client -lpthread -ldl -lssl -lcrypto

target/cxx/libtikv_client.a: target/cxx/libtikv_client_rust.a target/cxx/tikv_client_glue.o target/cxx/tikv_client_cpp.o
	cd $(cur_makefile_path)/target/cxx && cp libtikv_client_rust.a libtikv_client.a && ar cr libtikv_client.a tikv_client_cpp.o tikv_client_glue.o

target/cxx/tikv_client_cpp.o: src/tikv_client.cpp
	c++ -c $(cur_makefile_path)/src/tikv_client.cpp -o $(cur_makefile_path)/target/cxx/tikv_client_cpp.o -std=c++17 -g -I$(cur_makefile_path)/target/cxx -I$(cur_makefile_path)/include
=======
target/tikv-test: target/cxx/libtikv_client.so example/main.cpp
	c++ $(cur_makefile_path)/example/main.cpp -o $(cur_makefile_path)/target/tikv-test -std=c++17 -g -I$(cur_makefile_path)/target/cxx -I$(cur_makefile_path)/include -L$(cur_makefile_path)/target/cxx -ltikv_client

target/cxx/libtikv_client.so: src/tikv_client.cpp target/cxx/libtikv_client_rust.a target/cxx/tikv_client_glue.o
	c++ -shared $(cur_makefile_path)/src/tikv_client.cpp -Wl,--whole-archive target/cxx/libtikv_client_rust.a target/cxx/tikv_client_glue.o -lssl -lcrypto  -lpthread -ldl -Wl,--no-whole-archive -o $(cur_makefile_path)/target/cxx/libtikv_client.so -std=c++17 -g -I$(cur_makefile_path)/target/cxx -I$(cur_makefile_path)/include
>>>>>>> df71f089ca7eb86bcbc3809acd70cedd730a7e0a

target/cxx/tikv_client_glue.o: target/cxx/tikv_client_glue.cc
	c++ -c $(cur_makefile_path)/target/cxx/tikv_client_glue.cc -o $(cur_makefile_path)/target/cxx/tikv_client_glue.o -fPIC -std=c++17 -I$(cur_makefile_path)/target/cxx

target/cxx/libtikv_client_rust.a: src/lib.rs
	cargo build && mv $(cur_makefile_path)/target/debug/libtikv_client_rust.a $(cur_makefile_path)/target/cxx

target/cxx/tikv_client_glue.cc: src/lib.rs
	cxxbridge $(cur_makefile_path)/src/lib.rs > $(cur_makefile_path)/target/cxx/tikv_client_glue.cc

target/cxx/tikv_client_glue.h: src/lib.rs
	cxxbridge $(cur_makefile_path)/src/lib.rs --header > $(cur_makefile_path)/target/cxx/tikv_client_glue.h
