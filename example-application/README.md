### Application

#### application-backend

The _application-backend_ serves an _application-frontend_ web react application.

Start _application-backend_:

```
make application-backend-run
```

Build _application-backend_ image:

```
make application-backend-image
```

Run _application-backend_ docker-compose service container from the _application-backend-image_.

```
make application-backend-docker-compose-run
```

Some other companion Makefile targets in familly `application-backend-*` are also available, see [application/backend/backend.mk](application/backend/backend.mk) for details.

    application-backend-docker-compose-logs
    application-backend-docker-compose-rm
    application-backend-docker-compose-run
    application-backend-docker-compose-stop
    application-backend-docker-compose-up
    application-backend-docker-compose-rm
    application-backend-image
    application-backend-image-push
    application-backend-image-push-ci
    application-backend-install
    application-backend-run

#### application-frontend

As mentionned above the _application-frontend_ web react app is served by the _application-backend_ server.

Application is available at:

- http://localhost:8080](http://localhost:8080) for the standard react application.
- or http://localhost:8080/ui](http://localhost:8080/ui) for the server-side pre-rendered react application.

Some othe companion Makefile targets in familly `application-frontend-*` are available, see [example-application/frontend/frontend.mk](example-application/frontend/frontend.mk) for details.

    application-frontend-build   
    application-frontend-bundle  
    application-frontend-npm-ci  
    application-frontend-start

#### application-mobile

A mobile cross platform *iOS* and *Android* _mobile-application_ using [Flutter](https://flutter.dev) is also available.

See [application/mobile/flutter.mk](application/mobile) folder for more details about the available `application-mobile-*` targets.

As an example, get _application-mobile_ Flutter dependancies with:

```bash
$ make application-mobile-flutter-pub-get
````


    
        
