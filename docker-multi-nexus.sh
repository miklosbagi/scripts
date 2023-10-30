#!/bin/bash

# this script downloads multiple architectures of a docker image, and pushes them to a private nexus registry.
# during this process, all the architecture versions will be pushed, and pulled under a single tag.

# for example: docker-multi-nexus.sh <image>:<tag>
# will pull <image>:<tag>-amd64, <image>:<tag>-arm64, <image>:<tag>-armv7, <image>:<tag>-armv6 if all set
# and push them to <nexus>:<port>/<image>:<tag>

# prerequisites: you must be authenticated to your nexus registry, end export the NEXUS_HOST variable, for example:
# NEXUS_HOST=my.nexus.host

ARCHS=(amd64 arm64)

if [ -z "$1" ]; then
    echo "Usage: docker-multi-nexus.sh <image>:<tag>"
    exit 1
fi

if [ -z "$NEXUS_HOST" ]; then
    echo "NEXUS_HOST is not set."
    exit 1
fi

echo "Processing $1..."
manifest_construct=""
for arch in "${ARCHS[@]}"; do
    echo "  Pulling $1 for $arch"
    # pull the image for the specified architecture
    docker pull -q --platform "linux/$arch" "$1" > /dev/null || { echo "Pull failed for $1 ($arch)" ; exit 1; }
    # tag the image with the architecture name and nexus host
    echo "  Tagging $1 for $arch"
    docker tag "$1" "$NEXUS_HOST/$1-$arch" > /dev/null || { echo "Tagging of $1 ($arch) failed for $NEXUS_HOST" ; exit 1; }
    # push the image to the nexus registry
    echo "  Pushing $1-$arch to $NEXUS_HOST"
    docker push "$NEXUS_HOST/$1-$arch" > /dev/null || { echo "Pushing of $1 ($arch) failed for $NEXUS_HOST" ; exit 1; }
    # remove the image so we have place for the next architecture (if exists)
    echo "  Removing $1 for $arch"
    docker rmi "$1" > /dev/null || { echo "Removal of $1 ($arch) failed" ; exit 1; }
    # add the --amend flag to the manifest construct if this is not the first architecture
    echo "  Adding $arch to manifest construct"
    manifest_construct+=" --amend $NEXUS_HOST/$1-$arch"
    echo
done

# create the manifest
echo
echo "Creating manifest for $1"
docker manifest create "$NEXUS_HOST/$1" $manifest_construct || { echo "Creation of manifest for $1 failed for $NEXUS_HOST" ; exit 1; } || { echo "Creation of manifest for $1 failed for $NEXUS_HOST" ; exit 1; }

for arch in "${ARCHS[@]}"; do
    # annotate the image with the architecture name
    echo "Annotating $1 for $arch"
    docker manifest annotate "$NEXUS_HOST/$1" "$NEXUS_HOST/$1-$arch" --os linux --arch "$arch" || { echo "Annotating of $1 ($arch) failed for $NEXUS_HOST" ; exit 1; }
done

# push the manifest to the nexus registry
echo "Pushing manifest to $NEXUS_HOST"
docker manifest push "$NEXUS_HOST/$1" || { echo "Pushing of manifest for $1 failed for $NEXUS_HOST" ; exit 1; }

# cleanup all local architecture images
for arch in "${ARCHS[@]}"; do
    echo "Removing $1-$arch"
    docker rmi "$NEXUS_HOST/$1-$arch" > /dev/null # we don't care of this fails.
done

# done
echo
echo "👍🏻 Done, all looking good."
echo
echo "You can test this with the followings: "
for arch in "${ARCHS[@]}"; do
    echo "  docker run --platform linux/$arch $NEXUS_HOST/$1"
done
echo
echo "(you may need to add extra params to those commands above, like -e variables, -v volumes, etc.)"

# EOF