from fastapi import FastAPI, Depends, HTTPException, WebSocket, WebSocketDisconnect, UploadFile, File
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from typing import List, Dict
import json
import os
import uuid
import aiofiles
from datetime import datetime

from database import get_db, create_tables, User, Message
from models import UserCreate, UserResponse, MessageResponse, WebSocketMessage, FileUploadResponse

# Create FastAPI app
app = FastAPI(title="Local Network Messaging API", version="1.0.0")

# Create database tables on startup
create_tables()

# Mount static files for uploads
app.mount("/files", StaticFiles(directory="uploads"), name="files")

# WebSocket connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, WebSocket] = {}

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        
        # Update user online status
        db = next(get_db())
        user = db.query(User).filter(User.id == user_id).first()
        if user:
            user.is_online = True
            db.commit()
        db.close()

    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
        
        # Update user offline status
        db = next(get_db())
        user = db.query(User).filter(User.id == user_id).first()
        if user:
            user.is_online = False
            db.commit()
        db.close()

    async def send_personal_message(self, message: str, user_id: int):
        if user_id in self.active_connections:
            await self.active_connections[user_id].send_text(message)

manager = ConnectionManager()

# API Endpoints

@app.post("/register", response_model=UserResponse)
async def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    # Check if username already exists
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    # Create new user
    db_user = User(username=user.username)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user

@app.get("/users", response_model=List[UserResponse])
async def get_users(db: Session = Depends(get_db)):
    """Get all registered users"""
    users = db.query(User).all()
    return users

@app.get("/messages/{user_id_1}/{user_id_2}", response_model=List[MessageResponse])
async def get_messages(user_id_1: int, user_id_2: int, db: Session = Depends(get_db)):
    """Get chat history between two users"""
    messages = db.query(Message).filter(
        or_(
            and_(Message.sender_id == user_id_1, Message.receiver_id == user_id_2),
            and_(Message.sender_id == user_id_2, Message.receiver_id == user_id_1)
        )
    ).order_by(Message.timestamp).all()
    
    return messages

@app.post("/upload", response_model=FileUploadResponse)
async def upload_file(file: UploadFile = File(...)):
    """Upload a file and return the file path"""
    # Generate unique filename
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = f"uploads/{unique_filename}"
    
    # Save file
    async with aiofiles.open(file_path, 'wb') as f:
        content = await file.read()
        await f.write(content)
    
    return FileUploadResponse(
        filename=file.filename,
        file_path=unique_filename,
        message="File uploaded successfully"
    )

@app.get("/files/{file_name}")
async def get_file(file_name: str):
    """Serve uploaded files"""
    file_path = f"uploads/{file_name}"
    if os.path.exists(file_path):
        return FileResponse(file_path)
    else:
        raise HTTPException(status_code=404, detail="File not found")

@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    """WebSocket endpoint for real-time messaging"""
    await manager.connect(websocket, user_id)
    db = next(get_db())
    
    try:
        while True:
            # Receive message from client
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            # Validate message data
            ws_message = WebSocketMessage(**message_data)
            
            # Save message to database
            db_message = Message(
                sender_id=user_id,
                receiver_id=ws_message.to,
                message_type=ws_message.type,
                content=ws_message.content
            )
            db.add(db_message)
            db.commit()
            db.refresh(db_message)
            
            # Get sender and receiver info
            sender = db.query(User).filter(User.id == user_id).first()
            receiver = db.query(User).filter(User.id == ws_message.to).first()
            
            # Prepare message for forwarding
            forward_message = {
                "id": db_message.id,
                "sender_id": user_id,
                "receiver_id": ws_message.to,
                "message_type": ws_message.type,
                "content": ws_message.content,
                "timestamp": db_message.timestamp.isoformat(),
                "sender": {
                    "id": sender.id,
                    "username": sender.username,
                    "is_online": sender.is_online
                }
            }
            
            # Send message to receiver if online
            await manager.send_personal_message(
                json.dumps(forward_message), 
                ws_message.to
            )
            
    except WebSocketDisconnect:
        manager.disconnect(user_id)
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(user_id)
    finally:
        db.close()

@app.get("/")
async def root():
    return {"message": "Local Network Messaging API is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
