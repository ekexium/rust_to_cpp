#!/bin/bash
home=$(cd `dirname $0`; pwd)
mkdir -p $home/target/cxx && \
cargo build && \
cxxbridge $home/src/lib.rs > $home/target/cxx/tikv_client_glue.cc && \
cxxbridge $home/src/lib.rs --header > $home/target/cxx/tikv_client_glue.h && \
mkdir -p $home/build && cd $home/build && cmake .. && make -j 2
exit $?
