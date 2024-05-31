#Code to simulate a network with a mesh topology of 20 nodes using the Link State (LS) protocol
#By Drew Tomkins

#Create a simulator object
set ns [new Simulator]

#Make it so the simulator uses the Link State protocol to enable dynamic routing
$ns rtproto LS

#Assign colours to the data packets so they can be told apart
$ns color 1 green
$ns color 2 purple

#Open the nam trace file
set nf [open Scenario_20_nodes_LS.nam w]
$ns namtrace-all $nf

#Open the trace file
set tf [open Scenario_20_nodes_LS.tr w]
$ns trace-all $tf

#Use a for loop to set up twenty nodes
for {set i 0} {$i < 20} {incr i} {
        set n($i) [$ns node]
}

#Create links between nodes
for {set i 0} {$i < 20} {incr i} {
       #Ensure that there are only up to 10 nodes in the topology
        for {set j [expr $i+1]} {$j < 20} {incr j} {
			#Create links between nodes and give them connection details
                $ns duplex-link $n($i) $n($j) 1Mb 10ms DropTail
			#Label the current nodes
                $ns at 0.0 "$n($i) label node$i"
                $ns at 0.0 "$n($j) label node$j"
			#Colour them blue
                $n($i) color blue
                $n($j) color blue
        }
}

#Create a TCP connection so that TCP packets can travel to the desired node
set tcp0 [new Agent/TCP]
#Makes it so that TCP packets have a certain colour by setting a unique flow
$tcp0 set class_ 2
#Establishes the end node for packets to be delivered
$ns attach-agent $n(0) $tcp0

#Creates a new sink for packets to be received
set sink0 [new Agent/TCPSink]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(11) $sink0

#Creates a connection for the packets to travel through
$ns connect $tcp0 $sink0
#Makes it so that TCP packets have a certain colour by setting a unique flow
$tcp0 set fid_ 1

#Setup a FTP over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

#Create a UDP agent and attach it to node n(0)
set udp0 [new Agent/UDP]
#Establishes the starting node for packets to be sent from
$ns attach-agent $n(0) $udp0

#Create a Null agent (a traffic sink) and attach it to node n(5)
set null0 [new Agent/Null]
$ns attach-agent $n(5) $null0

#Connect the traffic source with the traffic sink
$ns connect $udp0 $null0
#Makes it so that UDP packets have a certain colour by seting a unique flow
$udp0 set fid_ 2

#Setup a CBR over UDP connection
set cbr0 [new Application/Traffic/CBR]
#Sets the UDP connection up with CBR
$cbr0 attach-agent $udp0
#Sets the type of traffic used to CBR
$cbr0 set type_ CBR
#Sets packet size to 1000
$cbr0 set packet_size_ 1000
#Sets the rate of the packet to 2mb
$cbr0 set rate_ 2mb
#Set the interval between sending the packets to 0.005 seconds
$cbr0 set interval_ 0.005
#Disables randomness for the connection
$cbr0 set random_ false

#Create a schedule of when certain TCP and UDP connections will start and stop
#transmitting packets to each other
$ns at 0.5 "$ftp0 start"
$ns at 4.0 "$ftp0 stop"

$ns at 2.0 "$cbr0 start"
$ns at 5.5 "$cbr0 stop"

#Create a for loop that determines which links go down within a time range and when they go back up
for {set i 11} {$i < 20} {incr i} {
        #Set links to go down at 1.X seconds
        $ns rtmodel-at 1.[expr $i-10] down $n(0) $n($i)
	    #Set links to go online at 4.X seconds
        $ns rtmodel-at 4.[expr $i-10] up $n(0) $n($i)
		#Set links to go down at 2.X seconds taking 14 away from the current increment to get the second node in the link
        $ns rtmodel-at 2.[expr $i-10] down $n(0) $n([expr $i-10])
		#Set links to go online at 5.X seconds taking 14 away from the current increment to get the second node in the link
        $ns rtmodel-at 5.[expr $i-10] up $n(0) $n([expr $i-10])
}

#Define a 'finish' procedure
proc finish {} {
        global ns nf tf
        $ns flush-trace
	#Close the nam + normal trace files
        close $nf
        close $tf
	#Execute nam on the trace file
        exec nam Scenario_20_nodes_LS.nam &
        exit 0
}

#Call the finish procedure after the simulation has been running for 5 seconds
$ns at 6.0 "finish"

#Run the simulation
$ns run