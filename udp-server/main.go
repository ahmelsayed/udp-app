package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	udpAddr, err := net.ResolveUDPAddr("udp", "0.0.0.0:8125")

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	conn, err := net.ListenUDP("udp", udpAddr)

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	for {
		var buf [512]byte
		_, addr, err := conn.ReadFromUDP(buf[0:])
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		strMsg := string(buf[0:])
		fmt.Print("> ", strMsg)

		conn.WriteToUDP([]byte("Hello UDP Client, received:> " + strMsg + "\n"), addr)
	}
}
