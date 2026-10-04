package engine

import (
	"testing"

	"github.com/CipherTun/payload-injector-generator/engine/go/internal/model"
)

func TestGenerateNormal(t *testing.T) {
	r := Generate(model.Spec{Host: "example.com", Port: 443, Method: "CONNECT", Protocol: "HTTP/1.1", Type: model.Normal})
	if len(r.Errors) != 0 {
		t.Fatalf("unexpected errors: %v", r.Errors)
	}
	if r.Payload == "" {
		t.Fatal("empty payload")
	}
}

func TestRejectInvalidPort(t *testing.T) {
	r := Generate(model.Spec{Host: "example.com", Port: 0, Method: "GET", Protocol: "HTTP/1.1", Type: model.Normal})
	if len(r.Errors) == 0 {
		t.Fatal("expected invalid port error")
	}
}
