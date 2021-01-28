#!/bin/bash

# Build builder images

rm -rf ./reports
outputVolume=$(docker volume create)
DOCKER_BUILDKIT=1 docker build -f "build/package/alpine-builder/Dockerfile" -t "runiac:alpine-builder" . || exit 1;
CID=$(docker create -v "$outputVolume":/reports "runiac:alpine-builder")
docker cp "$CID":/reports $(pwd)
touch ./reports/*.xml
docker rm "$CID"
docker volume rm "$outputVolume"


# Build consumer images
for d in build/package/*/ ; do
  if [[ "$d" == *"-builder"* ]]; then
    continue
  fi

  echo "$d"
  dir="${d%/*}"
  tag=${dir##*/}
  DOCKER_BUILDKIT=1 docker build -f "$d/Dockerfile" -t "runiac:$tag" . &
done

wait
