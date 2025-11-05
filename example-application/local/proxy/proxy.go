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
)

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("local_proxy")
	config.SetDefault(targetHostConfig, "localhost")
	config.SetDefault(targetPortConfig, "8080")
	config.SetDefault(listenPortConfig, "8081")
	config.BindEnv(targetHostConfig, "TARGET_HOST")
	config.BindEnv(targetPortConfig, "TARGET_PORT")
	config.BindEnv(listenPortConfig, "LISTEN_PORT")
}

func main() {

	targetHost := config.GetString(targetHostConfig)
	targetPort := config.GetString(targetPortConfig)
	// Redirect using same port that listen
	targetUrl, err := url.Parse("http://" + net.JoinHostPort(targetHost, targetPort))
	if err != nil {
		panic(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(targetUrl)

	director := proxy.Director

	// This will rewrite the Host header
	proxy.Director = func(req *http.Request) {
		director(req)
		req.Host = targetUrl.Host // this overwrites the host
	}

	http.Handle("/", proxy)

	listenPort := config.GetString(listenPortConfig)
	http.ListenAndServe(":"+listenPort, nil)
}
