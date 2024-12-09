#!/bin/bash

# Check if jq is installed; if not, install it
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update -y
    sudo apt-get install -y jq
else
    echo "jq is already installed."
fi

# Prompt user for inputs
read -p "Enter the major version (e.g., 1.21): " major_version
read -p "Enter the file name (e.g., 1.21.44.01_arm32_arm64_patched.apk): " file_name
read -p "Enter the download link (e.g., https://github.com/mcpebd/yssmirror/releases/download/1.21.44/1.21.44.01_arm32_arm64_patched.apk): " link
read -p "Enter the sha256 hash (e.g., 542fc5d9a997a5c8678e4ada4c40cd916da4db572a0435b69f0023a2efc63dd1): " sha256

# Check if links.json exists
if [ ! -f "links.json" ]; then
    echo "links.json not found! Creating new file."
    echo "{}" > links.json
fi

# Debugging: Show the current content of links.json before modification
echo "Current content of links.json:"
cat links.json
echo ""

# Use jq to update the links.json file
jq --arg major_version "$major_version" \
   --arg file_name "$file_name" \
   --arg link "$link" \
   --arg sha256 "$sha256" \
   '
   # Add the new entry under the major_version key
   .[$major_version] += [{
       "name": $file_name,
       "link": $link,
       "sha256": $sha256
   }]
   |
   # Sort the entries by version (numeric sorting)
   .[$major_version] = (
     .[$major_version] | 
     sort_by(
       # Extract version part from the name field before the first underscore
       .name | capture("^(\\d+\\.\\d+\\.\\d+)") | 
       .[0] | 
       split(".") | 
       map(tonumber)
     ) | reverse
   )
   ' links.json > temp_links.json && mv temp_links.json links.json

# Debugging: Show the content of links.json after modification
echo "Updated content of links.json:"
cat links.json
echo ""

echo "links.json updated and sorted by version (newer first) successfully!"
