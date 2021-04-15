CC=yosys
CC_FLAGS=-q
ifdef DEBUG
	PNR=lldb -- /Users/waka/dev/fpga/nextpnr/Debug/nextpnr-ice40
	PNR_FLAGS=#--debug --log debuglog.txt 
else
	PNR=/Users/waka/dev/fpga/nextpnr/Release/nextpnr-ice40
	PNR_flags=#--debug --log debuglog.txt 
endif


default: dac

upload:
	iceprog hardware.bin 

%.json:  %.v
	$(CC) -p "synth_ice40 -json $@" $(CC_FLAGS) $^ 

%.asc: %.json 
	$(PNR) $(PNR_FLAGS) --up5k --package sg48 --json $^ --asc $@ --pcf upduino.pcf -q

# %.bin: %.asc
# 	icepack $^ $@

dac: simple_dac.asc
	icepack $^ hardware.bin

