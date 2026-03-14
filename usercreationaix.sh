#!/bin/bash

#Define the  list of servers where the user needs to be created
SERVERS=(
LIST THE SERVERS LIST
)

# Define the common user variables
# Define the common user variables
USER="USERID"
PASSWORD="Bridge@123"
HOME_DIR="/home/$USER"
SHELL="/usr/bin/ksh"
GECOS=""


# Define the mirror ID whose group details we need to retrieve
MIRROR_USER="MIRRORID"



# Function to get the pgrp and groups from an existing user
get_pgrp_and_groups() {
    local server=$1
    local mirror_user=$2

    # Get the primary group (pgrp) and the secondary groups for the mirror user
    local pgrp=$(ssh -q ID@$server "id -gn $mirror_user")
    local groups=$(ssh -q ID@$server "id -Gn $mirror_user" | tr ' ' ',') # Get group names

    echo "$pgrp,$groups"
}

# Function to create a user and set the password
create_user_on_server() {
    local server=$1
    local mirror_user=$2
    local user=$3
    local password=$4
    local home_dir=$5
    local shell=$6
    local gecos=$7

    # Get pgrp and groups from the mirror user
    local group_info=$(get_pgrp_and_groups $server $mirror_user)
    local pgrp=$(echo $group_info | cut -d',' -f1)
    local groups=$(echo $group_info | cut -d',' -f2-)

    echo "Creating user on server: $server with pgrp=$pgrp and groups=$groups"

    # Run user creation command remotely
    ssh -q ID@$server "
        if id $user >/dev/null 2>&1; then
            echo 'User $user already exists on $server. Skipping creation.'
        else
            sudo mkuser pgrp=$pgrp groups=$groups home=\"$home_dir\" shell=\"$shell\" gecos=\"$gecos\" $user
            if [ \$? -eq 0 ]; then
                echo 'User $user created successfully on $server.'
            else
                echo 'Failed to create user $user on $server.'
                exit 1
            fi
        fi
    "

    # Set the password for the user on the remote server
    if ssh -q ID@$server "id $user >/dev/null 2>&1"; then
        echo "Setting password for $user on $server..."
        ssh -q ID@$server "echo '$user:$password' | sudo chpasswd"
        if [ $? -eq 0 ]; then
            echo "Password set successfully for $user on $server."
        else
            echo "Failed to set password for $user on $server."
        fi
    else
        echo "User $user does not exist on $server. Skipping password setup."
    fi
}

# Main script execution
for SERVER in "${SERVERS[@]}"; do
    create_user_on_server "$SERVER" "$MIRROR_USER" "$USER" "$PASSWORD" "$HOME_DIR" "$SHELL" "$GECOS"
done

echo "User creation and password setup process completed."
