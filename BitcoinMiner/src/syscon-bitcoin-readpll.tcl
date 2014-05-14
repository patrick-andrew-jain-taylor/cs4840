# Reads the registers of the parallelized miner

proc hex2bin {hex} {
	set h [string range $hex 2 end]
  binary scan [binary format H* $h] B* bin
  return $bin
}

set bitcoin_miner 0x0

set m [lindex [get_service_paths master] 0]
open_service master $m
puts "Opened master"

set hb ""
for {set i 95} {$i >= 0} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append hb " $tmp"
}

set nonce ""
for {set i 99} {$i > 95} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append nonce " $tmp"
}


#set n_out ""
#for {set i 107} {$i > 103} {incr i -1} {
#	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
#	append n_out " $tmp"
#}

set start [master_read_8 $m [expr $bitcoin_miner + 102] 1]
set loading [master_read_8 $m [expr $bitcoin_miner + 101] 1]
set ticket [master_read_8 $m [expr $bitcoin_miner + 100] 1]
set nstate [master_read_8 $m [expr $bitcoin_miner + 103] 1]

puts "Output:"
puts "header_buffer:\n$hb"
puts "<stop><start>: [hex2bin $start]"
puts "<loading><loaddone>: [hex2bin $loading]"
puts "nonce: $nonce"
#puts "n_out: $n_out"
puts "<ticket><gold_nonce32>: [hex2bin $ticket]"
puts "nstate <MINERS1nout32><MINERS0nout32><nonce_out32><read_gold_nonce>: [hex2bin $nstate]" 


puts "\n"

# Read nonces from the nonce_ram
set nonceram0 ""
for {set i 107} {$i > 103} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append nonceram0 " $tmp"
}

set nonceram1 ""
for {set i 111} {$i > 107} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append nonceram1 " $tmp"
}

set nonceram2 ""
for {set i 115} {$i > 111} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append nonceram2 " $tmp"
}

set nonceram3 ""
for {set i 119} {$i > 115} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append nonceram3 " $tmp"
}

set nonceram4 ""
for {set i 123} {$i > 119} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append nonceram4 " $tmp"
}

# Read the results from result_ram
set resultram0 ""
for {set i 152} {$i > 147} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append resultram0 " $tmp"
}

set resultram1 ""
for {set i 157} {$i > 152} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append resultram1 " $tmp"
}

set resultram2 ""
for {set i 162} {$i > 157} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append resultram2 " $tmp"
}

set resultram3 ""
for {set i 167} {$i > 162} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append resultram3 " $tmp"
}

set resultram4 ""
for {set i 173} {$i > 168} {incr i -1} {
	set tmp [master_read_8 $m [expr $bitcoin_miner + $i] 1]
	append resultram4 " $tmp"
}

puts "Nonce Ram"
puts "0: $nonceram0"
puts "1: $nonceram1"
puts "2: $nonceram2"
puts "3: $nonceram3"
puts "4: $nonceram4"

puts "Results Ram: <ticket><golden nonce>"
puts "0: $resultram0"
puts "1: $resultram1"
puts "2: $resultram2"
puts "3: $resultram3"
puts "4: $resultram4"

close_service master $m
puts "Closed master"
