#!/bin/bash

# List all running Docker containers
containers=$(docker ps --format '{{.Names}}')

# Print the header
printf "%-20s %-15s %-30s\n" "Name" "IP Address" "Port[Container->Host]"

# Loop through each container
for container in $containers
do
    # Get container network settings
    network_info=$(docker inspect $container --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

    # Check if the IP address is IPv4
    if [[ $network_info =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Extract and process each port mapping
        port_lines=$(docker inspect $container --format '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}} -> {{(index $conf 0).HostPort}}{{"\n"}}{{else}}{{$p}} -> No mapping{{"\n"}}{{end}}{{end}}')

        # Read port mapping lines
        IFS=$'\n' read -r -d '' -a ports <<< "$port_lines"

        # Print the first line with container info
        if [ ${#ports[@]} -eq 0 ]; then
            # Handle case with no ports or no mappings
            printf "%-20s %-15s %-30s\n" "$container" "$network_info" "No mapping"
        else
            printf "%-20s %-15s %-30s\n" "$container" "$network_info" "${ports[0]}"
            # Print remaining ports, if any
            for ((i=1; i<${#ports[@]}; i++)); do
                printf "%-20s %-15s %-30s\n" "" "" "${ports[$i]}"
            done
        fi
    fi
done
