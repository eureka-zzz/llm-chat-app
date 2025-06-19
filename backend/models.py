from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

# User models
class UserCreate(BaseModel):
    username: str

class UserResponse(BaseModel):
    id: int
    username: str
    is_online: bool
    
    class Config:
        from_attributes = True

# Message models
class MessageCreate(BaseModel):
    receiver_id: int
    message_type: str
    content: str

class MessageResponse(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    message_type: str
    content: str
    timestamp: datetime
    sender: UserResponse
    receiver: UserResponse
    
    class Config:
        from_attributes = True

# WebSocket message model
class WebSocketMessage(BaseModel):
    to: int
    type: str
    content: str

# File upload response
class FileUploadResponse(BaseModel):
    filename: str
    file_path: str
    message: str
