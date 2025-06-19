#!/bin/bash

# 🚀 Local Network Messaging App - Automated Setup Script
# This script will set up both backend and frontend automatically

echo "🚀 Starting Local Network Messaging App Setup..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Python is installed
check_python() {
    print_header "🐍 Checking Python installation..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_status "Python found: $PYTHON_VERSION"
    else
        print_error "Python 3 is not installed. Please install Python 3.8+ first."
        exit 1
    fi
}

# Check if pip is installed
check_pip() {
    print_header "📦 Checking pip installation..."
    if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
        print_status "pip is available"
    else
        print_error "pip is not installed. Please install pip first."
        exit 1
    fi
}

# Setup backend
setup_backend() {
    print_header "🔧 Setting up Backend Server..."
    
    cd backend || exit 1
    
    print_status "Installing Python dependencies..."
    if pip install -r requirements.txt; then
        print_status "Backend dependencies installed successfully!"
    else
        print_error "Failed to install backend dependencies"
        exit 1
    fi
    
    cd ..
}

# Check Flutter installation
check_flutter() {
    print_header "📱 Checking Flutter installation..."
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_status "Flutter found: $FLUTTER_VERSION"
        return 0
    else
        print_warning "Flutter is not installed."
        print_warning "Please install Flutter from: https://flutter.dev/docs/get-started/install"
        print_warning "You can still run the backend server without Flutter."
        return 1
    fi
}

# Setup Flutter
setup_flutter() {
    print_header "📱 Setting up Flutter Client..."
    
    cd flutter_client || exit 1
    
    print_status "Getting Flutter dependencies..."
    if flutter pub get; then
        print_status "Flutter dependencies installed successfully!"
    else
        print_error "Failed to install Flutter dependencies"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# Get local IP address
get_local_ip() {
    print_header "🌐 Detecting local IP address..."
    
    # Try different methods to get IP
    if command -v hostname &> /dev/null; then
        LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null)
    fi
    
    if [ -z "$LOCAL_IP" ]; then
        if command -v ifconfig &> /dev/null; then
            LOCAL_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
        fi
    fi
    
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP="localhost"
        print_warning "Could not detect IP address automatically. Using localhost."
    else
        print_status "Local IP detected: $LOCAL_IP"
    fi
}

# Update Flutter configuration
update_flutter_config() {
    if [ "$FLUTTER_AVAILABLE" = true ]; then
        print_header "⚙️  Updating Flutter configuration..."
        
        # Update API service
        sed -i.bak "s|static const String baseUrl = '.*';|static const String baseUrl = 'http://$LOCAL_IP:8000';|g" flutter_client/lib/services/api_service.dart 2>/dev/null
        
        # Update WebSocket service  
        sed -i.bak "s|static const String baseUrl = '.*';|static const String baseUrl = 'ws://$LOCAL_IP:8000';|g" flutter_client/lib/services/websocket_service.dart 2>/dev/null
        
        print_status "Flutter configuration updated with IP: $LOCAL_IP"
    fi
}

# Start backend server
start_backend() {
    print_header "🚀 Starting Backend Server..."
    
    cd backend || exit 1
    
    print_status "Starting FastAPI server on http://0.0.0.0:8000"
    print_status "Server will be accessible at: http://$LOCAL_IP:8000"
    print_status ""
    print_status "Press Ctrl+C to stop the server"
    print_status "=================================================="
    
    python3 main.py
}

# Main setup function
main() {
    print_header "🎉 Local Network Messaging App Setup"
    print_header "====================================="
    
    # Check prerequisites
    check_python
    check_pip
    
    # Setup backend
    setup_backend
    
    # Check and setup Flutter
    if check_flutter; then
        FLUTTER_AVAILABLE=true
        setup_flutter
    else
        FLUTTER_AVAILABLE=false
    fi
    
    # Get IP and update config
    get_local_ip
    update_flutter_config
    
    # Print setup summary
    print_header "✅ Setup Complete!"
    print_header "=================="
    print_status "Backend: Ready to start"
    if [ "$FLUTTER_AVAILABLE" = true ]; then
        print_status "Flutter: Configured and ready"
    else
        print_warning "Flutter: Not available (backend only)"
    fi
    print_status "Server URL: http://$LOCAL_IP:8000"
    print_status ""
    
    # Ask if user wants to start server
    echo -n "Do you want to start the backend server now? (y/n): "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        start_backend
    else
        print_status "Setup complete! To start the server later, run:"
        print_status "cd backend && python3 main.py"
        if [ "$FLUTTER_AVAILABLE" = true ]; then
            print_status ""
            print_status "To run the Flutter app:"
            print_status "cd flutter_client && flutter run"
        fi
    fi
}

# Run main function
main "$@"
