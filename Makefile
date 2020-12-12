pes_parent_dir:=$(shell pwd)/$(lastword $(MAKEFILE_LIST))
cur_makefile_path := $(shell dirname $(pes_parent_dir))

all: target/cxx target/cxx/app

pre-build: target/cxx target/cxx/libtikv_client_rust.a target/cxx/tikv_client_glue.cc target/cxx/tikv_client_glue.h

run: target/tikv-test
	RUST_BACKTRACE=1 $(cur_makefile_path)/target/tikv-test

target/cxx:
	mkdir -p $(cur_makefile_path)/target/cxx

target/tikv-test: target/cxx/libtikv_client.a
	c++ example/main.cpp -o target/tikv-test -std=c++17 -g -I$(cur_makefile_path)/target/cxx -I$(cur_makefile_path)/include -Ltarget/cxx -ltikv_client -lpthread -lssl -lcrypto -ldl

target/cxx/libtikv_client.a: target/cxx/libtikv_client_rust.a target/cxx/tikv_client_glue.o target/cxx/tikv_client_cpp.o
	cd $(cur_makefile_path)/target/cxx && cp libtikv_client_rust.a libtikv_client.a && ar cr libtikv_client.a tikv_client_cpp.o tikv_client_glue.o

target/cxx/tikv_client_cpp.o: src/tikv_client.cpp
	c++ -c $(cur_makefile_path)/src/tikv_client.cpp -o $(cur_makefile_path)/target/cxx/tikv_client_cpp.o -std=c++17 -g -I$(cur_makefile_path)/target/cxx -I$(cur_makefile_path)/include -lpthread -lssl -lcrypto -ldl

target/cxx/tikv_client_glue.o: target/cxx/tikv_client_glue.cc
	c++ -c $(cur_makefile_path)/target/cxx/tikv_client_glue.cc -o $(cur_makefile_path)/target/cxx/tikv_client_glue.o -std=c++17 -I$(cur_makefile_path)/target/cxx

target/cxx/libtikv_client_rust.a: src/lib.rs
	cargo build && mv $(cur_makefile_path)/target/debug/libtikv_client_rust.a $(cur_makefile_path)/target/cxx

target/cxx/tikv_client_glue.cc: src/lib.rs
	cxxbridge $(cur_makefile_path)/src/lib.rs > $(cur_makefile_path)/target/cxx/tikv_client_glue.cc

target/cxx/tikv_client_glue.h: src/lib.rs
	cxxbridge $(cur_makefile_path)/src/lib.rs --header > $(cur_makefile_path)/target/cxx/tikv_client_glue.h
