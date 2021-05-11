# Building the yosys toolchain (macos)

## Prerequisites (mac)
brew install libftdi qt5 boost eigen cmake coreutils
alias nproc=sysctl -n hw.logicalcpu

## icestorm
git apply ../icestorm.patch
make -j$(nproc)
sudo make install

## nextpnr
git submodule update --init --recursive
mkdir Release &&  cd Release

cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_GUI=ON ../

cmake -DARCH=ice40 -DICESTORM_INSTALL_PREFIX=/usr/local/ -DBUILD_GUI=ON -DTBB_DIR=/usr/local/Cellar/tbb/2020_U3_1/ -DUSE_TBB=ON USE_IPO=OFF ../

debug build: (run it twice if you have to, it messes with the cache)
mkdir Debug && cd Debug
cmake -DARCH=ice40 -DCMAKE_BUILD_TYPE=Debug -DICESTORM_INSTALL_PREFIX=/usr/local/ -DBUILD_GUI=OFF -DUSE_TBB=OFF -DTBB_DIR=/usr/local/Cellar/tbb/2020_U3_1/ -DUSE_IPO=OFF -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DICE40_UP5K_ONLY=1 ../

lldb -- nextpnr-ice40 otherargs

make -j$(nproc)
sudo make install

## yosys
make -j$(nproc)
sudo make install

## Build europa with
Uses Sconstruct derived from apio template
scons fpga_size=up5k fpga_pack=sg48 verbose_pnr=1



# Stuff i learned
[Dwarf debug and linking](http://wiki.dwarfstd.org/index.php?title=Apple%27s_%22Lazy%22_DWARF_Scheme)

basically the linker doesnt attach the debug info but makes references. Use dsymutil to chase rabbits down holes.

Boost LTO breaks dwarf?
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
Change nextnpr cmakelists to:
if(ipo_supported AND NOT (CMAKE_BUILD_TYPE STREQUAL "Debug"))
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()


