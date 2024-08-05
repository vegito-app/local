#!/bin/bash

export REACT_APP_GOOGLE_MAPS_API_KEY=$(sudo cat /run/secrets/google_maps_api_key)
make frontend-build frontend-bundle 