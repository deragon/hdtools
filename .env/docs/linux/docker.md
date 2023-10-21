# COMMON COMMANDS

    docker ps # List all containers running.

    docker images --all # List all images available locally.
    # Same command as above, but with Created date shown as exact date.
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"

    # Delete all dangling images.  From:  https://stackoverflow.com/questions/33913020/docker-remove-none-tag-images
    # docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

    docker run ${IMAGE}  # Create a container from image.

    DOCKER_CONTAINER_ID="$(docker container ps --format "{{.ID}}" | head -1)"; echo "${DOCKER_CONTAINER_ID}"

    docker container start   "${DOCKER_CONTAINER_ID}" # Start an already existing container.
    docker container restart "${DOCKER_CONTAINER_ID}"
    docker container stop    "${DOCKER_CONTAINER_ID}"

    docker container ps --all --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Size}}\t{{.Status}}" # List running and idle containers in table format.

    docker exec -it "${DOCKER_CONTAINER_ID}" bash   # Start bash session in container.
    docker exec -it "${DOCKER_CONTAINER_ID}" --user <user> bash   # Start bash session as <user>
    docker exec -it "${DOCKER_CONTAINER_ID}" --user 0 bash   # Start bash session as root.
    docker inspect "${DOCKER_CONTAINER_ID}" | less # Safe.  Prints out details.

    docker info # Shows all sort of info about the docker eco-system on the host.

    docker logs -f "${DOCKER_CONTAINER_ID}" # Equivalent of a tail, but it scrolls from the beginning


    # Enable / Disable docker container at host bootup.
    docker update --restart=unless-stopped "${DOCKER_CONTAINER_ID}" # Enable autostart at host boot, but only if not stopped manually.
    docker update --restart=always         "${DOCKER_CONTAINER_ID}" # Enable autostart at host boot.
    docker update --restart=no             "${DOCKER_CONTAINER_ID}" # Disable autostart at host boot.


    # Formated outputs.  See:  https://docs.docker.com/engine/reference/commandline/ps/#formatting
    docker ps --all --format 'table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Names}}\t{{.Labels}}'



# CREATION

  Interesting base images:

  - Centos:  https://hub.docker.com/_/centos
      docker pull centos:7.5.1804 # Download to get the image locally.

  - Ubuntu:  https://hub.docker.com/_/ubuntu
      docker pull ubuntu:22.04



# DOCKER IMAGE VS CONTAINER

  https://phoenixnap.com/kb/docker-image-vs-container



# DIFFERENCE BETWEEN A REGISTRY, REPOSITORY AND IMAGE

  You could say a registry has many repositories and a repository has many
  different versions of the same image which are individually versioned with
  tags.

  From:  https://nickjanetakis.com/blog/docker-tip-53-difference-between-a-registry-repository-and-image

  A Docker repository is where you can store 1 or more versions of a specific
  Docker image. An image can have 1 or more versions (tags).  A Docker image
  can be compared to a git repo. A git repo can be hosted inside of a GitHub
  repository, but it could also be hosted on Gitlab, BitBucket or your own git
  repo hosting service. It could also sit on your development box and not be
  hosted anywhere.

  The same goes for a Docker image. You can choose to not push it anywhere,
  but you could also push it to the Docker Hub which is both a public and
  private service for hosting Docker repositories. There are other third party
  repository hosting services too.

  The thing to remember here is a Docker repository is a place for you to
  publish and access your Docker images. Just like GitHub is a place for you
  to publish and access your git repos.

  It’s also worth pointing out that the Docker Hub and other third party
  repository hosting services are called “registries”. A registry stores a
  collection of repositories.



# INSTALL DOCKER

## UBUNTU (INCLUDING WSL 2)

  Read:  https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

  Once installed, on WSL 2, the service must be started.  As of
  2022-01-24, systemd is still not supported on WSL 2.  You must start it with:

    sudo service docker start   # Safe
    sudo service docker restart # Safe

  To test if the installation was successful, run:

    sudo docker run hello-world # Safe

## RED HAT / RHEL

  From:  https://stackoverflow.com/questions/65878769/cannot-install-docker-in-a-rhel-server

  Add an entry on top of the file `/etc/yum.repos.d/docker-ce.repo`, with this
  content (although it states `centos`, it works for RHEL too):

    [centos-extras]
    name=Centos extras - $basearch
    baseurl=http://mirror.centos.org/centos/7/extras/x86_64
    enabled=1
    gpgcheck=1
    gpgkey=http://centos.org/keys/RPM-GPG-KEY-CentOS-7

  Then the installation command:

    yum -y install slirp4netns fuse-overlayfs container-selinux



# VOLUMES AND DATA

    docker volume ls  # SAFE.  List all volumes on host.
    docker inspect -f '{{ .Mounts }}' "${DOCKER_CONTAINER_ID}"
    docker inspect "${DOCKER_CONTAINER_ID}" | less


## IMPORTANT NOTES

  - Volumes in dockers should have been called mount points.  They are moint
    points allowing docker containers to access directories and files of the
    host.

  - Volumes are a bit if a misnowmer.  Usually when VMs talks about volumes,
    it is a storage sytem that contains the root file system within the VM.
    In docker, it is not the case.


## Root

  Root directories of containers are found in Ubuntu under:

    /var/lib/docker/aufs/mnt/<uuid>

  One can copy files directly into these directory and they will show
  up immediately in the container.


  The directory where the root dirs is stored can be different depending
  on the hosts distribution.  One way to figure out where they reside is
  to use the following command:

    docker info | egrep '(Storage Driver|Root Dir)'
    Storage Driver: aufs
     Root Dir: /var/lib/docker/aufs
    Docker Root Dir: /var/lib/docker



# Tools

## LazyDocker

  A user interface for Docker and docker-compose, with everything you need
  in one terminal window, and every command command being one keypress away,
  so you don't have to memorise commands or keep track of your containers
  across multiple terminal windows

  https://github.com/jesseduffield/lazydocker
  https://www.linuxuprising.com/2019/07/lazydocker-new-docker-and-docker.html



# 10 DOCKER COMMANDS YOU CAN'T LIVE WITHOUT

From:  https://www.bitcoininsider.org/article/23859/top-10-docker-commands-you-cant-live-without

- docker ps

  Lists running containers. Some useful flags include: -a / -all for all
  containers (default shows just running) and —-quiet /-q to list just their
  ids (useful for when you want to get all the containers).

- docker pull

  Most of your images will be created on top of a base image from the Docker
  Hub registry. Docker Hub contains many pre-built images that you can pull
  and try without needing to define and configure your own. To download a
  particular image, or set of images (i.e., a repository), use docker pull.

- docker build

  The docker build command builds Docker images from a Dockerfile and a
  “context”. A build’s context is the set of files located in the specified
  PATH or URL. Use the -t flag to label the image, for example docker build -t
  my_container . with the . at the end signalling to build using the currently
  directory.

  Example:

    docker build --tag "${IMAGE_TAG}" .
      --tag "${IMAGE_TAG}"  to tag the image with a label.
      .                     assumes that *Dockerfile* is under the current dir.

  Other options:

      --nocache    Force rebuild of everything, ignoreing current cache.

- docker run

  Run a docker container based on an image, you can follow this on with
  other commands, such as -it bash to then run bash from within the
  container. docker run my_image -it bash

- docker logs

  Use this command to display the logs of a container, you must specify
  a container and can use flags, such as --follow to follow the output
  in the logs of using the program. docker logs --follow my_container

- docker volume ls

  This lists the volumes, which are the preferred mechanism for
  persisting data generated by and used by Docker containers.

- docker rm

  Removes one or more containers. docker rm my_container

- docker rmi

  Removes one or more images. docker rmi my_image

- docker stop

  Stops one or more containers. docker stop my_container A more direct
  way is to use docker kill my_container , which does not attempt to
  shut down the process gracefully first.

- Use them together, for example to clean up all your docker images and containers:

  - kill all running containers with docker kill $(docker ps -q)
  - delete all stopped containers with docker rm $(docker ps -a -q)
  - delete all images with docker rmi $(docker images -q)



# TROUBLESHOOTING

## Network problems

  If you have network problems with your builds/containers, a good idea
  is to download the wbitt/network-multitool image, start a container based
  on it, get into it and start

    docker pull wbitt/network-multitool         # Fetch image
    docker run -it wbitt/network-multitool bash # Start container with Bash session.

  Source code of the image:  https://github.com/wbitt/Network-MultiTool


## WARNING:  NFTABLES not supported

  22.04 & later install nftables instead of iptables, causing docker
  to fail to start when attempting to create iptables rules.

  The workaround is to run:

    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy



# Cleanup

WARNING:  This will remove:

- ALL STOPPED CONTAINERS
- all volumes not used by at least one container
- all networks not used by at least one container
- all images without at least one container associated to them

    # Doc:  https://docs.docker.com/engine/reference/commandline/system_prune/
    docker system prune --all --force --volumes
      # --all, -a      Remove all unused images not just dangling ones
      # --force, -f    Do not prompt for confirmation
      # --volumes      Prune volumes too

# Copyright

    █ ─ Copyright Notice ───────────────────────────────────────────────────
    █
    █ Copyright 2000-2023 Hans Deragon - GPL 3.0 licence.
    █
    █ Hans Deragon (hans@deragon.biz) owns the copyright of this work.
    █
    █ It is released under the GPL 3 licence which can be found at:
    █
    █     https://www.gnu.org/licenses/gpl-3.0.en.html
    █
    █ ─────────────────────────────────────────────────── Copyright Notice ─
