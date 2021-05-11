CC=yosys
CC_FLAGS=-q
ifdef DEBUG
	PNR=lldb -- /Users/waka/dev/fpga/nextpnr/Debug/nextpnr-ice40
	PNR_FLAGS=#--debug --log debuglog.txt 
else
	PNR=nextpnr-ice40
	PNR_flags=#--debug --log debuglog.txt 
endif

VERIFLA_DIR=../verifla/verilog/verifla
VERIFLA_INVOCATION=hierarchy -libdir . ; hierarchy -libdir $(VERIFLA_DIR);
default: dac

upload:
	iceprog hardware.bin 

%.json:  %.v
	$(CC) -p "$(VERIFLA_INVOCATION) synth_ice40 -json $@;" $(CC_FLAGS) $^ 

%.asc: %.json 
	$(PNR) $(PNR_FLAGS) --up5k --package sg48 --json $^ --asc $@ --pcf ../upduino.pcf -q

# %.bin: %.asc
# 	icepack $^ $@

dac: simple_dac.asc
	icepack $^ hardware.bin

comparator: simple_comparator.asc
	icepack $^ hardware.bin	

comp_instr: simple_comparator_instrumented.asc
	icepack $^ hardware.bin	

clean:
	rm -rf *.json *.asc hardware.bin