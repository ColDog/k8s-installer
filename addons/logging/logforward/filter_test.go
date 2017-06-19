package main

import (
	"encoding/json"
	"testing"
)

func TestFilter_Regex(t *testing.T) {
	test := map[string]string{
		"CONTAINER_NAME": "k8s_frontend_foo_bar_iamuid_4",
		"CONTAINER_ID":   "test",
		"MESSAGE":        "Hello",
	}
	data, _ := json.Marshal(test)

	sp := specs["K8Spec"]

	f, err := newFilter(sp)
	if err != nil {
		t.Fatal(err)
	}

	out := f.filter(data)
	println(string(out))
}
