#!/bin/bash

# Function to display the menu
function display_menu() {
  echo "Docker Commander Menu:"
  echo "1. List container's IP addresses"
  echo "2. Stop all running containers"
  echo "3. Kill and prune all containers"
  echo "4. Restart all containers"
  echo "5. Exit"
  echo "Enter your choice: "
}

# Function to print table headers
function print_headers() {
  printf " Hostname\t\tIP Address\n"
  printf " ---------\t\t---------\n"
}

# Function to print table row
function print_row() {
  hostname="$1"
  ip_address="$2"
  printf " %-10s\t\t%s\n" "$hostname" "$ip_address"
}

# Function to print container's IP addresses
function print_containers_ip() {
  print_headers
  containers_ip=$(docker inspect -f '{{json .Name}}  {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q) | sed -e 's/"//g; s/\///g')
  while IFS=' ' read -r hostname ip_address; do
    print_row "$hostname" "$ip_address"
  done <<< $containers_ip
}

# Get user choice
choice=""
while [ -z "$choice" ]; do
  display_menu
  read choice
done

# Execute the selected command
case $choice in
  1) print_containers_ip ;;
  2) docker stop $(docker ps -q) ;;
  3) docker kill $(docker ps -q) ;;
  4) docker restart $(docker ps -q) ;;
  5) exit ;;
  *) echo "Invalid choice. Please enter a number between 1 and 5." ;;
esac

