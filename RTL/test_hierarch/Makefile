
##https://www.reddit.com/r/yosys/comments/8crxkm/keep_duplicate_ff_through_opt_merge/

synth: 
	~/.apio/packages/toolchain-yosys/bin/yosys -p 'read_verilog -lib ~/.apio/packages/toolchain-yosys/share/yosys/ice40/cells_sim.v; synth -flatten -top top; setattr -mod -unset keep_hierarchy; flatten; show -format pdf top' test.v

ice40: 
	~/.apio/packages/toolchain-yosys/bin/yosys -p 'synth_ice40; show -format pdf top' test.v