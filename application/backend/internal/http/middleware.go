package http

import "net/http"

// Type middleware : une fonction qui prend un http.Handler et retourne un http.Handler
type Middleware func(http.Handler) http.Handler

// Fonction qui enchaîne les middlewares sur un handler final
func ApplyMiddleware(handler http.Handler, middlewares ...Middleware) http.Handler {
	// On les applique dans l'ordre inverse pour respecter l'ordre d'exécution naturel
	for i := len(middlewares) - 1; i >= 0; i-- {
		handler = middlewares[i](handler)
	}
	
	return handler
}
