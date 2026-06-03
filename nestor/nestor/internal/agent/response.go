package agent

import (
	"encoding/json"
	"fmt"
	"strings"
)

type Response struct {
	Tool   string            `json:"tool,omitempty"`
	Args   map[string]string `json:"args,omitempty"`
	Done   bool              `json:"done,omitempty"`
	Result string            `json:"result,omitempty"`
}

func ParseResponse(raw string) (Response, error) {
	cleaned := strings.TrimSpace(raw)

	if strings.HasPrefix(cleaned, "```") {
		cleaned = strings.TrimPrefix(cleaned, "```json")
		cleaned = strings.TrimPrefix(cleaned, "```")
		cleaned = strings.TrimSuffix(cleaned, "```")
		cleaned = strings.TrimSpace(cleaned)
	}

	var response Response
	if err := json.Unmarshal([]byte(cleaned), &response); err != nil {
		return Response{}, fmt.Errorf("parse agent response: %w: %s", err, raw)
	}

	return response, nil
}
