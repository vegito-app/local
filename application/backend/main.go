package main

import (
	"context"

	"github.com/7d4b9/utrade/backend/firebase"
	_ "github.com/7d4b9/utrade/backend/log"

	"github.com/7d4b9/utrade/backend/btc"
	"github.com/7d4b9/utrade/backend/internal/http"
	"github.com/7d4b9/utrade/backend/internal/http/api"
	"github.com/7d4b9/utrade/backend/internal/storage"
	"github.com/7d4b9/utrade/backend/internal/vault"
	"github.com/7d4b9/utrade/backend/track"
	"github.com/rs/zerolog/log"
)

func main() {
	track.TrackUsage()

	ctx := context.TODO()

	firebaseApp, err := firebase.NewApp(ctx)
	if err != nil {
		log.Fatal().Err(err).Msg("new firebase app")
	}

	storage, err := storage.NewStorage(firebaseApp)
	if err != nil {
		log.Fatal().Err(err).Msg("new storage")
	}
	defer storage.Close()

	vaultClient, err := vault.NewClient(ctx, storage)
	if err != nil {
		log.Fatal().Err(err).Msg("new vault client")
	}

	btcService := btc.NewBTC()
	defer btcService.Close()

	s, err := api.NewService(firebaseApp, storage, btcService, vaultClient)
	if err != nil {
		log.Fatal().Err(err).Msg("create api services")
	}
	if err := http.StartAPI(s); err != nil {
		log.Fatal().Err(err).Msg("http start api")
	}
}
