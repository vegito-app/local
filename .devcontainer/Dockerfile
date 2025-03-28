ARG builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest
FROM ${builder_image} AS build
# The workspace folder value '/workspaces/<project>' is enforced by Github Codespaces (see .devcontainer/devcontainer.json).
# It must be a static value due to limitations in the Devcontainer as it doesn't support variables and treats any syntax as a hard value without expansion.
# Luckily this restriction only applies to Github Codespaces. If another platform imposed the same restriction, we would face a complicated decision.
# Refer to https://containers.dev for more about the containers.dev initiative.

# To address this, we mimic the same workspace folder across different environments using a symlink hardcoded to '/workspaces/<project>'.
# This approach is beneficial when your environment needs to mount the current workspace in third-party containers, such as running a development docker-compose.

# Requiring alignment between the container mounted workspace folder path inside the container and outside,
# enables transparent work on the project files inside and outside of the development container, which can be destroyed and recreated with minimal impact and restart time.

# It further allows cache redirection inside the current folder located on docker daemon host physical disks (see .devcontainer/post-create-cmd.sh).
# It is superior to volumes as generated files stay within the local checked-out project folder, eliminating docker volume management and enabling access to locally readable container cache outside docker.

# When /var/run/docker.sock is mounted by docker daemon inside a running container (see docker-compose.yml) the host's docker is used.
# If you run the command 'docker run -v`pwd`:`pwd` -w `pwd` sh' it will display the current folder inside the container at the same virtual position where it currently resides, an existing path on the daemon underlying file system.

# Using this technique, you can safely mount files under your project path inside new containers like third party development containers with a local docker-compose.yml for local functional tests for instance.
ARG host_pwd
ARG github_project_name
RUN if [ "${host_pwd}" != "/workspaces/${github_project_name}" ]; then \
    sudo mkdir -p /workspaces && \
    sudo ln -sf ${host_pwd} /workspaces/${github_project_name} ; \
    fi