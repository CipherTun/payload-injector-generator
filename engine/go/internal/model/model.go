package model

type PayloadType string

const (
	Normal      PayloadType = "normal"
	FrontInject PayloadType = "front_inject"
	BackInject  PayloadType = "back_inject"
	FrontQuery  PayloadType = "front_query"
	BackQuery   PayloadType = "back_query"
	WebSocket   PayloadType = "websocket"
	SNI         PayloadType = "sni"
)

type Spec struct {
	Host      string            `json:"host"`
	Port      int               `json:"port"`
	Method    string            `json:"method"`
	Protocol  string            `json:"protocol"`
	Type      PayloadType       `json:"type"`
	UserAgent string            `json:"user_agent,omitempty"`
	Headers   map[string]string `json:"headers,omitempty"`
	Split     bool              `json:"split,omitempty"`
}

type Result struct {
	Payload  string   `json:"payload"`
	Warnings []string `json:"warnings"`
	Errors   []string `json:"errors"`
}
