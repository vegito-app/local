package main

import (
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"

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
	targetURL, err := url.Parse("http://" + net.JoinHostPort(targetHost, targetPort))
	if err != nil {
		panic(err)
	}

	http.Handle("/", &httputil.ReverseProxy{
		Rewrite: func(req *httputil.ProxyRequest) {
			rewriteRequestURL(req.Out, targetURL)
			req.Out.Host = targetURL.Host // this overwrites the host
		},
	})

	listenPort := config.GetString(listenPortConfig)
	http.ListenAndServe(":"+listenPort, nil)
}

func rewriteRequestURL(req *http.Request, target *url.URL) {
	targetQuery := target.RawQuery
	req.URL.Scheme = target.Scheme
	req.URL.Host = target.Host
	req.URL.Path, req.URL.RawPath = joinURLPath(target, req.URL)
	if targetQuery == "" || req.URL.RawQuery == "" {
		req.URL.RawQuery = targetQuery + req.URL.RawQuery
	} else {
		req.URL.RawQuery = targetQuery + "&" + req.URL.RawQuery
	}
}

func joinURLPath(a, b *url.URL) (path, rawpath string) {
	if a.RawPath == "" && b.RawPath == "" {
		return singleJoiningSlash(a.Path, b.Path), ""
	}
	// Same as singleJoiningSlash, but uses EscapedPath to determine
	// whether a slash should be added
	apath := a.EscapedPath()
	bpath := b.EscapedPath()

	aslash := strings.HasSuffix(apath, "/")
	bslash := strings.HasPrefix(bpath, "/")

	switch {
	case aslash && bslash:
		return a.Path + b.Path[1:], apath + bpath[1:]
	case !aslash && !bslash:
		return a.Path + "/" + b.Path, apath + "/" + bpath
	}
	return a.Path + b.Path, apath + bpath
}

func singleJoiningSlash(a, b string) string {
	aslash := strings.HasSuffix(a, "/")
	bslash := strings.HasPrefix(b, "/")
	switch {
	case aslash && bslash:
		return a + b[1:]
	case !aslash && !bslash:
		return a + "/" + b
	}
	return a + b
}
