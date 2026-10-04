package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/CipherTun/payload-injector-generator/engine/go/internal/engine"
	"github.com/CipherTun/payload-injector-generator/engine/go/internal/model"
)

func main() {
	inputPath := flag.String("input", "", "JSON file containing a PayloadLab spec")
	flag.Parse()

	if *inputPath == "" {
		fmt.Fprintln(os.Stderr, "usage: payloadlab --input spec.json")
		os.Exit(2)
	}

	data, err := os.ReadFile(*inputPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var spec model.Spec
	if err := json.Unmarshal(data, &spec); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	result := engine.Generate(spec)
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	if err := enc.Encode(result); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if len(result.Errors) > 0 {
		os.Exit(1)
	}
}
