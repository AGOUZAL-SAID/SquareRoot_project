SRC = $(wildcard avalon_impl/src/*.vhd) avalon_impl/tb/*.vhd
TB = TB_AV
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
