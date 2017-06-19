package main

import (
	"encoding/json"
	"os"
	"regexp"
)

type field struct {
	Regex    string `json:"regex"`
	Alias    string `json:"alias"`
	Value    string `json:"value"`
	Hostname bool   `json:"hostname"`

	compiled *regexp.Regexp
}

type spec map[string]*field

func newFilter(sp spec) (*filter, error) {
	f := &filter{spec: sp}
	err := f.compile()
	return f, err
}

type filter struct {
	spec        spec
	tpl         map[string]string
	hostname    string
	hostnameKey string
}

func (f *filter) compile() error {
	tpl := map[string]string{}

	for k, field := range f.spec {
		if field.Regex != "" {
			var err error
			field.compiled, err = regexp.Compile(field.Regex)
			if err != nil {
				return err
			}
		}
		if field.Value != "" {
			tpl[k] = field.Value
		}
		if field.Hostname {
			f.hostnameKey = k
		}
	}

	f.hostname, _ = os.Hostname()

	f.tpl = tpl
	return nil
}

func (f *filter) filter(data []byte) []byte {
	in := map[string]string{}
	out := map[string]string{}

	for k, v := range f.tpl {
		out[k] = v
	}

	if f.hostnameKey != "" {
		out[f.hostnameKey] = f.hostname
	}

	json.Unmarshal(data, &in)

	catchAll := f.spec["*"]

	for k, v := range in {
		if k == "" {
			continue
		}

		field, ok := f.spec[k]
		if !ok {
			field = catchAll
		}
		if field == nil {
			continue
		}

		if field.compiled != nil {
			matches := field.compiled.FindStringSubmatch(v)
			for i, name := range field.compiled.SubexpNames() {
				if name == "" {
					continue
				}
				out[name] = matches[i]
			}
			continue
		}

		if field.Alias != "" {
			out[field.Alias] = v
			continue
		}

		out[k] = v
	}

	outData, _ := json.Marshal(out)
	return outData
}

var specs = map[string]spec{
	"K8Spec": {
		"CONTAINER_NAME": {
			Regex: "k8s_(?P<k8s_container_name>[^_]+)_(?P<k8s_pod_name>[^_]+)_(?P<k8s_namespace>[^_]+)_(?P<k8s_uid>[^_]+)_(?P<k8s_attempts>[^_]+)",
		},
		"CONTAINER_ID":               {Alias: "container_id"},
		"MESSAGE":                    {Alias: "message"},
		"_SOURCE_REALTIME_TIMESTAMP": {Alias: "timestamp"},
		"cluster":                    {Alias: os.Getenv("K8S_CLUSTER_NAME")},
		"host":                       {Hostname: true},
	},
	"NoFilterSpec": {
		"*": {},
	},
}

var specOptions = func() (out []string) {
	for k := range specs {
		out = append(out, k)
	}
	return out
}()
