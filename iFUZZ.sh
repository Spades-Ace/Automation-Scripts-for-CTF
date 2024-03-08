#!/bin/bash

# Define paths to required files
# Please specify the absolute path for seclist here accordingly
seclist_big_txt="/usr/share/seclists/Discovery/Web-Content/big.txt"
subdomain_20000="/usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt"

# Function to perform directory enumeration using fuzz tool
perform_directory_enumeration() {
    local url="$1"
    local filters="$2"
    local follow_redirect="$3"
    local recursion="$4"
    local filter_option=""
    local redirect_option=""
    local recursion_option=""
    
    if [ "$filters" != "skipped" ]; then
        filter_option="-fc $filters"
    fi

    if [ "$follow_redirect" == "yes" ]; then
        redirect_option="-r"
    fi

    if [ "$recursion" == "yes" ]; then
        recursion_option="-recursion"
    fi
    
    ffuf -w "$seclist_big_txt" -u "$url/FUZZ" $redirect_option $recursion_option $filter_option
}

# Function to perform DNS enumeration using fuzz tool
perform_dns_enumeration() {
    local url="$1"
    local filters="$2"
    local follow_redirect="$3"
    local recursion="$4"
    local filter_option=""
    local redirect_option=""
    local recursion_option=""
    
    if [ "$filters" != "skipped" ]; then
        filter_option="-fc $filters"
    fi

    if [ "$follow_redirect" == "yes" ]; then
        redirect_option="-r"
    fi

    if [ "$recursion" == "yes" ]; then
        recursion_option="-recursion"
    fi
    
    ffuf -w "$subdomain_20000" -u "$url" -H "Host: FUZZ.$(echo $url | cut -d '/' -f3)" $redirect_option $recursion_option $filter_option
}

# Prompt user for URL input
read -p "Enter URL: " user_url

# Prompt user for filters
read -p "Enter filters (default is skipped): " user_filters

# Prompt user for following redirections
read -p "Follow redirections? (yes/no, default is no): " follow_redirect

# Prompt user for recursion
read -p "Use recursion? (yes/no, default is no): " recursion

# If filters are empty, set default value
user_filters="${user_filters:-skipped}"
follow_redirect="${follow_redirect:-no}"
recursion="${recursion:-no}"

# Perform directory enumeration
echo "Performing directory enumeration..."
perform_directory_enumeration "$user_url" "$user_filters" "$follow_redirect" "$recursion"

# Perform DNS enumeration
echo "Performing DNS enumeration..."
perform_dns_enumeration "$user_url" "$user_filters" "$follow_redirect" "$recursion"