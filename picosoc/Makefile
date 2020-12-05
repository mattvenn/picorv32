PI_ADDR = pi@raspberrypi.local
FOMU_FLASH = ~/fomu-flash/fomu-flash

CROSS=riscv64-unknown-elf-
GCC_PATH=/home/matt/work/fpga/ecp5-toolchain-linux_x86_64-v1.6.9/bin/
ECP5_TOOLS=/opt/fpga-toolchain/bin
CFLAGS=-mabi=ilp32 

CONSTR=mv_ecp.lpf
DEVICE=45k

ecp5demo_all.bin: ecp5demo.bit ecp5demo_fw.bin
	cp ecp5demo.bit ecp5demo.padded.bit
	dd if=/dev/zero of=ecp5demo.padded.bit bs=1 count=1 seek=1048575
	cat ecp5demo.padded.bit ecp5demo_fw.bin > ecp5demo_all.bin 

ecp5prog: ecp5demo_all.bin
	scp $< $(PI_ADDR):/tmp/$<
	ssh $(PI_ADDR) "sudo $(FOMU_FLASH) -w /tmp/$< && sudo $(FOMU_FLASH) -r"

ecp5prog_fw: ecp5demo_fw.bin
	scp $< $(PI_ADDR):/tmp/$<
	ssh $(PI_ADDR) "sudo $(FOMU_FLASH) -w /tmp/$< -a 1048576 && sudo $(FOMU_FLASH) -r"

ecp5sim: ecp5demo_tb.vvp ecp5demo_fw.hex
	vvp -N $< +firmware=ecp5demo_fw.hex

ecp5synsim: ecp5demo_syn_tb.vvp ecp5demo_fw.hex
	vvp -N $< +firmware=ecp5demo_fw.hex

ecp5demo.json: ecp5demo.v spimemio.v simpleuart.v picosoc.v ../picorv32.v wishbone-button-leds/wb_buttons_leds.v
	$(ECP5_TOOLS)/yosys -ql ecp5demo.log -DSYNTH -p 'synth_ecp5 -top ecp5demo -json ecp5demo.json' $^

ecp5demo_tb.vvp: ecp5demo_tb.v ecp5demo.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v wishbone-button-leds/wb_buttons_leds.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v` # FIXME

ecp5demo_syn_tb.vvp: ecp5demo_tb.v ecp5demo_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v` # FIXME

ecp5demo_syn.v: ecp5demo.json
	$(ECP5_TOOLS)/yosys -p 'read_json -wideports ecp5demo.json; write_verilog ecp5demo_syn.v'

ecp5demo_out.config: ecp5demo.json
	$(ECP5_TOOLS)/nextpnr-ecp5 -l nextpnr.log --json $< --lpf $(CONSTR) --textcfg $@ --$(DEVICE) --package CABGA256 --speed 8

ecp5demo.bit: ecp5demo_out.config
	$(ECP5_TOOLS)/ecppack --compress --svf-rowsize 100000 --svf ecp5demo.svf --input $< --bit $@

ecp5demo_sections.lds: sections.lds
	$(GCC_PATH)$(CROSS)cpp -P -o $@ $^

ecp5demo_fw.elf: ecp5demo_sections.lds start.s firmware.c
	$(GCC_PATH)$(CROSS)gcc $(CFLAGS) -march=rv32imc -Wl,-Bstatic,-T,ecp5demo_sections.lds,--strip-debug -ffreestanding -nostdlib -o ecp5demo_fw.elf start.s firmware.c

ecp5demo_fw.hex: ecp5demo_fw.elf
	$(GCC_PATH)$(CROSS)objcopy -O verilog ecp5demo_fw.elf ecp5demo_fw.hex

ecp5demo_fw.bin: ecp5demo_fw.elf
	$(GCC_PATH)$(CROSS)objcopy -O binary ecp5demo_fw.elf ecp5demo_fw.bin

# ---- Testbench for SPI Flash Model ----

spiflash_tb: spiflash_tb.vvp firmware.hex
	vvp -N $<

spiflash_tb.vvp: spiflash.v spiflash_tb.v
	iverilog -s testbench -o $@ $^


# ---- Clean ----

clean:
	rm -f testbench.vvp testbench.vcd spiflash_tb.vvp spiflash_tb.vcd
	rm -f ecp5demo_fw.elf ecp5demo_fw.hex ecp5demo_fw.bin cmos.log
	rm -f ecp5demo.json ecp5demo.log ecp5demo.asc ecp5demo.rpt ecp5demo.bin
	rm -f ecp5demo_syn.v ecp5demo_syn_tb.vvp ecp5demo_tb.vvp

.PHONY: spiflash_tb clean
.PHONY: ecp5prog ecp5prog_fw ecp5sim ecp5synsim
