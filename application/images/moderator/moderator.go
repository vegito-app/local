package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"cloud.google.com/go/pubsub"
	"cloud.google.com/go/storage"
	vision "cloud.google.com/go/vision/apiv1"
	"github.com/7d4b9/utrade/images/vegetable"
	"github.com/rs/zerolog"
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
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stdout, TimeFormat: time.RFC3339})

	log.Info().Msg("Starting application images moderator...")

	rootCtx, rootCancel := context.WithCancel(context.Background())
	defer rootCancel()

	sgn := make(chan os.Signal, 1)
	defer close(sgn)

	signal.Notify(sgn, os.Interrupt, syscall.SIGTERM)
	go func() {
		select {
		case <-rootCtx.Done():
			log.Info().Msg("Received root context cancellation, exiting...")
			return
		case <-sgn:
			log.Info().Msg("Received shutdown signal, exiting...")
			rootCancel()
			return
		}
	}()

	// Initialize the application
	initctx, initCancel := context.WithTimeout(rootCtx, 10*time.Second)
	defer initCancel()

	app, err := NewApp(initctx)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create application")
	}
	defer app.Close()

	if err := app.ReceiveCreatedVegetableImages(rootCtx); err != nil {
		log.Error().Err(err).Msg("Failed to receive messages from Pub/Sub subscription")
	}
}

type App struct {
	ProjectID                string
	TopicID                  string
	SubID                    string
	TopicOut                 string
	PermaBucket              string
	FirebaseUploadBucket     string
	ClientImageAnnotator     *vision.ImageAnnotatorClient
	PubClient                *pubsub.Client
	CreatedVegetableImageSub *pubsub.Subscription
	SrcBucket                *storage.BucketHandle
	DstBucket                *storage.BucketHandle
}

func (a *App) Close() {
	if a.ClientImageAnnotator != nil {
		a.ClientImageAnnotator.Close()
	}
	if a.PubClient != nil {
		a.PubClient.Close()
	}
}

func NewApp(ctx context.Context) (*App, error) {

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

	// Copie dans bucket validé (existant)
	storageClient, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create storage client")
	}
	defer storageClient.Close()

	srcBucket := storageClient.Bucket(firebaseUploadBucket)
	dstBucket := storageClient.Bucket(permanentBucket)

	app := &App{
		ProjectID:                projectID,
		TopicID:                  topicID,
		SubID:                    subID,
		TopicOut:                 topicOut,
		PermaBucket:              permanentBucket,
		FirebaseUploadBucket:     firebaseUploadBucket,
		ClientImageAnnotator:     clientImageAnnotator,
		PubClient:                client,
		CreatedVegetableImageSub: sub,
		SrcBucket:                srcBucket,
		DstBucket:                dstBucket,
	}

	// SafeSearch detection (existant)
	return app, nil
}

func (a *App) ReceiveCreatedVegetableImages(ctx context.Context) error {
	return a.CreatedVegetableImageSub.Receive(ctx, func(ctx context.Context, msg *pubsub.Message) {
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
		// Chemin complet relatif
		path := fmt.Sprintf("vegetables/%s/%d.jpg", payload.VegetableID, payload.ImageIndex)

		dstObject := a.DstBucket.Object(path)

		// Vérifie si le fichier existe déjà dans le bucket validé
		_, err := dstObject.Attrs(ctx)
		if err == nil {
			log.Debug().Str("vegetable_id", payload.VegetableID).Int("image_index", payload.ImageIndex).Msg("Image already validated, skipping moderation.")
			msg.Ack()
			return
		}
		if err != storage.ErrObjectNotExist {
			log.Error().Err(err).Msg("Failed to check validated bucket")
			msg.Nack()
			return
		}
		if err := a.moderateVegetableImage(ctx, payload.ImagePath, payload.VegetableID, payload.ImageIndex); err != nil {
			log.Error().Err(err).
				Str("vegetable_id", payload.VegetableID).
				Msg("Moderation failed")
			msg.Nack()
			return
		}

		msg.Ack()
	})

}

func (a *App) moderateVegetableImage(ctx context.Context, imagePath string, vegetableID string, imageIndex int) error {
	img := vision.NewImageFromURI(imagePath)
	if img == nil {
		return fmt.Errorf("failed to create image from URI for %s", vegetableID)
	}

	annotations, err := a.ClientImageAnnotator.DetectSafeSearch(ctx, img, nil)
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

		path := fmt.Sprintf("vegetables/%s/%d.jpg", vegetableID, imageIndex)
		src := a.SrcBucket.Object(path)
		if err := src.Delete(ctx); err != nil {
			log.Error().Err(err).Str("vegetable_id", vegetableID).Msg("Failed to delete unsafe image")
		} else {
			log.Info().Str("vegetable_id", vegetableID).Msg("Unsafe image deleted successfully")
		}

		return fmt.Errorf("image %s contains unsafe content", vegetableID)
	}

	path := imagePath

	src := a.SrcBucket.Object(path)
	dst := a.DstBucket.Object(path)

	_, err = dst.CopierFrom(src).Run(ctx)
	if err != nil {
		return fmt.Errorf("failed to copy image to permanent bucket: %w", err)
	}

	if err := src.Delete(ctx); err != nil {
		return fmt.Errorf("failed to delete original image: %w", err)
	}

	// --- Nouvelle partie : détection des labels ---
	labels, err := a.ClientImageAnnotator.DetectLabels(ctx, img, nil, 10)
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
		"imagePath":   imagePath,
		"labels":      labelData,
	})
	if err != nil {
		return fmt.Errorf("failed to marshal output message: %w", err)
	}

	pub := a.PubClient.Topic(a.TopicOut)
	result := pub.Publish(ctx, &pubsub.Message{
		Data: messageData,
	})
	if _, err := result.Get(ctx); err != nil {
		return fmt.Errorf("failed to publish validated image message: %w", err)
	}

	log.Printf("Moderated vegetable %s and published labels", vegetableID)
	return nil
}
