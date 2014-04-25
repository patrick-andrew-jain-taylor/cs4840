#
# Testing a hashing sequence with a known block header value.
# miner_top is the top level module
#

restart -force -nowave

###########################
# add the desired waveforms
###########################

#miner_top
add wave -noupdate reset
add wave -noupdate write
add wave -noupdate -radix decimal address
add wave -noupdate loading
add wave -noupdate clk
add wave -noupdate -radix hexadecimal writedata
add wave -noupdate -radix hexadecimal header_buffer

#fpgaminer_top
add wave -noupdate start
add wave -noupdate -radix hexadecimal /miner/header_data_input
add wave -noupdate -radix hexadecimal /miner/header_data_output
add wave -noupdate -radix hexadecimal /miner/midstate_buf
add wave -noupdate -radix hexadecimal /miner/data
add wave -noupdate -radix hexadecimal /miner/nonce_next
add wave -noupdate -radix hexadecimal /miner/nonce
add wave -noupdate -radix hexadecimal /miner/state
add wave -noupdate -radix hexadecimal /miner/hash2
add wave -noupdate -radix hexadecimal /miner/golden_nonce
add wave -noupdate -radix hexadecimal /miner/is_golden_ticket

##############
#Signal inputs
##############

#clk
force clk 0 0 ns, 1 5 ns -repeat 10 ns

#add incorrect test header
#force header_midstate_buf 16#328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @0
#force header_data 16#000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115 @0
#force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000e44427a2194261a9395e64dbed17115328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @0
#force write 0 @0
force reset 0 @0
force reset 1 @110000
force reset 0 @120000
force write 1 0 ns, 0 20 ns -repeat 40 ns

force address 16#0 @120000
force address 16#1 @160000
force address 16#2 @200000
force address 16#3 @240000
force address 10#4 @280000
force address 10#5 @320000
force address 10#6 @360000
force address 10#7 @400000
force address 10#8 @440000
force address 10#9 @480000
force address 10#10 @520000
force address 10#11 @560000
force address 10#12 @600000
force address 10#13 @640000
force address 10#14 @680000
force address 10#15 @720000
force address 10#16 @760000
force address 10#17 @800000
force address 10#18 @840000
force address 10#19 @880000
force address 10#20 @920000
force address 10#21 @960000
force address 10#22 @1000000
force address 10#23 @1400000


force writedata 16#af41f790 @120000
force writedata 16#f106abb3 @160000
force writedata 16#c8c582a5 @200000
force writedata 16#61a5e75e @240000
force writedata 16#a7252b91 @280000
force writedata 16#60c009cd @320000
force writedata 16#2a3c9ba8 @360000
force writedata 16#328ea473 @400000
force writedata 16#bed17115 @440000
force writedata 16#9395e64d @480000
force writedata 16#2194261a @520000
force writedata 16#0e44427a @560000
force writedata 16#80000000 @600000
force writedata 16#00000000 @640000
force writedata 16#00000000 @680000
force writedata 16#00000000 @720000
force writedata 16#00000000 @760000
force writedata 16#00000000 @800000
force writedata 16#00000000 @840000
force writedata 16#00000000 @880000
force writedata 16#00000000 @920000
force writedata 16#00000000 @960000
force writedata 16#00000000 @1000000
force writedata 16#00000280 @1400000

#force writedata 16#328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @110000
#force writedata 16#000000000000000000000000800000000e44427a2194261a9395e64dbed17115 @130000
#force writedata 16#0000028000000000000000000000000000000000000000000000000000000000 @150000

#force header_nonce 16#0e44427a @0

#add correct header with known output
#force header_midstate_buf 16#228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13000000
#force header_data 16#000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115 @13000000
#force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000e33327a2194261a9395e64dbed17115228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13000000
#force header_nonce 16#0e33327a @13000000
force reset 1 @57950000
force reset 0 @58000000

force address 16#0 @58000000
force address 16#1 @58040000
force address 16#2 @58080000
force address 16#3 @58120000
force address 10#4 @58160000
force address 10#5 @58200000
force address 10#6 @58240000
force address 10#7 @58280000
force address 10#8 @58320000
force address 10#9 @58360000
force address 10#10 @58400000
force address 10#11 @58440000
force address 10#12 @58480000
force address 10#13 @58520000
force address 10#14 @58560000
force address 10#15 @58600000
force address 10#16 @58640000
force address 10#17 @58680000
force address 10#18 @58720000
force address 10#19 @58760000
force address 10#20 @58800000
force address 10#21 @58840000
force address 10#22 @58920000
force address 10#23 @58960000


force writedata 16#af41f790 @58000000
force writedata 16#f106abb3 @58040000
force writedata 16#c8c582a5 @58080000
force writedata 16#61a5e75e @58120000
force writedata 16#a7252b91 @58160000
force writedata 16#60c009cd @58200000
force writedata 16#2a3c9ba8 @58240000
force writedata 16#228ea473 @58280000
force writedata 16#bed17115 @58320000
force writedata 16#9395e64d @58360000
force writedata 16#2194261a @58400000
force writedata 16#0e33327a @58440000
force writedata 16#80000000 @58480000
force writedata 16#00000000 @58520000
force writedata 16#00000000 @58560000
force writedata 16#00000000 @58600000
force writedata 16#00000000 @58640000
force writedata 16#00000000 @58680000
force writedata 16#00000000 @58720000
force writedata 16#00000000 @58760000
force writedata 16#00000000 @58800000
force writedata 16#00000000 @58840000
force writedata 16#00000000 @58920000
force writedata 16#00000280 @58960000

#force header_data_input 16#228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13110000
#force header_data_input 16#000000000000000000000000800000000e33327a2194261a9395e64dbed17115 @13140000
#force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000 @13170000 

####loop_log = 0
#run 20000000
####loop_log = 5
run 160000000
