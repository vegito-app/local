package main

import (
	"context"

	_ "github.com/7d4b9/utrade/backend/log"

	"github.com/7d4b9/utrade/backend/btc"
	"github.com/7d4b9/utrade/backend/internal/firebase"
	"github.com/7d4b9/utrade/backend/internal/http"
	v1 "github.com/7d4b9/utrade/backend/internal/http/api/v1"
	"github.com/7d4b9/utrade/backend/internal/vault"
	"github.com/7d4b9/utrade/backend/track"
	"github.com/rs/zerolog/log"
)

func main() {
	track.TrackUsage()
	firebaseClient, err := firebase.NewClient()
	if err != nil {
		log.Fatal().Err(err).Msg("new firebase app")
	}
	defer firebaseClient.Close()

	btcService := btc.NewBTC()
	defer btcService.Close()

	vaultClient, err := vault.NewClient(context.Background(), firebaseClient)
	if err != nil {
		log.Fatal().Err(err).Msg("new vault client")
	}

	s, err := v1.NewService(firebaseClient, btcService, vaultClient)
	if err != nil {
		log.Fatal().Err(err).Msg("create api services")
	}
	if err := http.StartAPI(s); err != nil {
		log.Fatal().Err(err).Msg("http start api")
	}
}
