#!/bin/bash

# Function to start the application process
start_application() {
    make run
}

# Trap SIGTERM and SIGINT to ensure the script can handle the termination signal
trap 'kill -TERM $PID; wait $PID' TERM INT

# Start the application process in the background
start_application &
PID=$!

# Wait for the process to complete
wait $PID