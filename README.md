# scripts
Scripts for various tasks

## docker-compose_generate_known_good_state.sh
I rely on docker image:latest except when I have a good reason not to (e.g. known compat issue) - this helps me keep a working version of my compose files by extracting the tags from the active versions, and saves a backup with those instead of assumed :latest.
