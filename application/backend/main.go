package main

import (
	"context"

	_ "github.com/7d4b9/utrade/backend/log"

	"github.com/7d4b9/utrade/backend/btc"
	"github.com/7d4b9/utrade/backend/internal/http"
	v1 "github.com/7d4b9/utrade/backend/internal/http/api/v1"
	"github.com/7d4b9/utrade/backend/internal/storage"
	"github.com/7d4b9/utrade/backend/internal/vault"
	"github.com/7d4b9/utrade/backend/track"
	"github.com/rs/zerolog/log"
)

func main() {
	track.TrackUsage()
	storage, err := storage.NewStorage()
	if err != nil {
		log.Fatal().Err(err).Msg("new firebase app")
	}
	defer storage.Close()

	vaultClient, err := vault.NewClient(context.Background(), storage)
	if err != nil {
		log.Fatal().Err(err).Msg("new vault client")
	}

	btcService := btc.NewBTC()
	defer btcService.Close()

	s, err := v1.NewService(storage, btcService, vaultClient)
	if err != nil {
		log.Fatal().Err(err).Msg("create api services")
	}
	if err := http.StartAPI(s); err != nil {
		log.Fatal().Err(err).Msg("http start api")
	}
}
