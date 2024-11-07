ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/docker-repository-public/moov-438615:builder
FROM ${builder_image}

COPY studio-entrypoint.sh /usr/local/bin/android-studio-docker-entrypoint.sh

ENTRYPOINT [ "android-studio-docker-entrypoint.sh" ]
CMD ["studio.sh"]
EXPOSE 5900