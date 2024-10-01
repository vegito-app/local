# CAR2GO

CAR2GO est fait pour proposer un service de déplacement par véhicule.

## Local

Start application locally:

```
make run
```

- Application is [available](http://localhost:8080).

### Build local image

Build local project service images.

```
    make local-images
```

### Run local backend service image.

```
    make application-backend-docker-run
```

### Build and push multi-architecture project images.

```
    make images
```

This operation may require to login to the project distant docker registry.

### Login to the project distant Docker registrty

```
 make docker-login
```
