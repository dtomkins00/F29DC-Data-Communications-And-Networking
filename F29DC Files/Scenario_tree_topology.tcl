#Code to simulate a network with subnet star and tree topologies with a central computer being
#connected to 10 routers which each have a server that has many clients connected to them, featuring
#100 nodes total using the Link State (LS) protocol
#By Drew Tomkins

#Create a simulator object
set ns [new Simulator]

#Make it so the simulator uses the LS protocol to enable dynamic routing
$ns rtproto LS

#Assign colours to the data packets so they can be told apart
$ns color 1 green
$ns color 2 purple
$ns color 3 yellow

#Open the nam trace file
set nf [open Scenario_tree_topology.nam w]
$ns namtrace-all $nf

#Open the trace file
set tf [open Scenario_tree_topology.tr w]
$ns trace-all $tf

#Create 100 nodes, with 1 central router, 10 routers connected to that, 1 server for
#each of the 10 routers and the rest being clients connected to the server
for {set i 0} {$i < 100} {incr i} {
        set n($i) [$ns node]
}

#For the central node, ensure that the current amount of nodes is below 10
for {set i 0} {$i < 10} {incr i} {
    #Create the node with its connection details
    $ns duplex-link $n(99) $n($i) 100Mb 10ms DropTail
	#When the animation starts, label it as a router
    $ns at 0.0 "$n(99) label ROU$i"
	
	#Make the node into a square so it can be seen as a router
    $n(99) shape square
	#Colour it blue
    $n(99) color blue
}

#Create the rest of the nodes to act as routers for the servers to function off of
for {set i 0} {$i < 10} {incr i} {
   #Create the nodes with their connection details
   $ns duplex-link $n($i) $n([expr ($i+1)%10]) 100Mb 10ms DropTail
   #When the animation starts, label them as routers
   $ns at 0.0 "$n($i) label ROU$i"
   #Make the nodes into squares so they can be seen as routers
    $n($i) shape square
   #Colour them blue
    $n($i) color blue
}

#For each router, a node will be created that acts as a server
for {set i 10} {$i < 20} {incr i} {
   #Create the nodes with their connection details
    $ns duplex-link $n($i) $n([expr ($i-10)]) 100Mb 10ms DropTail
   #When the animation starts, label them as servers
    $ns at 0.0 "$n($i) label SERVER[expr ($i-10)]"
   #Make the nodes into circles
    $n($i) shape circle
   #Colour them red to differentiate them from routers and clients
    $n($i) color red
}

#For the rest of the nodes, connect them to the servers to act as clients
for {set i 20} {$i < 99} {incr i} {
    #Give the nodes a smaller packet size and make sure thery only connect to servers
    $ns duplex-link $n($i) $n([expr (($i+1)%10)+10]) 1Mb 1ms DropTail
	#Label them as clients when the animation starts
    $ns at 0.0 "$n($i) label CLI[expr ($i-20)]"
	#Make them circles
    $n($i) shape circle
	#Make them black
    $n($i) color Black
}

#To return the results of pings, a function is declared that takes the ping values and
#shows them in the terminal
Agent/Ping instproc recv {from rtt} {
$self instvar node_
#Gets the ping value from a node and returns the milliseconds it took for the request
#to be completed.
puts "node [$node_ id] received ping answer from \
              $from with round-trip-time $rtt ms."
}

#------------TCP Connections-------------#

#Create a TCP connection so that TCP packets can travel to the desired node
set tcp0 [new Agent/TCP]
#Makes it so that TCP packets have a certain colour
$tcp0 set class_ 2
#Establishes the starting node for packets to be sent from
$ns attach-agent $n(69) $tcp0
#Creates a new sink for packets to be received
set sink0 [new Agent/TCPSink]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(51) $sink0
#Creates a connection for the packets to travel through
$ns connect $tcp0 $sink0
#Makes it so that TCP packets have a certain colour
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
$ns attach-agent $n(92) $tcp1
#Creates a new sink for packets to be received
set sink1 [new Agent/TCPSink]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(48) $sink1
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
$ns attach-agent $n(53) $udp0
#Creates a new sink for packets to be received
set null0 [new Agent/Null]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(31) $null0
#Creates a connection for the packets to travel through
$ns connect $udp0 $null0
#Makes it so that UDP packets have a certain colour by setting a unique flow
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
$ns attach-agent $n(85) $udp1
#Creates a new sink for packets to be received
set null1 [new Agent/Null]
#Establishes the end node for packets to be delivered
$ns attach-agent $n(76) $null1
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
$ns attach-agent $n(37) $p0
set p1 [new Agent/Ping]
$ns attach-agent $n(24) $p1
set p2 [new Agent/Ping]
$ns attach-agent $n(79) $p2
set p3 [new Agent/Ping]
$ns attach-agent $n(66) $p3

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
        exec nam Scenario_tree_topology.nam &
        exit 0
}

#After 100 seconds, the finish procedure is called and executed
$ns at 101.0 "finish"

#Run the simulation
$ns run