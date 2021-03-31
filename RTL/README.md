# Building the yosys toolchain

## Prerequisites (mac)
brew install libftdi qt5 boost eigen cmake coreutils
alias nproc=sysctl -n hw.logicalcpu

## icestorm
git apply ../icestorm.patch
make -j$(nproc)
sudo make install
## nextpnr
git submodule update --init --recursive
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_GUI=ON .
make -j$(nproc)
sudo make install

## yosys
make -j$(nproc)
sudo make install
