ARG builder_image=docker-repository-public/utrade:builder
FROM ${builder_image}

COPY studio-entrypoint.sh /usr/local/bin/android-studio-docker-entrypoint.sh

ENTRYPOINT [ "android-studio-docker-entrypoint.sh" ]
CMD ["studio.sh"]
EXPOSE 5900