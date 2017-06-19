package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
	"strings"
)

var (
	bufferSize  int    = 5000
	configFile  string = "/etc/kube-logger/config.json"
	remoteUdp   string = "127.0.0.1:20001"
	localUdp    string = "127.0.0.1:10001"
	defaultSpec string
	logErrors   bool
	logMessages bool
)

func main() {
	flag.IntVar(&bufferSize, "buffer-size", bufferSize, "Message buffer size")
	flag.StringVar(&configFile, "config", configFile, "Config file path")
	flag.StringVar(&defaultSpec, "spec", defaultSpec, "Pre configured filter specifications: "+strings.Join(specOptions, ","))
	flag.StringVar(&remoteUdp, "remote-udp", remoteUdp, "Remote UDP forwarder address")
	flag.StringVar(&localUdp, "local-udp", localUdp, "Local UDP forwarder address")
	flag.BoolVar(&logErrors, "log-errors", logErrors, "Log error messages to STDOUT")
	flag.BoolVar(&logMessages, "log-messages", logMessages, "Log all messages to STDOUT for debuggin")
	flag.Parse()

	var selectedSpec spec

	if defaultSpec != "" {
		selectedSpec = specs[defaultSpec]
		if selectedSpec == nil {
			log.Fatalf("spec does not exist: %s", defaultSpec)
		}
	} else {
		f, err := os.Open(configFile)
		if err != nil {
			log.Fatalf("failed to read config: %v", err)
		}
		selectedSpec = spec{}
		err = json.NewDecoder(f).Decode(&selectedSpec)
		if err != nil {
			log.Fatalf("failed to read config: %v", err)
		}
	}

	selectedFilter, err := newFilter(selectedSpec)
	if err != nil {
		log.Fatalf("failed to create filter: %v", err)
	}

	ing := &ingestor{
		filter:      selectedFilter,
		localUdp:    localUdp,
		remoteUdp:   remoteUdp,
		logMessages: logMessages,
		logErrors:   logErrors,
	}

	err = ing.open()
	if err != nil {
		log.Fatalf("failed to open ingestor: %v", err)
	}

	go ing.reader()
	go ing.filtering()
	err = ing.forwarder()
	if err != nil {
		log.Fatalf("failed to forward udp: %v", err)
	}
}
