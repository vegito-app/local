package main

import (
	_ "github.com/7d4b9/utrade/backend/log"

	"github.com/7d4b9/utrade/backend/btc"
	"github.com/7d4b9/utrade/backend/internal/firebase"
	"github.com/7d4b9/utrade/backend/internal/http"
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

	vaultClient, err := vault.NewVaultClient()
	if err != nil {
		log.Fatal().Err(err).Msg("new vault client")
	}

	if err := http.StartAPI(firebaseClient, btcService, vaultClient); err != nil {
		log.Fatal().Err(err).Msg("http start api")
	}
}
