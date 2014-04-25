#
# Testing a hashing sequence with a known block header value.
# Excluded test_fpgaminer_top module
# fpgaminer_top is the top level module
#

restart -force -nowave

###########################
# add the desired waveforms
###########################

add wave -noupdate -radix hexadecimal header_data_input     
add wave -noupdate rst
add wave -noupdate write
add wave -noupdate load_cycle
add wave -noupdate load_done
add wave -noupdate loading
add wave -noupdate clk
add wave -noupdate -radix hexadecimal header_data_output
add wave -noupdate -radix hexadecimal header_buffer

#fpgaminer_top

add wave -noupdate -radix hexadecimal midstate_buf
add wave -noupdate -radix hexadecimal data
add wave -noupdate -radix hexadecimal nonce_next
add wave -noupdate -radix hexadecimal nonce
add wave -noupdate -radix hexadecimal state
add wave -noupdate -radix hexadecimal data 
add wave -noupdate -radix hexadecimal hash2
add wave -noupdate -radix hexadecimal golden_nonce
add wave -noupdate -radix hexadecimal is_golden_ticket

##############
#Signal inputs
##############

#clk
force clk 0 0 ns, 1 5 ns -repeat 10 ns

#add incorrect test header
#force header_midstate_buf 16#328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @0
#force header_data 16#000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115 @0
#force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000e44427a2194261a9395e64dbed17115328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @0
force write 0 @0
force write 1 @110000
force write 0 @120000
force write 1 @130000
force write 0 @140000
force write 1 @150000 
force write 0 @160000
force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000 @150000
force header_data_input 16#000000000000000000000000800000000e44427a2194261a9395e64dbed17115 @130000
force header_data_input 16#328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @110000

#force header_nonce 16#0e44427a @0

#add correct header with known output
#force header_midstate_buf 16#228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13000000
#force header_data 16#000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115 @13000000
#force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000e33327a2194261a9395e64dbed17115228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13000000
#force header_nonce 16#0e33327a @13000000

force write 1 @13110000
force write 0 @13120000
force write 1 @13140000
force write 0 @13150000
force write 1 @13170000 
force write 0 @13180000
force header_data_input 16#228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13110000
force header_data_input 16#000000000000000000000000800000000e33327a2194261a9395e64dbed17115 @13140000
force header_data_input 16#0000028000000000000000000000000000000000000000000000000000000000 @13170000 
#force rst 1 @13100000
#force rst 0 @13500000

####loop_log = 0
#run 20000000
####loop_log = 4
run 160000000