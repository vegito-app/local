package main

import (
	"log"

	"github.com/7d4b9/utrade/backend/internal/firebase"
	"github.com/7d4b9/utrade/backend/internal/http"
	"github.com/7d4b9/utrade/backend/track"
)

func main() {
	track.TrackUsage()

	firebaseClient, err := firebase.NewClient()
	if err != nil {
		log.Fatalln("new firebase app:", err.Error())
	}
	defer firebaseClient.Close()

	if err := http.StartAPI(firebaseClient); err != nil {
		log.Fatalln("http start api:", err.Error())
	}
}
