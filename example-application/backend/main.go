package main

import (
	_ "github.com/vegito-app/vegito/backend/log"

	"github.com/rs/zerolog/log"
	"github.com/vegito-app/vegito/backend/internal/firebase"
	"github.com/vegito-app/vegito/backend/internal/http"
	"github.com/vegito-app/vegito/backend/track"
)

func main() {
	track.TrackUsage()
	firebaseClient, err := firebase.NewClient()
	if err != nil {
		log.Fatal().Err(err).Msg("new firebase app")
	}
	defer firebaseClient.Close()
	if err := http.StartAPI(firebaseClient); err != nil {
		log.Fatal().Err(err).Msg("http start api")
	}
}
