package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

type StrMapFlag map[string]string

func (i *StrMapFlag) String() string {
	return fmt.Sprintf("%+v", *i)
}

func (i *StrMapFlag) Set(value string) error {
	parts := strings.Split(value, "=")
	if len(parts) <= 1 {
		return fmt.Errorf("expected format key=value, received: %s", value)
	}
	(*i)[parts[0]] = parts[1]
	return nil
}

var (
	checks = StrMapFlag{
		"apiserver":         "http://127.0.0.1:80/healthz",
		"scheduler":         "http://127.0.0.1:10251/healthz",
		"controllermanager": "http://127.0.0.1:10252/healthz",
	}
	listen string
)

func run(url string) error {
	r, err := http.Get(url)
	if err != nil {
		return err
	}
	defer r.Body.Close()
	if r.StatusCode == 200 {
		return nil
	}
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return err
	}
	return fmt.Errorf("check failed (%d): %s", r.StatusCode, data)
}

func healthz(w http.ResponseWriter, r *http.Request) {
	ok := true
	buf := bytes.NewBuffer(nil)

	for name, check := range checks {
		err := run(check)
		if err != nil {
			buf.WriteString(name + ": " + err.Error() + "\n")
			ok = false
		}
	}
	if ok {
		w.WriteHeader(200)
		w.Write([]byte("ok\n"))
		return
	}

	w.WriteHeader(500)
	buf.WriteTo(w)
}

func main() {
	flag.StringVar(&listen, "listen", "0.0.0.0:6199", "Address and port to listen on")
	flag.Var(&checks, "checks", "")
	flag.Parse()

	http.HandleFunc("/healthz", healthz)
	err := http.ListenAndServe(listen, nil)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
}
