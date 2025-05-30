package main

import (
	"context"
	"os"
	"strings"
	"time"

	"cloud.google.com/go/storage"
	"github.com/rs/zerolog/log"
	"google.golang.org/api/iterator"
	"google.golang.org/api/option"
)

func main() {
	ctx := context.Background()

	bucketName := os.Getenv("CLEANER_BUCKET_NAME")
	if bucketName == "" {
		log.Fatal().Msg("CLEANER_BUCKET_NAME not set")
	}

	// Delay before which files should be deleted
	expiration := time.Hour * 24

	client, err := storage.NewClient(ctx, option.WithEndpoint("http://10.0.2.2:9199/storage/v1/"))
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to create storage client")
	}
	defer client.Close()

	bkt := client.Bucket(bucketName)
	query := &storage.Query{}

	it := bkt.Objects(ctx, query)
	for {
		objAttrs, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Error().Err(err).Msg("Failed to list objects")
			break
		}

		// Skip folders
		if strings.HasSuffix(objAttrs.Name, "/") {
			continue
		}

		age := time.Since(objAttrs.Created)
		if age > expiration {
			log.Info().
				Str("object_name", objAttrs.Name).
				Dur("age", age).
				Msg("Deleting expired object")
			err := bkt.Object(objAttrs.Name).Delete(ctx)
			if err != nil {
				log.Error().Err(err).
					Str("object_name", objAttrs.Name).
					Msg("Failed to delete object")
			}
		}
	}
}
