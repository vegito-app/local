package main

import (
	"context"
	"encoding/json"
	"fmt"

	"cloud.google.com/go/pubsub"
	"cloud.google.com/go/storage"
	vision "cloud.google.com/go/vision/apiv1"
	"github.com/7d4b9/utrade/images/vegetable"
	"github.com/rs/zerolog/log"
	"github.com/spf13/viper"
	pb "google.golang.org/genproto/googleapis/cloud/vision/v1"
)

const (
	// PubSubSubscriptionInputConfig is the subscription for the input topic
	PubSubSubscriptionInputConfig = "pubsub_subscription"
	// PubSubTopicInputConfig is the input topic for vegetable creation messages
	PubSubTopicInputConfig = "pubsub_topic_input"
	// PubSubTopicOutputConfig is the output topic for validated vegetable images
	PubSubTopicOutputConfig = "pubsub_topic_output"
	// validatedOutputBucketConfig is the bucket where validated images are stored
	validatedOutputBucketConfig = "validated_output_bucket"
	// createdInputBucketConfig is the bucket where images are uploaded from Firebase
	createdInputBucketConfig = "created_input_bucket"

	gcloudProjectIDConfig = "gcloud_project_id"
)

var config = viper.New()

func init() {
	config.AutomaticEnv() // Automatically read environment variables
	config.SetEnvPrefix("application_images_moderator")
	config.BindEnv(gcloudProjectIDConfig, "GCLOUD_PROJECT_ID")

}

// main is the entry point for the application
func main() {
	ctx := context.Background()

	projectID := config.GetString(gcloudProjectIDConfig)
	if projectID == "" {
		log.Fatal().Msg("GCLOUD_PROJECT_ID not set")
	}

	topicID := config.GetString(PubSubTopicInputConfig)
	if topicID == "" {
		log.Fatal().Msg("APPLICATION_IMAGES_MODERATOR_PUBSUB_TOPIC_INPUT not set")
	}
	subID := config.GetString(PubSubSubscriptionInputConfig)
	if subID == "" {
		log.Fatal().Msg("APPLICATION_IMAGES_MODERATOR_PUBSUB_SUBSCRIPTION_INPUT not set")
	}

	topicOut := config.GetString(PubSubTopicOutputConfig)
	if topicOut == "" {
		log.Fatal().Msg("PUBSUB_TOPIC_OUTPUT not set")
	}

	permanentBucket := config.GetString(validatedOutputBucketConfig)
	if permanentBucket == "" {
		log.Fatal().Msg("APPLICATION_IMAGES_MODERATOR_VALIDATED_OUTPUT_BUCKET not set")
	}

	firebaseUploadBucket := config.GetString(createdInputBucketConfig)
	if firebaseUploadBucket == "" {
		log.Fatal().Msg("APPLICATION_IMAGES_MODERATOR_INPUT_STORAGE_BUCKET not set")
	}

	clientImageAnnotator, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create image annotator client")
	}
	defer clientImageAnnotator.Close()

	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create pubsub client")
	}
	defer client.Close()

	sub := client.Subscription(subID)

	sub.ReceiveSettings.MaxOutstandingMessages = 500
	sub.ReceiveSettings.NumGoroutines = 100

	err = sub.Receive(ctx, func(ctx context.Context, msg *pubsub.Message) {
		log.Debug().
			Str("message_data", string(msg.Data)).
			Msg("Received message")

		var payload vegetable.VegetableCreatedImageMessage
		if err := json.Unmarshal(msg.Data, &payload); err != nil {
			log.Error().Err(err).
				Str("vegetable_id", payload.VegetableID).
				Msg("Invalid message payload")
			msg.Nack()
			return
		}

		if err := moderateVegetable(ctx, client, payload.ImageURL, payload.VegetableID, payload.ImageIndex, topicOut, permanentBucket, firebaseUploadBucket); err != nil {
			log.Error().Err(err).
				Str("vegetable_id", payload.VegetableID).
				Msg("Moderation failed")
			msg.Nack()
			return
		}

		msg.Ack()
	})

	if err != nil {
		log.Fatal().Err(err).Msg("Receive returned error")
	}
}

func moderateVegetable(ctx context.Context, client *pubsub.Client, imageUrl string, vegetableID string, imageIndex int, topicOut string, validatedBucket string, firebaseBucket string) error {
	img := vision.NewImageFromURI(imageUrl)
	if img == nil {
		return fmt.Errorf("failed to create image from URI for %s", vegetableID)
	}

	clientImageAnnotator, err := vision.NewImageAnnotatorClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to create image annotator client: %w", err)
	}
	defer clientImageAnnotator.Close()

	// SafeSearch detection (existant)
	annotations, err := clientImageAnnotator.DetectSafeSearch(ctx, img, nil)
	if err != nil {
		return fmt.Errorf("failed to perform SafeSearch detection: %w", err)
	}
	if annotations == nil {
		return fmt.Errorf("no SafeSearch annotations found for image %s", vegetableID)
	}

	// Vérifie le contenu SafeSearch
	if annotations.Adult != pb.Likelihood_VERY_UNLIKELY ||
		annotations.Medical != pb.Likelihood_VERY_UNLIKELY ||
		annotations.Violence != pb.Likelihood_VERY_UNLIKELY ||
		annotations.Racy != pb.Likelihood_VERY_UNLIKELY {
		storageClient, err := storage.NewClient(ctx)
		if err != nil {
			return fmt.Errorf("failed to create storage client: %w", err)
		}
		defer storageClient.Close()

		srcBucket := storageClient.Bucket(firebaseBucket)
		path := fmt.Sprintf("vegetables/%s/%d.jpg", vegetableID, imageIndex)
		src := srcBucket.Object(path)
		if err := src.Delete(ctx); err != nil {
			log.Error().Err(err).Str("vegetable_id", vegetableID).Msg("Failed to delete unsafe image")
		} else {
			log.Info().Str("vegetable_id", vegetableID).Msg("Unsafe image deleted successfully")
		}

		return fmt.Errorf("image %s contains unsafe content", vegetableID)
	}

	// Copie dans bucket validé (existant)
	storageClient, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to create storage client: %w", err)
	}
	defer storageClient.Close()

	srcBucket := storageClient.Bucket(firebaseBucket)
	dstBucket := storageClient.Bucket(validatedBucket)

	path := fmt.Sprintf("vegetables/%s/%d.jpg", vegetableID, imageIndex)

	src := srcBucket.Object(path)
	dst := dstBucket.Object(path)

	_, err = dst.CopierFrom(src).Run(ctx)
	if err != nil {
		return fmt.Errorf("failed to copy image to permanent bucket: %w", err)
	}

	if err := src.Delete(ctx); err != nil {
		return fmt.Errorf("failed to delete original image: %w", err)
	}

	// --- Nouvelle partie : détection des labels ---
	labels, err := clientImageAnnotator.DetectLabels(ctx, img, nil, 10)
	if err != nil {
		return fmt.Errorf("failed to perform Label detection: %w", err)
	}

	// Construction d'une structure simple pour la sérialisation JSON
	type LabelData struct {
		Description string  `json:"description"`
		Score       float32 `json:"score"`
	}

	var labelData []LabelData
	for _, label := range labels {
		labelData = append(labelData, LabelData{
			Description: label.Description,
			Score:       label.Score,
		})
	}

	// Message JSON enrichi envoyé sur le topic de sortie
	messageData, err := json.Marshal(map[string]interface{}{
		"vegetableId": vegetableID,
		"imageIndex":  imageIndex,
		"imageUrl":    fmt.Sprintf("gs://%s/%s", validatedBucket, path),
		"labels":      labelData,
	})
	if err != nil {
		return fmt.Errorf("failed to marshal output message: %w", err)
	}

	pub := client.Topic(topicOut)
	result := pub.Publish(ctx, &pubsub.Message{
		Data: messageData,
	})
	if _, err := result.Get(ctx); err != nil {
		return fmt.Errorf("failed to publish validated image message: %w", err)
	}

	log.Printf("Moderated vegetable %s and published labels", vegetableID)
	return nil
}
