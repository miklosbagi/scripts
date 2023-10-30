# scripts
Scripts for various tasks

## docker-multi-nexus
This is a script to help cloning docker images into nexus with multiple architectures.

## jwt-tool
Small util to encode / decode jwt keys to velidate information & create tests.

## docker-compose_generate_known_good_state.sh
I rely on docker image:latest except when I have a good reason not to (e.g. known compat issue) - this helps me keep a working version of my compose files by extracting the tags from the active versions, and saves a backup with those instead of assumed :latest.
