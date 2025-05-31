package http

import (
	"context"
	"net/http"
	"time"
)

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

func AuditMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requestTime := r.Context().Value("requestTime")
		if requestTime == nil {
			// Si le contexte ne contient pas de valeur pour "requestTime", on peut définir une valeur par défaut
			requestTime = r.Context().Value("requestUnixTime")
		}
		// On peut aussi vérifier si requestTime est de type time.Time ou int64 selon le contexte
		if t, ok := requestTime.(time.Time); ok {
			// Si c'est un time.Time, on peut l'utiliser directement
			r = r.WithContext(context.WithValue(r.Context(), "requestTime", t.Unix()))
		} else if t, ok := requestTime.(int64); ok {
			// Si c'est un int64, on peut l'utiliser directement
			r = r.WithContext(context.WithValue(r.Context(), "requestTime", t))
		} else {
			// Si ce n'est ni l'un ni l'autre, on peut définir une valeur par défaut
			r = r.WithContext(context.WithValue(r.Context(), "requestTime", time.Now().Unix()))
		}
		// Logique d'audit ici, par exemple enregistrer l'URL et la méthode
		// log.Printf("Request: %s %s", r.Method, r.URL.Path)

		// Appel du handler suivant
		next.ServeHTTP(w, r)
	})
}
