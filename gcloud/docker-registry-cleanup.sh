PROJECT=moov-dev-439608
REGION=europe-west1
REPO=docker-repository-private

gcloud artifacts docker images list \
  ${REGION}-docker.pkg.dev/${PROJECT}/${REPO} \
  --include-tags \
  --format=json |
jq -r '.[] | @base64' |
while read row; do
  obj=$(echo "$row" | base64 -d)

  image=$(echo "$obj" | jq -r '.package')
  version=$(echo "$obj" | jq -r '.version')

  tags=$(echo "$obj" | jq -r '.tags[]?' 2>/dev/null)

  keep=false
  for tag in $tags; do
    if [[ "$tag" == *latest || "$tag" == *current ]]; then
      keep=true
    fi
  done

  if [ "$keep" = false ]; then
    echo "DELETE $image@$version"
    gcloud artifacts docker images delete "$image@$version" \
      --quiet --delete-tags
  fi
done