package agent

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type OllamaClient struct {
	Host       string
	Model      string
	HTTPClient *http.Client
}

type ollamaChatRequest struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
	Stream   bool      `json:"stream"`
}

type ollamaChatResponse struct {
	Message Message `json:"message"`
	Done    bool    `json:"done"`
}

func NewOllamaClientFromEnv() *OllamaClient {
	host := os.Getenv("OLLAMA_HOST")
	if host == "" {
		host = "http://127.0.0.1:11434"
	}

	if strings.HasPrefix(host, "tcp://") {
		host = "http://" + strings.TrimPrefix(host, "tcp://")
	}

	model := os.Getenv("NESTOR_OLLAMA_MODEL")
	if model == "" {
		model = "qwen3:8b"
	}

	return &OllamaClient{
		Host:  strings.TrimRight(host, "/"),
		Model: model,
		HTTPClient: &http.Client{
			Timeout: 5 * time.Minute,
		},
	}
}

func (c *OllamaClient) Chat(ctx context.Context, messages []Message) (string, error) {
	fmt.Printf(
		"OLLAMA host=%s model=%s messages=%d\n",
		c.Host,
		c.Model,
		len(messages),
	)
	payload := ollamaChatRequest{
		Model:    c.Model,
		Messages: messages,
		Stream:   false,
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.Host+"/api/chat", bytes.NewReader(body))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")

	fmt.Printf("OLLAMA URL=%s\n", c.Host+"/api/chat")
	fmt.Printf("OLLAMA PAYLOAD=%s\n", string(body))

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	bodyResp, _ := io.ReadAll(resp.Body)

	fmt.Printf(
		"OLLAMA STATUS=%d BODY=%s\n",
		resp.StatusCode,
		string(bodyResp),
	)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("ollama chat failed: %s", resp.Status)
	}

	var decoded ollamaChatResponse
	if err := json.Unmarshal(bodyResp, &decoded); err != nil {
		return "", err
	}

	return decoded.Message.Content, nil
}
