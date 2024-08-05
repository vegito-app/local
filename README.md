# CAR2GO

CAR2GO est fait pour proposer un service de déplacement par véhicule.

## Local

Start application locally:

```
make run
```

- Application is [available](http://localhost:8080) on `PORT` environement variable (default is 8080).

Puch CTRL+C or send os `SIGINT` signal to **graceful shutdown**.

### Build local image

Build local service image.

```
    make image-build
```

### Run local image

Run local service image.

```
    make image-run
```

### Push local image

Push local service image to the distant docker registry.

```
    make image-push
```

This operation may require to login to the project distant docker registry.

### Login to the project distant Docker registrty

```
 make docker-login
```
