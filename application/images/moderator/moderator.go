package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"

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
	PubSubSubscriptionInputConfig = "application_images_moderator_pubsub_subscription"
	// PubSubTopicInputConfig is the input topic for vegetable creation messages
	PubSubTopicInputConfig = "application_images_moderator_pubsub_topic_input"
	// PubSubTopicOutputConfig is the output topic for validated vegetable images
	PubSubTopicOutputConfig = "application_images_moderator_pubsub_topic_output"
	// validatedOutputBucketConfig is the bucket where validated images are stored
	validatedOutputBucketConfig = "application_images_moderator_validated_output_bucket"
	// firebaseUploadBucketConfig is the bucket where images are uploaded from Firebase
	firebaseUploadBucketConfig = "application_images_moderator_input_firebase_bucket"
)

var config = viper.New()

func init() {
	config.SetConfigName("config")
	config.SetConfigType("yaml")
	config.AddConfigPath(".")
	if err := config.ReadInConfig(); err != nil {
		log.Fatal().Err(err).Msg("Failed to read config file")
	}
	config.AutomaticEnv() // Automatically read environment variables
	config.SetEnvPrefix("application_images_moderator")
	viper.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))

}

// main is the entry point for the application
func main() {
	ctx := context.Background()

	projectID := os.Getenv("GCP_PROJECT_ID")
	if projectID == "" {
		log.Fatal().Msg("GCP_PROJECT_ID not set")
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

	firebaseUploadBucket := config.GetString(firebaseUploadBucketConfig)
	if firebaseUploadBucket == "" {
		log.Fatal().Msg("APPLICATION_IMAGES_MODERATOR_INPUT_FIREBASE_BUCKET not set")
	}

	clientImageAnnotator, err := vision.NewImageAnnotatorClient(ctx)
	defer clientImageAnnotator.Close()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create image annotator client")
	}

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

		if err := moderateVegetable(ctx, client, payload.ImageURL, payload.VegetableID, payload.ImageID, topicOut, permanentBucket, firebaseUploadBucket); err != nil {
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

func moderateVegetable(ctx context.Context, client *pubsub.Client, imageUrl string, vegetableID string, imageID string, topicOut string, validatedBucket string, firebaseBucket string) error {
	img := vision.NewImageFromURI(imageUrl)
	if img == nil {
		return fmt.Errorf("Failed to create image from URI for %s", vegetableID)
	}
	clientImageAnnotator, err := vision.NewImageAnnotatorClient(ctx)
	defer clientImageAnnotator.Close()
	if err != nil {
		return fmt.Errorf("Failed to create image annotator client: %w", err)
	}
	// Perform SafeSearch detection
	annotations, err := clientImageAnnotator.DetectSafeSearch(ctx, img, nil)
	if err != nil {
		return fmt.Errorf("Failed to perform SafeSearch detection: %w", err)
	}
	if annotations == nil {
		return fmt.Errorf("No SafeSearch annotations found for image %s", vegetableID)
	}
	// Check for unsafe content
	if annotations.Adult == pb.Likelihood_VERY_UNLIKELY &&
		annotations.Medical == pb.Likelihood_VERY_UNLIKELY &&
		annotations.Violence == pb.Likelihood_VERY_UNLIKELY &&
		annotations.Racy == pb.Likelihood_VERY_UNLIKELY {
		log.Debug().Str("vegetable_id", vegetableID).Msg("Image is safe")
	} else {
		storageClient, err := storage.NewClient(ctx)
		if err != nil {
			return fmt.Errorf("failed to create storage client: %w", err)
		}
		defer storageClient.Close()

		srcBucket := storageClient.Bucket(firebaseBucket)
		path := fmt.Sprintf("vegetables/%s/%s.jpg", vegetableID, imageID)
		src := srcBucket.Object(path)
		if err := src.Delete(ctx); err != nil {
			log.Error().Err(err).Str("vegetable_id", vegetableID).Msg("Failed to delete unsafe image")
		} else {
			log.Info().Str("vegetable_id", vegetableID).Msg("Unsafe image deleted successfully")
		}

		return fmt.Errorf("Image %s contains unsafe content", vegetableID)
	}

	storageClient, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to create storage client: %w", err)
	}
	defer storageClient.Close()

	srcBucket := storageClient.Bucket(firebaseBucket)
	dstBucket := storageClient.Bucket(validatedBucket)

	path := fmt.Sprintf("vegetables/%s/%s.jpg", vegetableID, imageID)

	src := srcBucket.Object(path)
	dst := dstBucket.Object(path)

	_, err = dst.CopierFrom(src).Run(ctx)
	if err != nil {
		return fmt.Errorf("failed to copy image to permanent bucket: %w", err)
	}

	if err := src.Delete(ctx); err != nil {
		return fmt.Errorf("failed to delete original image: %w", err)
	}

	pub := client.Topic(topicOut)
	result := pub.Publish(ctx, &pubsub.Message{
		Data: []byte(fmt.Sprintf(`{"vegetableId":"%s","imageId":"%s","validatedUrl":"gs://%s/%s"}`, vegetableID, imageID, validatedBucket, path)),
	})
	if _, err := result.Get(ctx); err != nil {
		return fmt.Errorf("failed to publish validated image message: %w", err)
	}

	log.Printf("Moderating vegetable %s", vegetableID)
	time.Sleep(1 * time.Second) // simulate work
	return nil
}
