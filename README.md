# Local Network Messaging Application

A complete mobile messaging application that works on a local Wi-Fi network, consisting of a Python FastAPI backend server and a Flutter mobile client.

## Features

- **Real-time messaging** using WebSockets
- **User registration** and online status tracking
- **File sharing** (images, documents)
- **Cross-platform** Flutter mobile app
- **Local network** communication
- **Telegram-inspired** UI design

## Technology Stack

### Backend
- **Python** with FastAPI
- **SQLite** database with SQLAlchemy
- **WebSockets** for real-time communication
- **File upload/serving** capabilities

### Frontend
- **Flutter** for cross-platform mobile app
- **Provider** for state management
- **WebSocket** connectivity
- **File picker** for attachments

## Setup Instructions

### Backend Server

1. **Navigate to the backend directory:**
   ```bash
   cd messaging_app/backend
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the server:**
   ```bash
   python3 main.py
   ```

   The server will start on `http://0.0.0.0:8000`

4. **Get your server's public URL:**
   The current server is running at: `http://82298cb6fbaf643872.blackbx.ai`

### Flutter Client

1. **Navigate to the Flutter directory:**
   ```bash
   cd messaging_app/flutter_client
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update server URL (if needed):**
   - Edit `lib/services/api_service.dart`
   - Edit `lib/services/websocket_service.dart`
   - Update the `baseUrl` to your server's address

4. **Run the Flutter app:**
   ```bash
   flutter run
   ```

## API Endpoints

### REST API
- `POST /register` - Register a new user
- `GET /users` - Get all registered users
- `GET /messages/{user_id_1}/{user_id_2}` - Get chat history
- `POST /upload` - Upload a file
- `GET /files/{file_name}` - Serve uploaded files

### WebSocket
- `WS /ws/{user_id}` - Real-time messaging endpoint

## Database Schema

### Users Table
- `id` (Integer, Primary Key)
- `username` (String, Unique)
- `is_online` (Boolean)

### Messages Table
- `id` (Integer, Primary Key)
- `sender_id` (Integer, Foreign Key)
- `receiver_id` (Integer, Foreign Key)
- `message_type` (String: 'text', 'image', 'document')
- `content` (String)
- `timestamp` (DateTime)

## Usage

1. **Start the backend server** on your local machine
2. **Make sure all devices are connected** to the same Wi-Fi network
3. **Install and run the Flutter app** on mobile devices
4. **Register with a username** on each device
5. **Start messaging** with other users on the network

## File Structure

```
messaging_app/
├── backend/
│   ├── main.py              # FastAPI application
│   ├── database.py          # Database models and setup
│   ├── models.py            # Pydantic models
│   ├── requirements.txt     # Python dependencies
│   └── uploads/             # File storage directory
└── flutter_client/
    ├── lib/
    │   ├── main.dart           # App entry point
    │   ├── models/             # Data models
    │   ├── services/           # API and WebSocket services
    │   ├── providers/          # State management
    │   ├── screens/            # UI screens
    │   └── widgets/            # Reusable widgets
    └── pubspec.yaml           # Flutter dependencies
```

## Network Configuration

- Ensure all devices are on the same Wi-Fi network
- The server should be accessible from other devices on the network
- Update the server URL in the Flutter app if using a different IP address

## Troubleshooting

1. **Connection Issues:**
   - Verify all devices are on the same network
   - Check firewall settings
   - Ensure the server is running and accessible

2. **WebSocket Issues:**
   - Check network connectivity
   - Verify WebSocket URL is correct
   - Look for error messages in app logs

3. **File Upload Issues:**
   - Check file permissions
   - Verify uploads directory exists
   - Check available storage space

## Development Notes

- The app uses a dark theme inspired by Telegram
- Real-time messaging is handled via WebSockets
- Files are stored locally on the server
- User sessions are maintained using SharedPreferences
- The app supports both text messages and file attachments

## Future Enhancements

- Group messaging
- Message encryption
- Voice messages
- Video calls
- Message reactions
- User profiles with avatars
- Message search functionality
- Push notifications
