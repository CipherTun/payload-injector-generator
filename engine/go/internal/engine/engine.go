package engine

import (
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"net/url"
	"regexp"
	"strings"

	"github.com/CipherTun/payload-injector-generator/engine/go/internal/model"
)

var controlChars = regexp.MustCompile(`[\r\n]`)

func Generate(s model.Spec) model.Result {
	var out model.Result
	host := strings.TrimSpace(s.Host)

	if host == "" {
		out.Errors = append(out.Errors, "host is required")
	}
	if controlChars.MatchString(host) {
		out.Errors = append(out.Errors, "host must not contain CR or LF")
	}
	if s.Port < 1 || s.Port > 65535 {
		out.Errors = append(out.Errors, "port must be between 1 and 65535")
	}
	if strings.TrimSpace(s.Method) == "" {
		out.Errors = append(out.Errors, "method is required")
	}
	if strings.TrimSpace(s.Protocol) == "" {
		out.Errors = append(out.Errors, "protocol is required")
	}
	for name, value := range s.Headers {
		if strings.TrimSpace(name) == "" || strings.ContainsAny(name, "\r\n:") {
			out.Errors = append(out.Errors, "invalid header name")
		}
		if controlChars.MatchString(value) {
			out.Errors = append(out.Errors, "header values must not contain CR or LF")
		}
	}
	if len(out.Errors) > 0 {
		return out
	}

	crlf := "\r\n"
	authority := fmt.Sprintf("%s:%d", host, s.Port)
	method := strings.ToUpper(strings.TrimSpace(s.Method))
	protocol := strings.TrimSpace(s.Protocol)
	var b strings.Builder

	switch s.Type {
	case model.FrontInject:
		fmt.Fprintf(&b, "GET http://%s/ %s%sHost: %s%s%s %s %s%s",
			host, protocol, crlf, host, crlf+crlf, method, authority, protocol, crlf)
	case model.BackInject:
		fmt.Fprintf(&b, "%s %s %s%s%s%sGET http://%s/ %s%sHost: %s",
			method, authority, protocol, crlf, crlf, "", host, protocol, crlf, host)
	case model.FrontQuery:
		fmt.Fprintf(&b, "%s %s@%s %s%s", method, host, authority, protocol, crlf)
	case model.BackQuery:
		fmt.Fprintf(&b, "%s %s@%s %s%s", method, authority, host, protocol, crlf)
	case model.WebSocket:
		fmt.Fprintf(&b, "%s %s %s%sUpgrade: websocket%sConnection: Upgrade%sHost: %s%s",
			method, authority, protocol, crlf, crlf, crlf, host, crlf)
	default:
		fmt.Fprintf(&b, "%s %s %s%sHost: %s%s", method, authority, protocol, crlf, host, crlf)
	}

	if s.UserAgent != "" {
		fmt.Fprintf(&b, "User-Agent: %s%s", s.UserAgent, crlf)
	}
	for name, value := range s.Headers {
		if strings.EqualFold(name, "host") {
			continue
		}
		fmt.Fprintf(&b, "%s: %s%s", strings.TrimSpace(name), value, crlf)
	}
	b.WriteString(crlf)
	out.Payload = b.String()

	if s.Split {
		out.Payload = strings.Replace(out.Payload, crlf+"Host: "+host, "[split]"+crlf+"Host: "+host, 1)
		out.Warnings = append(out.Warnings, "split is an inspection marker, not a transmitted protocol primitive")
	}
	if s.Type == model.SNI {
		out.Warnings = append(out.Warnings, "SNI belongs to the TLS layer and cannot be represented by an HTTP request line")
	}
	return out
}

func Base64Encode(s string) string { return base64.StdEncoding.EncodeToString([]byte(s)) }
func Base64Decode(s string) (string, error) {
	b, err := base64.StdEncoding.DecodeString(strings.TrimSpace(s))
	return string(b), err
}
func URLEncode(s string) string          { return url.QueryEscape(s) }
func URLDecode(s string) (string, error) { return url.QueryUnescape(s) }
func HexEncode(s string) string          { return hex.EncodeToString([]byte(s)) }
func HexDecode(s string) (string, error) {
	b, err := hex.DecodeString(strings.ReplaceAll(strings.TrimSpace(s), " ", ""))
	return string(b), err
}

func ValidateRaw(s string) []string {
	var errors []string
	if s == "" {
		return []string{"input is empty"}
	}
	if !strings.Contains(s, "\r\n\r\n") {
		errors = append(errors, "no HTTP-style CRLF CRLF terminator found")
	}
	first := strings.SplitN(s, "\r\n", 2)[0]
	if len(strings.Fields(first)) < 2 {
		errors = append(errors, "first line does not contain enough request fields")
	}
	return errors
}
