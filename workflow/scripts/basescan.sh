#!/bin/bash

query="$1"
keyword="$alfred_workflow_keyword"

# Set domain based on keyword
if [[ "$keyword" == "bss" ]]; then
    domain="sepolia.basescan.org"
    network="Sepolia"
else
    domain="basescan.org"
    network="Base"
fi

# Function to create JSON item
create_item() {
    local title="$1"
    local subtitle="$2"
    local url="$3"
    echo "{\"title\":\"$title\",\"subtitle\":\"$subtitle\",\"arg\":\"$url\",\"valid\":true}"
}

# Initialize items array
items="["

# Show help/default items if no query
if [[ -z "$query" ]]; then
    items+="$(create_item "Search $network Explorer" "Enter address, tx, block, or name" "https://$domain")"
    items+=","
    items+="$(create_item "Recent Blocks" "View latest blocks on $network" "https://$domain/blocks")"
    items+=","
    items+="$(create_item "Recent Transactions" "View latest transactions on $network" "https://$domain/txs")"
else
    if [[ "$query" =~ ^0x[a-fA-F0-9]{64}$ ]]; then
        items+="$(create_item "View Transaction" "$query" "https://$domain/tx/$query")"
    elif [[ "$query" =~ ^[0-9]+$ ]]; then
        items+="$(create_item "View Block #$query" "Open block explorer" "https://$domain/block/$query")"
    elif [[ "$query" == *"."* ]]; then
        items+="$(create_item "Search Name: $query" "Lookup Base name" "https://$domain/name-lookup-search?id=$query")"
    elif [[ "$query" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        items+="$(create_item "View Address" "$query" "https://$domain/address/$query")"
    elif [[ "$query" =~ ^[a-zA-Z0-9]+$ ]]; then
        items+="$(create_item "Search Name: $query.base.eth" "Lookup Base name" "https://$domain/name-lookup-search?id=$query.base.eth")"
    fi
fi

items+="]"
echo "{\"items\":$items}"