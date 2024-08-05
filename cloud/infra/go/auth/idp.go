package auth

import (
	"encoding/json"
	"log"
	"net/http"
	"net/http/httputil"
)

func IdentityPaltformAuth(w http.ResponseWriter, r *http.Request) {
	requestDump, err := httputil.DumpRequest(r, true)
	if err != nil {
		log.Println(err)
	} else {
		log.Println(string(requestDump))
	}

	response := map[string]interface{}{
		"success": true,
		"message": "Authentication succeeded",
	}

	json.NewEncoder(w).Encode(response)
}
