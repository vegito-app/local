package main

import (
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"

	"github.com/spf13/viper"
)

var config = viper.New()

const (
	targetHostConfig = "target_host"
	targetPortConfig = "target_port"
	listenPortConfig = "listen_port"
	listenHostConfig = "proxy_host"
)

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

	proxy := httputil.NewSingleHostReverseProxy(targetUrl)

	//nolint:staticcheck
	// Director is deprecated but remains the simplest
	// and most maintainable solution until Rewrite
	// provides an equivalent helper.//
	// TODO(go): migrate when Rewrite provides a
	// non-copy-paste replacement for NewSingleHostReverseProxy.

	director := proxy.Director

	// This will rewrite the Host header
	proxy.Director = func(req *http.Request) {
		if listenHost != "" &&
			req.Host != "" &&
			req.Host != listenHost {
			return
		}
		director(req)
		req.Host = targetUrl.Host // this overwrites the host
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if listenHost != "" &&
			r.Host != "" &&
			r.Host != listenHost {

			http.Error(w, "invalid host", http.StatusForbidden)
			return
		}

		proxy.ServeHTTP(w, r)
	})
	listenPort := config.GetString(listenPortConfig)
	http.ListenAndServe(":"+listenPort, nil)
}
