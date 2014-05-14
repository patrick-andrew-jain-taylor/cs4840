# Writes correct header buffer data to the miner

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

puts "Writing correct header data"
foreach {r v} {0 0x90 1 0xf7 2 0x41 3 0xaf 4 0xb3 5 0xab 6 0x06 7 0xf1 8 0xa5 9 0x82 10 0xc5 11 0xc8 12 0x5e 13 0xe7 14 0xa5 15 0x61 16 0x91 17 0x2b 18 0x25 19 0xa7 20 0xcd 21 0x09 22 0xc0 23 0x60 24 0xa8 25 0x9b 26 0x3c 27 0x2a 28 0x73 29 0xa4 30 0x8e 31 0x22 32 0x15 33 0x71 34 0xd1 35 0xbe 36 0x4d 37 0xe6 38 0x95 39 0x93 40 0x1a 41 0x26 42 0x94 43 0x21 44 0x7a 45 0x22 46 0x22 47 0x0e 48 0x00 49 0x00 50 0x00 51 0x80 52 0x00 53 0x00 54 0x00 55 0x00 56 0x00 57 0x00 58 0x00 59 0x00 60 0x00 61 0x00 62 0x00 63 0x00 64 0x00 65 0x00 66 0x00 67 0x00 68 0x00 69 0x00 70 0x00 71 0x00 72 0x00 73 0x00 74 0x00 75 0x00 76 0x00 77 0x00 78 0x00 79 0x00 80 0x00 81 0x00 82 0x00 83 0x00 84 0x00 85 0x00 86 0x00 87 0x00 88 0x00 89 0x00 90 0x00 91 0x00 92 0x80 93 0x02 94 0x00 95 0x00} {
    master_write_8 $m [expr $bitcoin_miner + $r] $v
}
