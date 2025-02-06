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

# Debug output
echo "Debug: query='$query' keyword='$keyword'" >&2

# Initialize items array
items="["

# Check for query (use parameter expansion for safety)
if [[ -z "${query:-}" ]]; then
    echo "Debug: Entering empty query block" >&2
    items+="$(create_item "Search $network Explorer" "Enter address, tx, block, or name" "https://$domain")"
    items+=","
    items+="$(create_item "Recent Blocks" "View latest blocks on $network" "https://$domain/blocks")"
    items+=","
    items+="$(create_item "Recent Transactions" "View latest transactions on $network" "https://$domain/txs")"
else
    echo "Debug: Entering non-empty query block" >&2
    # Rest of your existing conditions for non-empty queries
    query="${query// /}"
    if [[ "$query" =~ ^0x[a-fA-F0-9]{64}$ ]]; then
        items+="$(create_item "View Transaction" "$query" "https://$domain/tx/$query")"
    elif [[ "$query" =~ ^[0-9]+$ ]]; then
        items+="$(create_item "View Block" "Block #$query" "https://$domain/block/$query")"
    elif [[ "$query" =~ ^.*\.base\.eth$ ]]; then
        items+="$(create_item "View Name: $query" "Lookup Base name" "https://$domain/name-lookup-search?id=$query")"
    elif [[ "$query" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        items+="$(create_item "View Address" "$query" "https://$domain/address/$query")"
    elif [[ "$query" =~ ^[a-zA-Z0-9]+$ ]]; then
        items+="$(create_item "Search Name: $query.base.eth" "Lookup Base name" "https://$domain/name-lookup-search?id=$query.base.eth")"
    fi
fi

items+="]"
echo "{\"items\":$items}"