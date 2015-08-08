#!/usr/bin/env bash
make clean
make uninstall
cd src/bin
make clean
make uninstall
cd ../lib/ext/ffi
make clean
make uninstall
cd ../file
make clean
make uninstall
cd ../stdio
make clean
make uninstall

cd ../../../../

make && sudo make install && make clean && cd src/bin && make && sudo make install && make clean && cd ../lib/ext/ffi && make && sudo make install && make clean && cd ../file && make && sudo make install && make clean  && cd ../stdio && make && sudo make install && make clean && cd ../env && make && sudo make install && make clean
