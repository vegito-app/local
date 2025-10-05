package auth

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"strings"

	"github.com/rs/zerolog/log"
	"github.com/vegito-app/vegito/infra/google-cloud/auth/firebase"

	_ "github.com/GoogleCloudPlatform/functions-framework-go/funcframework"
	"github.com/rs/zerolog"
)

func init() {
	// UNIX Time is faster and smaller than most timestamps
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
}

type App struct {
	*firebase.App
}

type RequestBody struct {
	Data struct {
		Jwt string `json:"jwt"`
	} `json:"data"`
}

func InternalServerError(w http.ResponseWriter, msg string, err error) {
	// Chaîne de caractères source
	charSet := "abcdef123456"
	// Longueur souhaitée pour l'identifiant
	length := 8
	errorID := make([]byte, length)
	for i := range errorID {
		// Générer un index aléatoire pour charSet
		errorID[i] = charSet[rand.Intn(len(charSet))]
	}
	log.Error().Err(err).
		Bytes("error_id", errorID).
		Msg(msg)
	http.Error(w, string(errorID)+": "+msg, http.StatusInternalServerError)
}

func IDPbeforeSignIn(w http.ResponseWriter, r *http.Request) {
	debug(r)
	if err := json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Authentication succeeded",
	}); err != nil {
		InternalServerError(w, "json encode success HTTP response", err)
		return
	}
}

// Valider les informations de l'utilisateur
// ...
// Créer un nouvel utilisateur dans la base de données
// ...
func IDPbeforeCreate(w http.ResponseWriter, r *http.Request) {
	debug(r)
	ctx := r.Context()
	firebaseAdminApp, err := firebase.NewApp(ctx)
	if err != nil {
		InternalServerError(w, "new firebase admin app", err)
		return
	}
	authClient, err := firebaseAdminApp.Auth(ctx)
	if err != nil {
		InternalServerError(w, "new authenticated client", err)
		return
	}
	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Can't read body", http.StatusBadRequest)
		return
	}
	var requestBody RequestBody
	err = json.Unmarshal(bodyBytes, &requestBody)
	if err != nil {
		http.Error(w, "Can't decode json", http.StatusBadRequest)
		return
	}
	idToken := requestBody.Data.Jwt
	token, err := authClient.VerifyIDToken(ctx, idToken)
	if err != nil {
		InternalServerError(w, "verifying ID token", err)
		return
	}
	b, err := json.Marshal(token.Claims)
	if err != nil {
		InternalServerError(w, "token claims json", err)
		return
	}
	log.Info().Bytes("json", b).Msg("token claims")
	fs, err := firebaseAdminApp.Firestore(ctx)
	if err != nil {
		InternalServerError(w, "new database client", err)
		return
	}
	user, err := authClient.GetUser(ctx, token.UID)
	if err != nil {
		InternalServerError(w, "get authenticated user", err)
		return
	}
	// Ici, vous pouvez persister les informations de l'utilisateur comme vous le souhaitez.
	userWriteResult, err := fs.Collection("users").Doc(token.UID).Set(ctx, map[string]any{
		"email":       user.Email,
		"displayName": user.DisplayName,
		"photo_url":   user.PhotoURL,
	})
	if err != nil {
		InternalServerError(w, "create authenticated user in database", err)
		return
	}
	if err := json.NewEncoder(w).Encode(map[string]interface{}{
		"success":          true,
		"message":          "Authentication succeeded",
		"user_update_time": userWriteResult.UpdateTime,
	}); err != nil {
		InternalServerError(w, "json encode success HTTP response", err)
		return
	}
}

func debug(r *http.Request) {
	log.Info().Str("URL", r.URL.String())
	log.Info().Str("Method", r.Method)
	var printHeaders []string
	for name, headers := range r.Header {
		name = strings.ToLower(name)
		for _, h := range headers {
			printHeaders = append(printHeaders, fmt.Sprintf("%v: %v\n", name, h))
		}
	}
	log.Info().Strs("headers", printHeaders).Msg("Head")
	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		log.Error().Err(err).Msg("read body")
		return
	}
	// Rétablir le body pour qu'il soit utilisable par la suite
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
	// Afficher le corps de manière formatée pour un meilleur débogage
	var prettyJSON bytes.Buffer
	error := json.Indent(&prettyJSON, bodyBytes, "", "\t")
	if error != nil {
		log.Error().Err(err).Msg("JSON parse")
		return
	}
	log.Info().
		Str("Request Body", prettyJSON.String()).
		Msg("dumb content")
}
