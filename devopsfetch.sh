#!/bin/bash

# Function to display all active ports and services
display_ports() {
    echo "Active Ports and Services:"
    netstat -tulnp | awk '
    BEGIN {
        printf "%-15s %-6s %-10s %-15s %s\n", "Host", "Port", "PID", "Service", "User"
    }
    NR > 2 {
        # Extract host and port from $4
        split($4, addr, ":")
        host = addr[1]
        port = addr[2]
        
        # Extract PID and service from $7
        split($7, pid_service, "/")
        pid = pid_service[1]
        service = pid_service[2]

        # Print the line to a temporary file for later processing
        print host, port, pid, service > "/tmp/netstat_tmp.txt"
    }
    '

    # Process the temporary file to get the user information
    while read -r host port pid service; do
        # Check if the PID is valid and retrieve the username
        if [ -n "$pid" ]; then
            user=$(ps -o user= -p "$pid" 2>/dev/null)
            if [ -z "$user" ]; then
                user="N/A"
            fi
            printf "%-15s %-6s %-10s %-15s %s\n" "$host" "$port" "$pid" "$service" "$user"
        fi
    done < /tmp/netstat_tmp.txt

    # Clean up the temporary file
    rm /tmp/netstat_tmp.txt
}

# Function to display detailed information about a specific port
display_port_details() {
    local port_number=$1
    echo "Details for port $port_number:"

    netstat -tulnp | awk -v port="$port_number" '
    BEGIN {
        printf "%-15s %-6s %-10s %-15s %s\n", "Host", "Port", "PID", "Service", "User"
    }
    NR > 2 {
        # Extract host and port from $4
        split($4, addr, ":")
        host = addr[1]
        port_num = addr[2]
        
        # Extract PID and service from $7
        split($7, pid_service, "/")
        pid = pid_service[1]
        service = pid_service[2]

        # Filter by the target port
        if (port_num == port) {
            # Print the line to a temporary file for later processing
            print host, port_num, pid, service > "/tmp/netstat_tmp.txt"
        }
    }
    '

    # Process the temporary file to get the user information
    while read -r host port pid service; do
        # Check if the PID is valid and retrieve the username
        if [ -n "$pid" ]; then
            user=$(ps -o user= -p "$pid" 2>/dev/null)
            if [ -z "$user" ]; then
                user="N/A"
            fi
            printf "%-15s %-6s %-10s %-15s %s\n" "$host" "$port" "$pid" "$service" "$user"
        fi
    done < /tmp/netstat_tmp.txt

    # Clean up the temporary file
    rm /tmp/netstat_tmp.txt
}

# Function to list all Docker images and containers
list_docker() {
    echo "Docker Images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}"

    echo "Docker Containers:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# Function to provide detailed information about a specific Docker container
docker_container_details() {
    local container_name=$1
    echo "Details for Docker container $container_name:"
    docker inspect $container_name | jq '.[] | {Name: .Name, State: .State, Config: .Config}'
}

# Function to display all Nginx domains and their ports
list_nginx_domains() {
    echo "Server Domain                           Proxy                Configuration File"
    echo "----------------------------------------+-----------------------+----------------------------------------"

    for file in /etc/nginx/sites-enabled/*; do
        server_names=$(grep -E -h "^\s*server_name" "$file" | sed 's/^\s*server_name \(.*\);/\1/' | tr -d ';' | grep -v '^_')
        proxy_passes=$(grep -E -h "^\s*proxy_pass" "$file" | sed 's/^\s*proxy_pass \(.*\);/\1/' | tr -d ';')

        IFS=' ' read -r -a server_name_array <<< "$server_names"
        IFS=' ' read -r -a proxy_pass_array <<< "$proxy_passes"

        for name in "${server_name_array[@]}"; do
            for proxy in "${proxy_pass_array[@]}"; do
                printf "%-40s | %-21s | %s\n" "$name" "$proxy" "$file"
            done
        done
    done | sort | uniq
}

# list_nginx_domains() {
#     echo "Nginx Domains and Ports:"
    
#     # Print heading
#     printf "%-40s %-10s %-40s %-10s\n" "Server Name" "Port" "Proxied Host" "Proxied Port"

#     # Process each configuration file
#     for file in /etc/nginx/sites-enabled/*; do
#         # Extract server_name directives, ignoring commented lines and empty entries
#         server_names=$(grep -E -h "^\s*server_name" "$file" | sed 's/^\s*server_name \(.*\);/\1/' | tr -d ';' | grep -v '^_')

#         # Extract listen directives, ignoring commented lines and empty entries
#         listen_ports=$(grep -E -h "^\s*listen" "$file" | sed 's/^\s*listen \(.*\);/\1/' | tr -d ';')

#         # Extract proxy_pass directives, ignoring commented lines and empty entries
#         proxy_passes=$(grep -E -h "^\s*proxy_pass" "$file" | sed 's/^\s*proxy_pass \(.*\);/\1/' | tr -d ';' | sed 's/^\(http:\/\/\|https:\/\/\)//')

#         # Handle multiple server names and listen ports
#         IFS=' ' read -r -a server_name_array <<< "$server_names"
#         IFS=' ' read -r -a listen_array <<< "$listen_ports"
#         IFS=' ' read -r -a proxy_pass_array <<< "$proxy_passes"

#         # Print each combination of server_name and listen
#         for name in "${server_name_array[@]}"; do
#             for port in "${listen_array[@]}"; do
#                 # Check if there are proxy_pass entries
#                 if [ ${#proxy_pass_array[@]} -eq 0 ]; then
#                     # No proxy_pass entries found
#                     printf "%-40s %-10s %-40s %-10s\n" "$name" "$port" "-" "-"
#                 else
#                     # Print each combination of server_name, listen, and proxy_pass
#                     for proxy in "${proxy_pass_array[@]}"; do
#                         # Extract the proxied host and port
#                         proxied_host=$(echo "$proxy" | awk -F: '{print $1}')
#                         proxied_port=$(echo "$proxy" | awk -F: '{print $2}')

#                         # Only print valid ports (numerical values) and non-empty domains
#                         if [[ $port =~ ^[0-9]+$ ]] && [[ -n $name ]]; then
#                             printf "%-40s %-10s %-40s %-10s\n" "$name" "$port" "$proxied_host" "${proxied_port:--}"
#                         fi
#                     done
#                 fi
#             done
#         done
#     done | sort | uniq
# }

# Function to provide detailed configuration information for a specific domain
nginx_domain_details() {
    local domain=$1
    echo "Details for Nginx domain $domain:"

    # Find files that contain the server_name directive for the given domain
    local files=$(grep -lR "server_name $domain;" /etc/nginx/sites-enabled/)

    # Initialize variables to store extracted details
    local port=""
    local root=""
    local index=""
    local server_name=""
    local proxy_host=""
    local proxy_port=""

    # Loop through each file to extract details
    for file in $files; do
        # Extract port
        local file_port=$(grep -E "^\s*listen" "$file" | awk '{print $2}' | head -1)
        if [ -n "$file_port" ]; then
            port="$file_port"
        fi

        # Extract root
        local file_root=$(grep -E "^\s*root" "$file" | awk '{print $2}' | head -1)
        if [ -n "$file_root" ]; then
            root="$file_root"
        fi

        # Extract index
        local file_index=$(grep -E "^\s*index" "$file" | awk '{print $2}' | head -1)
        if [ -n "$file_index" ]; then
            index="$file_index"
        fi

        # Extract server_name
        local file_server_name=$(grep -E "^\s*server_name" "$file" | awk '{print $2}' | head -1)
        if [ -n "$file_server_name" ]; then
            server_name="$file_server_name"
        fi

        # Extract proxy_pass (both host and port)
        local file_proxy=$(grep -E "^\s*proxy_pass" "$file" | sed 's/^\s*proxy_pass \(.*\);/\1/' | tr -d ';' | sed 's/^\(http:\/\/\|https:\/\/\)//')
        if [ -n "$file_proxy" ]; then
            proxy_host=$(echo "$file_proxy" | awk -F: '{print $1}')
            proxy_port=$(echo "$file_proxy" | awk -F: '{print $2}')
        fi
    done

    # if was unable to find server-name, show cannot find
    if [ -z "$server_name" ]; then
        echo "Cannot find server_name for domain $domain"
        exit 1
    fi

    # Display the extracted details in a formatted column style
    printf "%-15s %-30s %-20s %-40s %-30s %-10s\n" "Port" "Root" "Index" "Server Name" "Proxied Host" "Proxied Port"
    printf "%-15s %-30s %-20s %-40s %-30s %-10s\n" "${port:--}" "${root:--}" "${index:--}" "${server_name:--}" "${proxy_host:--}" "${proxy_port:--}"
}

# Function to list all users and their last login times
list_users() {
    echo "Users and Last Login Times:"
    lastlog | column -t
}

# Function to provide detailed information about a specific user
user_details() {
    local username=$1
    echo "Details for user $username:"
    finger $username
}

# Function to display activities within a specified time range
display_activities_in_time_range() {
    local start_time=$1
    local end_time=$2
    echo "Activities from $start_time to $end_time:"
    journalctl --since="$start_time" --until="$end_time" | less
}

# Display usage instructions
display_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p, --port                Display all active ports and services"
    echo "  -p <port_number>          Display detailed information about a specific port"
    echo "  -d, --docker              List all Docker images and containers"
    echo "  -d <container_name>       Display detailed information about a specific Docker container"
    echo "  -n, --nginx               Display all Nginx domains and their ports"
    echo "  -n <domain>               Display detailed configuration information for a specific Nginx domain"
    echo "  -u, --users               List all users and their last login times"
    echo "  -u <username>             Display detailed information about a specific user"
    echo "  -t, --time <start> <end>  Display activities within a specified time range"
    echo "  -h, --help                Display this help message"
}

# Parse command-line arguments
case $1 in
    -p|--port)
        if [ -z "$2" ]; then
            display_ports
        else
            display_port_details $2
        fi
        ;;
    -d|--docker)
        if [ -z "$2" ]; then
            list_docker
        else
            docker_container_details $2
        fi
        ;;
    -n|--nginx)
        if [ -z "$2" ]; then
            list_nginx_domains
        else
            nginx_domain_details $2
        fi
        ;;
    -u|--users)
        if [ -z "$2" ]; then
            list_users
        else
            user_details $2
        fi
        ;;
    -t|--time)
        if [ -z "$3" ]; then
            echo "Error: Time range requires start and end times."
            exit 1
        else
            display_activities_in_time_range $2 $3
        fi
        ;;
    -h|--help)
        display_help
        ;;
    *)
        echo "Error: Invalid option."
        display_help
        exit 1
        ;;
esac
