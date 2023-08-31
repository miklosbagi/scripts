#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <compose_file>"
    exit 1
fi

compose_file="$1"  # Path to the Docker Compose file
current_date=$(date +"%Y-%m-%d")
known_good_file="${compose_file%.*}_last_known_good-$current_date.yaml"

# Extract latest versions
latest_versions=$(grep -E 'image:.*:latest' "$compose_file" | sed -E 's/^(.*):latest$/\1/')

# Create known good state file
cp "$compose_file" "$known_good_file"

# Replace :latest with extracted versions
for version in $latest_versions; do
    service_name=$(grep -E "image:.*$version" "$known_good_file" | cut -d':' -f1)
    sed -i "s|image:.*$service_name:latest|image: $version|g" "$known_good_file"
done

echo "Known good state file generated: $known_good_file"
