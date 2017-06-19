package main

import (
	"bufio"
	"log"
	"net"
	"os"
)

type ingestor struct {
	buffer    int
	filter    *filter
	remoteUdp string
	localUdp  string

	logErrors   bool
	logMessages bool

	incoming chan []byte
	outgoing chan []byte
}

func (in *ingestor) open() error {
	in.incoming = make(chan []byte, in.buffer)
	in.outgoing = make(chan []byte, in.buffer)
	return nil
}

func (in *ingestor) reader() {
	reader := bufio.NewReader(os.Stdin)
	for {
		data, err := reader.ReadBytes('\n')
		if err != nil {
			continue
		}
		in.incoming <- data
	}
}

func (in *ingestor) filtering() {
	for msg := range in.incoming {
		out := in.filter.filter(msg)
		in.outgoing <- out
	}
}

func (in *ingestor) forwarder() error {
	target, err := net.ResolveUDPAddr("udp", in.remoteUdp)
	if err != nil {
		return err
	}

	local, err := net.ResolveUDPAddr("udp", in.localUdp)
	if err != nil {
		return err
	}

	conn, err := net.DialUDP("udp", local, target)
	if err != nil {
		return err
	}

	defer conn.Close()

	for msg := range in.outgoing {
		if in.logMessages {
			log.Printf("write udp: %s", msg)
		}
		_, err := conn.Write(msg)
		if err != nil {
			if in.logErrors {
				log.Printf("failed to write udp: %v", err)
			}
		}
	}
	return nil
}
