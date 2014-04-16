#
# Testing a hashing sequence with a known block header value
#

restart -force -nowave

###########################
# add the desired waveforms
###########################

#test_fpgaminer_top IO waves
add wave -noupdate -radix hexadecimal header_midstate_buf      
add wave -noupdate -radix hexadecimal header_data      
add wave -noupdate -radix hexadecimal header_nonce
add wave -noupdate newinput
add wave -noupdate -radix hexadecimal golden_nonce
add wave -noupdate golden_nonce_ticket
add wave -noupdate clk

#fpgaminer_top
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/midstate_buf_in
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/data_in
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/nonce
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/state
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/data 
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/hash2
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/golden_nonce
add wave -noupdate -radix hexadecimal /test_fpgaminer_top/uut/is_golden_ticket

##############
#Signal inputs
##############

#clk
force clk 0 0 ns, 1 5 ns -repeat 10 ns

#add incorrect test header
force header_midstate_buf 16#328ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @0
force header_data 16#000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115 @0
force header_nonce 16#0e44427a @0
force newinput 0 @0
force newinput 1 @110000
force newinput 0 @150000

#add correct header with known output
force header_midstate_buf 16#228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790 @13000000
force header_data 16#000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115 @13000000
force header_nonce 16#0e33327a @13000000
force newinput 1 @13100000
force newinput 0 @13500000

run 20000000