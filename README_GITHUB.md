# 🚀 Local Network Messaging Application

A complete real-time messaging application for local Wi-Fi networks, built with **Python FastAPI** backend and **Flutter** mobile frontend.

![Messaging App Demo](https://img.shields.io/badge/Status-Ready%20for%20Testing-brightgreen)
![Python](https://img.shields.io/badge/Python-3.8+-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-WebSocket-green)

## ✨ Features

- 🔄 **Real-time messaging** with WebSocket support
- 👥 **Multi-user support** with online status tracking
- 📁 **File sharing** (images, documents)
- 📱 **Cross-platform** Flutter mobile app
- 🌐 **Local network** communication
- 🎨 **Modern UI** with Telegram-inspired dark theme
- 💾 **Persistent storage** with SQLite database
- 🔒 **Type-safe** API with Pydantic models

## 🏗️ Architecture

```
┌─────────────────┐    WebSocket/HTTP    ┌─────────────────┐
│  Flutter Client │ ◄─────────────────► │ FastAPI Backend │
│                 │                     │                 │
│ • Dart/Flutter  │                     │ • Python        │
│ • Provider      │                     │ • FastAPI       │
│ • WebSocket     │                     │ • SQLAlchemy    │
│ • File Upload   │                     │ • WebSocket     │
└─────────────────┘                     └─────────────────┘
                                                │
                                                ▼
                                        ┌─────────────────┐
                                        │ SQLite Database │
                                        │                 │
                                        │ • Users         │
                                        │ • Messages      │
                                        │ • Files         │
                                        └─────────────────┘
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Download and extract the project
git clone https://github.com/yourusername/local-messaging-app.git
cd local-messaging-app

# Run the automated setup script
chmod +x setup.sh
./setup.sh
```

### Option 2: Manual Setup

#### Backend Setup
```bash
cd backend
pip install -r requirements.txt
python3 main.py
```

#### Frontend Setup
```bash
cd flutter_client
flutter pub get
flutter run
```

## 📋 Prerequisites

- **Python 3.8+** with pip
- **Flutter SDK 3.0+** 
- **Android Studio/VS Code** (for mobile development)
- **Git** (for cloning)

## 🔧 Installation Guide

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/local-messaging-app.git
cd local-messaging-app
```

### 2. Backend Setup
```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Start the server
python3 main.py
```
Server will start on `http://0.0.0.0:8000`

### 3. Flutter Client Setup
```bash
cd flutter_client

# Install dependencies
flutter pub get

# Update server IP (replace with your server's IP)
# Edit lib/services/api_service.dart and lib/services/websocket_service.dart
# Change baseUrl to your server's IP address

# Run the app
flutter run
```

## 🌐 Network Configuration

### For Local Network Use:
1. **Find your server's IP address:**
   ```bash
   # Linux/Mac
   hostname -I
   
   # Windows
   ipconfig
   ```

2. **Update Flutter app configuration:**
   - Edit `flutter_client/lib/services/api_service.dart`
   - Edit `flutter_client/lib/services/websocket_service.dart`
   - Replace `baseUrl` with your server's IP:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:8000';
   ```

3. **Ensure all devices are on the same Wi-Fi network**

## 📱 Usage

1. **Start the backend server** on your main device
2. **Install and run the Flutter app** on mobile devices
3. **Register** with unique usernames on each device
4. **Start messaging** - users will appear in the contacts list
5. **Send text messages** and **share files** in real-time

## 🧪 Testing

### API Testing
```bash
# Test server status
curl http://localhost:8000/

# Register a user
curl -X POST "http://localhost:8000/register" \
-H "Content-Type: application/json" \
-d '{"username": "testuser"}'

# Get all users
curl http://localhost:8000/users
```

### WebSocket Testing
```bash
python3 test_websocket.py
```

## 📊 API Documentation

### REST Endpoints
- `GET /` - Server status
- `POST /register` - Register new user
- `GET /users` - Get all users
- `GET /messages/{user1}/{user2}` - Get chat history
- `POST /upload` - Upload file
- `GET /files/{filename}` - Serve file

### WebSocket
- `WS /ws/{user_id}` - Real-time messaging

## 🗄️ Database Schema

### Users Table
```sql
id          INTEGER PRIMARY KEY
username    VARCHAR UNIQUE
is_online   BOOLEAN
```

### Messages Table
```sql
id           INTEGER PRIMARY KEY
sender_id    INTEGER FOREIGN KEY
receiver_id  INTEGER FOREIGN KEY
message_type VARCHAR (text/image/document)
content      TEXT
timestamp    DATETIME
```

## 🚀 Deployment Options

### Local Network
- Perfect for home, office, or event networks
- No internet required
- Fast and secure local communication

### Cloud Deployment
- **Heroku:** Easy git-based deployment
- **DigitalOcean:** VPS hosting
- **AWS/GCP:** Scalable cloud hosting

### Docker Deployment
```bash
# Backend
cd backend
docker build -t messaging-backend .
docker run -p 8000:8000 messaging-backend

# Frontend (web version)
cd flutter_client
flutter build web
# Deploy build/web to any static hosting
```

## 🔒 Security Notes

For production deployment:
- Use HTTPS/WSS for encrypted communication
- Implement proper authentication
- Add rate limiting
- Validate all user inputs
- Use environment variables for configuration

## 🛠️ Development

### Project Structure
```
messaging_app/
├── backend/                 # Python FastAPI server
│   ├── main.py             # Application entry point
│   ├── database.py         # Database models
│   ├── models.py           # Pydantic schemas
│   └── requirements.txt    # Dependencies
├── flutter_client/         # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart      # App entry point
│   │   ├── models/        # Data models
│   │   ├── services/      # API services
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   └── widgets/       # UI components
│   └── pubspec.yaml       # Flutter dependencies
└── docs/                   # Documentation
```

### Tech Stack
- **Backend:** Python, FastAPI, SQLAlchemy, WebSocket
- **Frontend:** Flutter, Dart, Provider, HTTP
- **Database:** SQLite (development), PostgreSQL (production)
- **Real-time:** WebSocket connections

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation:** Check the [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Issues:** Open an issue on GitHub
- **Discussions:** Use GitHub Discussions for questions

## 🎯 Roadmap

- [ ] Group messaging
- [ ] Message encryption
- [ ] Voice messages
- [ ] Video calls
- [ ] Push notifications
- [ ] User profiles with avatars
- [ ] Message reactions
- [ ] File preview
- [ ] Message search

## 🙏 Acknowledgments

- Built with [FastAPI](https://fastapi.tiangolo.com/)
- Mobile app powered by [Flutter](https://flutter.dev/)
- Inspired by modern messaging applications

---

**Made with ❤️ for local network communication**
