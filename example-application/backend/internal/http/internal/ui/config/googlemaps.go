package config

import (
	"net/http"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	"cloud.google.com/go/secretmanager/apiv1/secretmanagerpb"
	"github.com/rs/zerolog/log"
)

func GoogleMaps(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	// googlemapsAPIkey := config.GetString(googleMapsAPIkey)
	// if googlemapsAPIkey != "" {
	// 	_, err := w.Write([]byte(`{"apiKey": "` + googlemapsAPIkey + `"}`))
	// 	if err != nil {
	// 		log.Error().Err(err).Msg("write googlemaps local secrets response")
	// 	}
	// 	return
	// }
	client, err := secretmanager.NewClient(ctx)
	if err != nil {
		log.Error().Err(err).Msg("new googlemaps config secretmanager client")
		return
	}
	defer func() {
		err = client.Close()
		if err != nil {
			log.Error().Err(err).Msg("close googlemaps secretmanager client")
			return
		}
	}()
	secretID := config.GetString(googlemapsSecretIDConfig)
	secretVersionRequest := &secretmanagerpb.AccessSecretVersionRequest{
		Name: secretID,
	}
	secretVersion, err := client.AccessSecretVersion(ctx, secretVersionRequest)
	if err != nil {
		log.Error().Err(err).Msg("close googlemaps secretmanager client")
		return
	}
	secret := secretVersion.GetPayload()
	if secret == nil {
		log.Error().Err(err).Msg("googlemaps config get payload from secret version")
		return
	}
	googleMapsconfig := secret.Data
	_, err = w.Write(googleMapsconfig)
	if err != nil {
		log.Error().Err(err).Msg("write googlemaps secrets response")
		return
	}
}
