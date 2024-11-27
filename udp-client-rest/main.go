package main

import (
	"bufio"
	"fmt"
	"net"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		udpResponse, err := getUDPResponse(r.URL.Query().Get("msg"))
		if err != nil {
			fmt.Println(err)
			w.Write([]byte("Error: " + err.Error()))
			return
		}

		w.Write([]byte(fmt.Sprintf("UDP response: %s\n", udpResponse)))
	})
	http.ListenAndServe(":8080", nil)
}

func getUDPResponse(msg string) (string, error) {
	udpAddr, err := net.ResolveUDPAddr("udp", "localhost:8125")

	if err != nil {
		return "", err
	}

	conn, err := net.DialUDP("udp", nil, udpAddr)

	if err != nil {
		return "", err
	}

	_, err = conn.Write([]byte(msg + "\n"))
	if err != nil {
		return "", err
	}

	data, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		return "", err
	}

	return string(data), nil
}
