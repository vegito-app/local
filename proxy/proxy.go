package main

import (
	"log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"
	"time"

	"github.com/spf13/viper"
)

var config = viper.New()

const (
	targetHostConfig = "target_host"
	targetPortConfig = "target_port"
	listenPortConfig = "listen_port"
	listenHostConfig = "proxy_host"
)

func hostOnly(hostport string) string {
	host, _, err := net.SplitHostPort(hostport)
	if err == nil {
		return host
	}
	return hostport
}

func headerValue(header http.Header, key string) string {
	value := header.Get(key)
	if value == "" {
		return "-"
	}
	return value
}

func logRequest(prefix string, req *http.Request) {
	if req == nil {
		log.Printf("%s request=<nil>", prefix)
		return
	}

	log.Printf(
		"%s method=%s url=%s scheme=%s host=%s url_host=%s remote=%s origin=%s referer=%s xfh=%s xfp=%s xff=%s upgrade=%s connection=%s content_length=%d content_type=%s",
		prefix,
		req.Method,
		req.URL.String(),
		req.URL.Scheme,
		req.Host,
		req.URL.Host,
		req.RemoteAddr,
		headerValue(req.Header, "Origin"),
		headerValue(req.Header, "Referer"),
		headerValue(req.Header, "X-Forwarded-Host"),
		headerValue(req.Header, "X-Forwarded-Proto"),
		headerValue(req.Header, "X-Forwarded-For"),
		headerValue(req.Header, "Upgrade"),
		headerValue(req.Header, "Connection"),
		req.ContentLength,
		headerValue(req.Header, "Content-Type"),
	)
}

func logResponse(prefix string, res *http.Response) {
	if res == nil {
		log.Printf("%s response=<nil>", prefix)
		return
	}

	log.Printf(
		"%s status=%d method=%s url=%s host=%s location=%s acao=%s vary=%s set_cookie_count=%d content_type=%s content_length=%d",
		prefix,
		res.StatusCode,
		res.Request.Method,
		res.Request.URL.String(),
		res.Request.Host,
		headerValue(res.Header, "Location"),
		headerValue(res.Header, "Access-Control-Allow-Origin"),
		headerValue(res.Header, "Vary"),
		len(res.Header.Values("Set-Cookie")),
		headerValue(res.Header, "Content-Type"),
		res.ContentLength,
	)
}

func looksInterestingPath(path string) bool {
	interesting := []string{
		"check",
		"update",
		"draft",
		"pending",
		"start",
		"sessions",
		"workspaces",
		"models",
	}
	for _, token := range interesting {
		if strings.Contains(path, token) {
			return true
		}
	}
	return false
}

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("local_proxy")
	config.SetDefault(targetHostConfig, "localhost")
	config.SetDefault(targetPortConfig, "8080")
	config.SetDefault(listenPortConfig, "8081")
	config.BindEnv(targetHostConfig, "TARGET_HOST")
	config.BindEnv(targetPortConfig, "TARGET_PORT")
	config.BindEnv(listenHostConfig, "LISTEN_HOST")
	config.BindEnv(listenPortConfig, "LISTEN_PORT")
}

func main() {

	targetHost := config.GetString(targetHostConfig)
	targetPort := config.GetString(targetPortConfig)
	listenHost := config.GetString(listenHostConfig)
	// Redirect using same port that listen
	targetUrl, err := url.Parse("http://" + net.JoinHostPort(targetHost, targetPort))
	if err != nil {
		panic(err)
	}

	log.Printf("localproxy config listen_host=%q listen_port=%q target_url=%q target_host=%q target_port=%q", listenHost, config.GetString(listenPortConfig), targetUrl.String(), targetHost, targetPort)

	proxy := httputil.NewSingleHostReverseProxy(targetUrl)

	proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
		log.Printf("proxy error method=%s url=%s host=%s remote=%s err=%v", r.Method, r.URL.String(), r.Host, r.RemoteAddr, err)
		http.Error(w, "proxy error", http.StatusBadGateway)
	}

	proxy.ModifyResponse = func(res *http.Response) error {
		if looksInterestingPath(res.Request.URL.Path) || res.StatusCode >= 400 || res.Header.Get("Location") != "" || res.Header.Get("Access-Control-Allow-Origin") != "" {
			logResponse("proxy response", res)
		}
		return nil
	}

	//nolint:staticcheck
	// Director is deprecated but remains the simplest
	// and most maintainable solution until Rewrite
	// provides an equivalent helper.//
	// TODO(go): migrate when Rewrite provides a
	// non-copy-paste replacement for NewSingleHostReverseProxy.

	director := proxy.Director

	// This deliberately rewrites the outbound Host header to the target host.
	proxy.Director = func(req *http.Request) {
		beforeHost := req.Host
		beforeURL := req.URL.String()

		if looksInterestingPath(req.URL.Path) || req.Header.Get("Origin") != "" || req.Header.Get("Upgrade") != "" {
			logRequest("proxy director before", req)
		}

		director(req)
		req.Host = targetUrl.Host // this intentionally overwrites the host

		if looksInterestingPath(req.URL.Path) || req.Header.Get("Origin") != "" || req.Header.Get("Upgrade") != "" {
			log.Printf("proxy director rewrite before_host=%s before_url=%s after_host=%s after_url=%s target=%s", beforeHost, beforeURL, req.Host, req.URL.String(), targetUrl.String())
			logRequest("proxy director after", req)
		}
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		startedAt := time.Now()
		h := hostOnly(r.Host)

		if looksInterestingPath(r.URL.Path) || r.Header.Get("Origin") != "" || r.Header.Get("Upgrade") != "" {
			logRequest("proxy inbound", r)
		}

		if listenHost != "" && h != listenHost {
			log.Printf("proxy rejected invalid host raw_host=%s parsed_host=%s expected_host=%s method=%s url=%s remote=%s", r.Host, h, listenHost, r.Method, r.URL.String(), r.RemoteAddr)
			http.Error(w, "invalid host", http.StatusForbidden)
			return
		}

		proxy.ServeHTTP(w, r)

		if looksInterestingPath(r.URL.Path) || r.Header.Get("Origin") != "" || r.Header.Get("Upgrade") != "" {
			log.Printf("proxy served method=%s url=%s host=%s duration=%s", r.Method, r.URL.String(), r.Host, time.Since(startedAt))
		}
	})
	listenPort := config.GetString(listenPortConfig)
	log.Printf("localproxy listening on :%s", listenPort)
	if err := http.ListenAndServe(":"+listenPort, nil); err != nil {
		log.Fatal(err)
	}
}
