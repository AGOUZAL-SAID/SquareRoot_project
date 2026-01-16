SRC = $(wildcard sqrt_module/src/*.vhd) $(wildcard custom_instruction/src/*.vhd)   custom_instruction/tb/*.vhd avalon_impl_slave/*.vhd
TB = TB_INST
SRC_WIN = "/mnt/c/intelFPGA/18.1/src"
all: sim


work:
	vlib work

compile: work 
	vcom $(SRC) 

sim: compile
	vsim -c -do "run -all; quit" work.$(TB)

deplace : $(WORK) 
	cp $(SRC) $(SRC_WIN)

clean:
	rm -f transcript vsim.wlf *.vcd *.log

mrproper:
	rm -rf work transcript vsim.wlf *.vcd *.log
