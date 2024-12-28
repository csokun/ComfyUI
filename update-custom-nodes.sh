#!/bin/bash

# Main directory name
main_dir="custom_nodes"

# Check if the main directory exists
if [ -d "$main_dir" ]; then
    # Scan subdirectories within the main directory with depth = 1
    for dir in "$main_dir"/*/; do
        # Check if the subdirectory contains a .git directory
        if [ -d "$dir/.git" ]; then
            echo "Entering directory $dir"
            # Change to the subdirectory
            cd "$dir"
            # Perform git pull
            git pull
            # Return to the main directory
            cd - > /dev/null
        else
            echo "Skipping $dir - not a git repository"
        fi
    done
else
    echo "Main directory $main_dir does not exist"
fi

