#Based off of the ns-simple.tcl file provided

#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green
$ns color 4 Purple

#Open the NAM trace file
set nf [open lab12.nam w]
$ns namtrace-all $nf

#Open the trace file
set tf [open lab12.tr w]
$ns trace-all $tf

#Define a 'finish' procedure
proc finish {} {
        global ns nf tf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
	#Close the trace file
	close $tf
        #Execute NAM on the trace file
        exec nam lab12.nam &
        exit 0
}

#Create five nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#Create links between the nodes
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n0 2Mb 10ms DropTail
$ns duplex-link $n2 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n4 2Mb 10ms DropTail
$ns duplex-link $n1 $n4 2Mb 10ms DropTail

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n2 $n3 10

#Give node position (for NAM)
$ns duplex-link-op $n3 $n2 orient left
$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n2 $n1 orient left-down
$ns duplex-link-op $n0 $n4 orient left-down
$ns duplex-link-op $n1 $n4 orient left-up

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5


#Setup a TCP connection
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n4 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n0 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 4

#Setup a second TCP connection
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n0 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 1

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

#Setup a second FTP over TCP connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

#Setup a UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n3 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n4 $null1
$ns connect $udp1 $null1
$udp1 set fid_ 3

#Setup a second UDP connection
set udp2 [new Agent/UDP]
$ns attach-agent $n1 $udp2
set null2 [new Agent/Null]
$ns attach-agent $n3 $null2
$ns connect $udp2 $null2
$udp2 set fid_ 2

#Setup a CBR over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 1mb
$cbr1 set random_ false

#Setup a second CBR over UDP connection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.5 "$ftp1 start"
$ns at 5.0 "$ftp1 stop"

$ns at 3.0 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"
$ns at 4.5 "$cbr1 start"
$ns at 6.0 "$cbr1 stop"
$ns at 7.5 "$cbr1 start"
$ns at 9.0 "$cbr1 stop"

$ns at 0.8 "$cbr2 start"
$ns at 1.5 "$cbr2 stop"
$ns at 2.3 "$cbr2 start"
$ns at 7.2 "$cbr2 stop"

$ns at 1.0 "$ftp2 start"
$ns at 8.0 "$ftp2 stop"

#Call the finish procedure after 10 seconds of simulation time
$ns at 10.0 "finish"

#Print CBR packet size and interval
puts "CBR1 packet size = [$cbr1 set packet_size_]"
puts "CBR1 interval = [$cbr1 set interval_]"
puts "CBR2 packet size = [$cbr2 set packet_size_]"
puts "CBR2 interval = [$cbr2 set interval_]"

#Run the simulation
$ns run