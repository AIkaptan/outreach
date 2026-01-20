#!/bin/bash

# Check if port 5000 is in use
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null ; then
    echo "Port 5000 is already in use. Please close it first or change the PORT in .env"
    echo "To find and kill the process:"
    echo "  lsof -i :5000"
    echo "  kill -9 <PID>"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Load environment variables if .env exists
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Run the Flask application
python app.py

