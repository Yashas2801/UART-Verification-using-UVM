# SIMULATOR = Questa for Mentor's Questasim
# Sv_Seed = 1339996228 for framing
# Sv_seed = 579432340 for parity 
# Sv_Seed = 3504803284 for breakinterrupt_error_test
SIMULATOR = Questa

SEED_NO= 579432340 
RTL= ../rtl/*
work= work #library name
SVTB1= ../top/top.sv
INC = +incdir+../top +incdir+../test +incdir+../agent +incdir+../env
SVTB2 = ../top/UART_pkg.sv
VSIMOPT= -vopt -voptargs=+acc 
VSIMCOV= -coverage -sva 
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"
VSIMBATCH2= -c -do  " log -r /* ;coverage save -onexit mem_cov2;run -all; exit"
VSIMBATCH3= -c -do  " log -r /* ;coverage save -onexit mem_cov3;run -all; exit"
VSIMBATCH4= -c -do  " log -r /* ;coverage save -onexit mem_cov4;run -all; exit"
VSIMBATCH5= -c -do  " log -r /* ;coverage save -onexit mem_cov5;run -all; exit"
VSIMBATCH6= -c -do  " log -r /* ;coverage save -onexit mem_cov6;run -all; exit"
VSIMBATCH7= -c -do  " log -r /* ;coverage save -onexit mem_cov7;run -all; exit"
VSIMBATCH8= -c -do  " log -r /* ;coverage save -onexit mem_cov8;run -all; exit"
VERBOSITY= +UVM_VERBOSITY=UVM_MEDIUM

help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                  								!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.  						!"
	@echo "! sv_cmp    	=>  Create library and compile the code.           						!"
	@echo "! run_test	=>  clean, compile & run the simulation for base_test in batch mode.		!" 
	@echo "! run_test1	=>  clean, compile & run the simulation for full_duplex_test in batch mode.			!" 
	@echo "! run_test2	=>  clean, compile & run the simulation for half_duplex_test in batch mode.			!"
	@echo "! run_test3	=>  clean, compile & run the simulation for loopback_test in batch mode.			!" 
	@echo "! run_test4	=>  clean, compile & run the simulation for parity_error_test	!"  
	@echo "! run_test5	=>  clean, compile & run the simulation for framing_error_test	!"  
	@echo "! run_test6	=>  clean, compile & run the simulation for overrun_error_test	!"  
	@echo "! run_test7	=>  clean, compile & run the simulation for breakinterrupt_error_test	!"  
	@echo "! view_wave1 =>  To view the waveform of base_test	    						!" 
	@echo "! view_wave2 =>  To view the waveform of full_duplex_test	    						!" 
	@echo "! view_wave3 =>  To view the waveform of half_duplex_test 						!" 
	@echo "! view_wave4 =>  To view the waveform of loopback_test   							!" 
	@echo "! view_wave5 =>  To view the waveform of parity_error_test    							!" 
	@echo "! view_wave6 =>  To view the waveform of framing_error_test    							!" 
	@echo "! view_wave7 =>  To view the waveform of overrun_error_test    							!" 
	@echo "! view_wave8 =>  To view the waveform of breakinterrupt_error_test							!" 
	@echo "! regress    =>  clean, compile and run all testcases in batch mode.		    				!"
	@echo "! report     =>  To merge coverage reports for all testcases and  convert to html format.			!"
	@echo "! cov        =>  To open merged coverage report in html format.							!"
	@echo ====================================================================================================================

clean 	   : clean_$(SIMULATOR)
sv_cmp     : sv_cmp_$(SIMULATOR)
run_test   : run_test_$(SIMULATOR)
run_test1  : run_test1_$(SIMULATOR)
run_test2  : run_test2_$(SIMULATOR)
run_test3  : run_test3_$(SIMULATOR)
run_test4  : run_test4_$(SIMULATOR)
run_test5  : run_test5_$(SIMULATOR)
run_test6  : run_test6_$(SIMULATOR)
run_test7  : run_test7_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)
view_wave5 : view_wave5_$(SIMULATOR)
view_wave6 : view_wave6_$(SIMULATOR)
view_wave7 : view_wave7_$(SIMULATOR)
view_wave8 : view_wave8_$(SIMULATOR)
regress    : regress_$(SIMULATOR)
report     : report_$(SIMULATOR)
cov        : cov_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1) $(VERBOSITY) -wlf wave_file1.wlf -l test1.log  -sv_seed random  work.top +UVM_TESTNAME=UART_test_base
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1
	
run_test1_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2) $(VERBOSITY) -wlf wave_file2.wlf -l test2.log  -sv_seed random  work.top +UVM_TESTNAME=full_duplex_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2
	
run_test2_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3) $(VERBOSITY) -wlf wave_file3.wlf -l test3.log  -sv_seed random  work.top +UVM_TESTNAME=half_duplex_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3
	
run_test3_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4) $(VERBOSITY) -wlf wave_file4.wlf -l test4.log  -sv_seed random  work.top +UVM_TESTNAME=loopback_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4
 
run_test4_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5) $(VERBOSITY) -wlf wave_file5.wlf -l test5.log  -sv_seed $(SEED_NO) work.top +UVM_TESTNAME=parity_error_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov5

run_test5_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5) $(VERBOSITY) -wlf wave_file6.wlf -l test6.log  -sv_seed 1339996228 work.top +UVM_TESTNAME=framing_error_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov6

run_test6_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5) $(VERBOSITY) -wlf wave_file7.wlf -l test7.log  -sv_seed random work.top +UVM_TESTNAME=overrun_error_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov7

run_test7_Questa:sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5) $(VERBOSITY) -wlf wave_file8.wlf -l test8.log  -sv_seed random work.top +UVM_TESTNAME=breakinterrupt_error_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov8
 
view_wave1_Questa:
	vsim -view wave_file1.wlf
	
view_wave2_Questa:
	vsim -view wave_file2.wlf
	
view_wave3_Questa:
	vsim -view wave_file3.wlf
	
view_wave4_Questa:
	vsim -view wave_file4.wlf
 
view_wave5_Questa:
	vsim -view wave_file5.wlf

view_wave6_Questa:
	vsim -view wave_file6.wlf

view_wave7_Questa:
	vsim -view wave_file7.wlf

view_wave8_Questa:
	vsim -view wave_file8.wlf

report_Questa:
	vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4 mem_cov5 mem_cov6 mem_cov7 mem_cov8
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress_Questa: clean_Questa run_test_Questa run_test1_Questa run_test2_Questa run_test3_Questa run_test4_Questa run_test5_Questa run_test6_Questa run_test7_Questa report_Questa 

cov_Questa:
	firefox covhtmlreport/index.html&
	
clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear

# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#



