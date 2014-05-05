# Base addresses of the peripherals: take from Qsys
set bitcoin_miner 0x0

puts "Started system-console-test-script"

# Using the JTAG chain, check the clock and reset"

set j [lindex [get_service_paths jtag_debug] 0]
open_service jtag_debug $j
puts "Opened jtag_debug"

#issues reset request to the system thru JTAG to Avalon Master Bridge
puts "Checking the JTAG chain loopback: [jtag_debug_loop $j {1 2 3 4 5 6}]"
jtag_debug_reset_system $j

puts -nonewline "Sampling the clock: "
foreach i {1 1 1 1 1 1 1 1 1 1 1 1} {
    puts -nonewline [jtag_debug_sample_clock $j]
}
puts ""

puts "Checking reset state: [jtag_debug_sample_reset $j]"

close_service jtag_debug $j
puts "Closed jtag_debug"

# Perform bus reads and writes
set m [lindex [get_service_paths master] 0]
open_service master $m
puts "Opened master"

set state [master_read_8 $m [expr $bitcoin_miner + 104] 1]
puts "state0: $state"

#send 'start' signal to miner
puts "Sending start signal to miner...\n"
master_write_8 $m [expr $bitcoin_miner + 102] 0x01
set start [master_read_8 $m [expr $bitcoin_miner + 102] 1]
puts "start: $start"
