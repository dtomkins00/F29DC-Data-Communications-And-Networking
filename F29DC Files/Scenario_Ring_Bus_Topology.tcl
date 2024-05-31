#Code to simulate a network with subnet ring + bus topologies with 
#60 nodes total using the Distance Vector (DV) protocol
#By Drew Tomkins

#Create a simulator object
set ns [new Simulator]

#Make it so the simulator uses the DV protocol to enable dynamic routing
$ns rtproto DV

#Assign colours to the data packets so they can be told apart
$ns color 1 green
$ns color 2 purple
$ns color 3 yellow

#Open the nam trace file
set nf [open Scenario_Ring_Bus_Topology.nam w]
$ns namtrace-all $nf

#Open the trace file
set tf [open Scenario_Ring_Bus_Topology.tr w]
$ns trace-all $tf

#Create 60 nodes, with a quarter being routers and the rest being connected clients
for {set i 0} {$i <= 60} {incr i} {
        set n($i) [$ns node]
}

#For the first five nodes, they are created in a circle as there are no other
#nodes at this point so it provides a good base to add nodes to
for {set i 0} {$i < 5} {incr i} {
    #Create links between the nodes
        $ns duplex-link $n($i) $n([expr ($i+1)%5]) 10Mb 10ms DropTail
    #Label the current nodes as routers
        $ns at 0.0 "$n($i) label ROU$i"
	#Make the routers represented with squares
        $n($i) shape square
	#Colour them blue so they stand out
        $n($i) color blue
}

#Create nodes 5-10 and link them up together
for {set i 5} {$i < 10} {incr i} {
    #Create links between nodes
        $ns duplex-link $n($i) $n([expr $i+1]) 10Mb 10ms DropTail
	#Label the current nodes as routers
        $ns at 0.0 "$n($i) label ROU$i"
	#Make nodes 5-10 into squares
        $n($i) shape square
        $n(10) shape square
	#Color them blue so they stand out
        $n($i) color blue
        $n(10) color blue
}

#Create a link between nodes 5 and 2 so that there are 2 rings, creating a ring topology
$ns duplex-link $n(5) $n(2) 10Mb 10ms DropTail

#Create a link between nodes 1- and 2 so that there are 2 rings, creating a ring topology
$ns duplex-link $n(10) $n(2) 10Mb 10ms DropTail

#Create nodes 11-15 and link them up together
for {set i 11} {$i < 15} {incr i} {
    #Create links between nodes
        $ns duplex-link $n($i) $n([expr $i+1]) 10Mb 10ms DropTail
	#Label the current nodes as routers
        $ns at 0.0 "$n($i) label ROU$i"
	#Make nodes 11-15 into squares
        $n($i) shape square
        $n(15) shape square
	#Color them blue so they stand out
        $n($i) color blue
        $n(15) color blue
}

#Create a link between nodes 11- and 2 so that there are 2 rings, creating a bus topology
#and linking it to the ring topologies, so as a result the network has been split
#into 3 topologies, with node 2 being the link between the topologies
$ns duplex-link $n(11) $n(2) 10Mb 10ms DropTail

#Now the client nodes are created, these are going to be attached to several routers over
#the topologies, starting with attaching nodes 16-21 to node 0.
for {set i 16} {$i < 22} {incr i} {
    $ns duplex-link $n($i) $n(0) 10Mb 10ms DropTail
    $ns at 0.0 "$n($i) label CLI[expr $i-16]"
    $n($i) shape circle
}

#Attach nodes 22-25 to node 1
for {set i 22} {$i < 26} {incr i} {
    $ns duplex-link $n($i) $n(1) 10Mb 10ms DropTail
    $ns at 0.0 "$n($i) label CLI[expr $i-16]"
    $n($i) shape circle
}

#Attach nodes 26-41 to various nodes in the bus topology
for {set i 26} {$i < 42} {incr i} {
        $ns duplex-link $n($i) $n([expr ($i+1)%4 + 12]) 10Mb 10ms DropTail
        $ns at 0.0 "$n($i) label CLI[expr $i-16]"
        $n($i) shape circle
}

#Attach nodes 42-46 to node 9
for {set i 42} {$i < 47} {incr i} {
        $ns duplex-link $n($i) $n(9) 10Mb 10ms DropTail
        $ns at 0.0 "$n($i) label CLI[expr $i-16]"
        $n($i) shape circle
}

#Attach nodes 47-48 to node 12
for {set i 47} {$i < 49} {incr i} {
        $ns duplex-link $n($i) $n(12) 10Mb 10ms DropTail
        $ns at 0.0 "$n($i) label CLI[expr $i-16]"
        $n($i) shape circle
}

#Attach nodes 49-51 to node 1
for {set i 49} {$i < 52} {incr i} {
        $ns duplex-link $n($i) $n(14) 10Mb 10ms DropTail
        $ns at 0.0 "$n($i) label CLI[expr $i-16]"
        $n($i) shape circle
}

#Attach nodes 52-53 to node 8
for {set i 52} {$i < 54} {incr i} {
        $ns duplex-link $n($i) $n(8) 10Mb 10ms DropTail
        $ns at 0.0 "$n($i) label CLI[expr $i-16]"
        $n($i) shape circle
}

#Attach nodes 54-60 to node 10
for {set i 54} {$i <= 60} {incr i} {
        $ns duplex-link $n($i) $n(10) 10Mb 10ms DropTail
        $ns at 0.0 "$n($i) label CLI[expr $i-16]"
        $n($i) shape circle
}

#To return the results of pings, a function is declared that takes the ping values and
#shows them in the terminal
Agent/Ping instproc recv {from rtt} {
$self instvar node_
#Gets the ping value from a node and returns the milliseconds it took for the request
#to be completed.
puts "node [$node_ id] got ping value from \ $from - round-trip-time $rtt ms."
}

#Create a TCP connection so that TCP packets can travel to the desired node
set tcp0 [new Agent/TCP]
#Makes it so that TCP packets have a certain colour
$tcp0 set class_ 2
#Establishes the starting node for packets to be sent from
$ns attach-agent $n(0) $tcp0
#Creates a new sink for packets to be received
set sink0 [new Agent/TCPSink]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(51) $sink0
#Creates a connection for the packets to travel through
$ns connect $tcp0 $sink0
#Makes it so that TCP packets have a certain colour by setting a unique flow
$tcp0 set fid_ 1

#Setup a FTP over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

#Create a TCP connection so that TCP packets can travel to the desired node
set tcp1 [new Agent/TCP]
#Makes it so that TCP packets have a certain colour
$tcp1 set class_ 2
#Establishes the starting node for packets to be sent from
$ns attach-agent $n(7) $tcp1
#Creates a new sink for packets to be received
set sink1 [new Agent/TCPSink]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(34) $sink1
#Creates a connection for the packets to travel through
$ns connect $tcp1 $sink1
#Makes it so that TCP packets have a certain colour by setting a unique flow
$tcp1 set fid_ 1

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

#Create a UDP connection so that UDP packets can travel to the desired node
set udp0 [new Agent/UDP]
#Establishes the starting node for packets to be sent from
$ns attach-agent $n(8) $udp0
#Create a Null agent (a traffic sink)
set null0 [new Agent/Null]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(28) $null0
#Creates a connection for the packets to travel through
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
#Disables randomness for the connection
$cbr0 set random_ false

#Create a UDP connection so that UDP packets can travel to the desired node
set udp1 [new Agent/UDP]
#Establishes the starting node for packets to be sent from
$ns attach-agent $n(2) $udp1
#Creates a new sink for packets to be received
set null1 [new Agent/Null]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(25) $null1
#Creates a connection for the packets to travel through
$ns connect $udp1 $null1
#Makes it so that UDP packets have a certain colour by seting a unique flow
$udp1 set fid_ 2

#Setup a CBR over UDP connection
set cbr1 [new Application/Traffic/CBR]
#Sets the UDP connection up with CBR
$cbr1 attach-agent $udp1
#Sets the type of traffic used to CBR
$cbr1 set type_ CBR
#Sets packet size to 1000
$cbr1 set packet_size_ 1000
#Sets the rate of the packet to 1mb
$cbr1 set rate_ 1mb
#Disables randomness for the connection
$cbr1 set random_ false

#Set up pings to check if the subnets can reach other
set p0 [new Agent/Ping]
#Establish the node the ping will come from (repeat for rest of pings)
$ns attach-agent $n(38) $p0
set p1 [new Agent/Ping]
$ns attach-agent $n(21) $p1
set p2 [new Agent/Ping]
$ns attach-agent $n(44) $p2
set p3 [new Agent/Ping]
$ns attach-agent $n(51) $p3

#Connect the ping requests
$ns connect $p0 $p1
$ns connect $p2 $p3

#Create a schedule of when certain TCP and UDP connections will start and stop
#transmitting packets to each other

$ns at 4.0 "$ftp0 start"
$ns at 95.0 "$ftp0 stop"
$ns at 2.0 "$ftp1 start"
$ns at 41.0 "$ftp1 stop"

$ns at 8.0 "$cbr0 start"
$ns at 64.0 "$cbr0 stop"
$ns at 50.0 "$cbr1 start"
$ns at 95.0 "$cbr1 stop"

#Do the same except for pings

$ns at 1.5 "$p0 send"
$ns at 17.3 "$p1 send"
$ns at 41.8 "$p2 send"
$ns at 88.8 "$p3 send"
$ns at 25.1 "$p0 send"
$ns at 52.9 "$p1 send"
$ns at 33.2 "$p2 send"
$ns at 67.5 "$p3 send"

#Define a 'finish' procedure which will close the trace files
#and open up the network animator before closing the simulation
proc finish {} {
        global ns nf tf
        $ns flush-trace
	#Close the nam trace file
        close $nf
    #Close the trace file
        close $tf
	#Execute nam on the trace file
        exec nam Scenario_Ring_Bus_Topology.nam &
	#Exit the simulation
        exit 0
}

#After 100 seconds, the finish procedure is called and executed
$ns at 101.0 "finish"

#Run the simulation
$ns run