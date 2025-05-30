package vegetable

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"

	"cloud.google.com/go/pubsub"
	apiV1 "github.com/7d4b9/utrade/backend/internal/http/api/v1"
	"github.com/7d4b9/utrade/images/vegetable"
	"github.com/rs/zerolog/log"
	"github.com/spf13/viper"
)

var config = viper.New()

const (
	gcloudProjectIDConfig                            = "gcloud_project_id"
	validatedImagesModeratorPubSubSubscriptionConfig = "validated_images_moderator_pubsub_subscription"
	createdImagesModeratorPubSubTopic                = "created_images_moderator_pubsub_topic"
)

func init() {
	config.AutomaticEnv()
	config.SetEnvPrefix("vegetable")
	config.BindEnv(gcloudProjectIDConfig, "GCLOUD_PROJECT_ID")
}

type Storage interface {
	UpdateVegetableImageURL(ctx context.Context, vegetableID, imageID, imageURL string) error
}

type VegetableClient struct {
	validatedImagesSubscriptionID string

	storage                    Storage
	exit                       func()
	pubSubClient               *pubsub.Client
	validateImagesPublishTopic *pubsub.Topic
}

func NewVegetableClient(storage Storage) (*VegetableClient, error) {
	gcloudProjectID := config.GetString(gcloudProjectIDConfig)
	pubSubClient, err := pubsub.NewClient(context.Background(), gcloudProjectID)
	if err != nil {
		return nil, fmt.Errorf("cannot create pubsub client: %w", err)
	}

	validateImagePublishTopic := config.GetString(createdImagesModeratorPubSubTopic)
	if validateImagePublishTopic == "" {
		return nil, fmt.Errorf("image moderator input topic not set in config: %s", createdImagesModeratorPubSubTopic)
	}

	validatedImagesTopicSubscription := config.GetString(validatedImagesModeratorPubSubSubscriptionConfig)
	if validatedImagesTopicSubscription == "" {
		return nil, fmt.Errorf("image moderator subscription not set in config: %s", validatedImagesModeratorPubSubSubscriptionConfig)
	}

	ctx, cancel := context.WithCancel(context.Background())

	validateImagesPublishTopic := pubSubClient.Topic(validateImagePublishTopic)

	v := &VegetableClient{
		pubSubClient:                  pubSubClient,
		storage:                       storage,
		validateImagesPublishTopic:    validateImagesPublishTopic,
		validatedImagesSubscriptionID: validatedImagesTopicSubscription,
		exit:                          cancel,
	}

	if err := v.receiveValidatedImages(ctx); err != nil {
		return nil, fmt.Errorf("failed to initialize vegetable client: %w", err)
	}

	log.Info().Str("image_moderator_input_topic", validateImagePublishTopic).Msg("Vegetable client running")

	return v, nil
}

func (v *VegetableClient) Close() {
	if v.exit != nil {
		v.exit()
	}
	v.exit = nil
	if v.pubSubClient != nil {
		if err := v.pubSubClient.Close(); err != nil {
			log.Error().Err(err).Msg("Failed to close pubsub client")
		}
	}
	v.pubSubClient = nil
	log.Info().Msg("Vegetable client closed")
}

func (v *VegetableClient) receiveValidatedImages(ctx context.Context) error {

	validatedImagesSub := v.pubSubClient.Subscription(v.validatedImagesSubscriptionID)

	validatedImagesSub.ReceiveSettings.MaxOutstandingMessages = 500
	validatedImagesSub.ReceiveSettings.NumGoroutines = 100

	err := validatedImagesSub.Receive(ctx, func(ctx context.Context, msg *pubsub.Message) {
		log.Printf("Received message: %s", string(msg.Data))
		var payload vegetable.VegetableValidatedImageMessage
		if err := json.Unmarshal(msg.Data, &payload); err != nil {
			log.Error().Err(err).Msg("Invalid message payload")
			msg.Nack()
			return
		}
		log.Debug().Str("vegetable_id", payload.VegetableID).Msg("Processing validated image")

		if err := v.storage.UpdateVegetableImageURL(ctx, payload.VegetableID, payload.ImageID, payload.ValidatedURL); err != nil {
			log.Error().Err(err).Msg("Failed to update vegetable image URL")
			msg.Nack()
			return
		}

		msg.Ack()
	})
	if err != nil {
		return fmt.Errorf("failed to create pubsub subscription: %w", err)
	}
	return nil
}

func (v *VegetableClient) SetImageValidation(ctx context.Context, vegetableID string, images []apiV1.VegetableImage) error {

	var wg sync.WaitGroup
	defer wg.Wait()
	wg.Add(len(images))
	for index, img := range images {
		go func(index int, img apiV1.VegetableImage) {
			defer wg.Done()

			msg := vegetable.VegetableCreatedImageMessage{
				VegetableID: vegetableID,
				ImageID:     fmt.Sprintf("%d", index),
				ImageURL:    img.URL,
			}

			payload, err := json.Marshal(msg)
			if err != nil {
				log.Error().Err(err).
					Fields(map[string]any{
						"vegetable_id": vegetableID,
						"image_id":     fmt.Sprintf("%d", index),
					}).
					Msg("failed to marshal message")
				return
			}

			res := v.validateImagesPublishTopic.Publish(ctx, &pubsub.Message{Data: payload})
			if _, err := res.Get(ctx); err != nil {
				log.Error().Err(err).
					Fields(map[string]any{
						"vegetable_id": vegetableID,
						"image_id":     fmt.Sprintf("%d", index),
					}).
					Msg("failed to publish image validation message")
				return
			}

			log.Debug().Fields(map[string]any{
				"vegetable_id": vegetableID,
				"image_id":     fmt.Sprintf("%d", index),
			}).Msg("Published image validation message")

		}(index, img)
	}

	return nil
}
