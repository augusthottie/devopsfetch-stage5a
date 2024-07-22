# DevOpsFetch

DevOpsFetch is a bash tool designed for retrieving and monitoring server information. 
It can display active ports, user logins, Nginx configurations, Docker images, and container statuses. 
The tool also includes a systemd service for continuous monitoring and logging.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Setup](#setup)
- [Usage](#usage)
  - [Display Active Ports](#display-active-ports)
  - [Port Information](#port-information)
  - [Docker Information](#docker-information)
  - [Nginx Information](#nginx-information)
  - [User Logins](#user-logins)
  - [Time Range Activities](#time-range-activities)
- [Logging](#logging)
- [Help](#help)
- [Contributing](#contributing)
- [License](#license)

## Features

- Display all active ports and services
- Provide detailed information about a specific port
- List all Docker images and containers
- Provide detailed information about a specific Docker container
- Display all Nginx domains and their ports
- Provide detailed configuration information for a specific Nginx domain
- List all users and their last login times
- Provide detailed information about a specific user
- Display activities within a specified time range
- Continuous monitoring and logging with log rotation

## Installation

### Dependencies

Ensure the following packages are installed on your system:
- `ss` (part of `iproute2`)
- `docker.io`
- `nginx`
- `journalctl`

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/AugustHottie/devopsfetch.git
   cd devopsfetch
   ```

2. Run the installation script to set up dependencies and the systemd service:
   ```bash
   sudo ./install.sh
   ```

## Usage

### Display Active Ports

To display all active ports and services, run:
```bash
./devopsfetch.sh -p
```

### Port Information

To provide detailed information about a specific port, run:
```bash
./devopsfetch.sh -p <port_number>
```
Example:
```bash
./devopsfetch.sh -p 80
```

### Docker Information

To list all Docker images and containers, run:
```bash
./devopsfetch.sh -d
```

To provide detailed information about a specific Docker container, run:
```bash
./devopsfetch.sh -d <container_name>
```
Example:
```bash
./devopsfetch.sh -d my_container
```

### Nginx Information

To display all Nginx domains and their ports, run:
```bash
./devopsfetch.sh -n
```

To provide detailed configuration information for a specific Nginx domain, run:
```bash
./devopsfetch.sh -n <domain>
```
Example:
```bash
./devopsfetch.sh -n example.com
```

### User Logins

To list all users and their last login times, run:
```bash
./devopsfetch.sh -u
```

To provide detailed information about a specific user, run:
```bash
./devopsfetch.sh -u <username>
```
Example:
```bash
./devopsfetch.sh -u myuser
```

### Time Range Activities

To display activities within a specified time range, run:
```bash
./devopsfetch.sh -t "<start_time>" "<end_time>"
```
Example:
```bash
./devopsfetch.sh -t "2024-07-21 00:00:00" "2024-07-22 00:00:00"
```

## Logging

Logs are stored in the `logs/` directory. Log rotation is implemented to manage log file size. When a log file exceeds a certain size, it is renamed with a `.old` extension, and a new log file is created.

## Help

To display the help message with usage instructions, run:
```bash
./devopsfetch.sh -h
```
