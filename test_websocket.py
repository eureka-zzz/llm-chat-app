#!/usr/bin/env python3
import asyncio
import websockets
import json

async def test_websocket():
    uri = "ws://82298cb6fbaf643872.blackbx.ai/ws/2"
    
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to WebSocket")
            
            # Send a test message
            message = {
                "to": 3,
                "type": "text",
                "content": "Hello from WebSocket test!"
            }
            
            await websocket.send(json.dumps(message))
            print(f"Sent message: {message}")
            
            # Listen for responses
            try:
                response = await asyncio.wait_for(websocket.recv(), timeout=5.0)
                print(f"Received: {response}")
            except asyncio.TimeoutError:
                print("No response received within timeout")
                
    except Exception as e:
        print(f"WebSocket error: {e}")

if __name__ == "__main__":
    asyncio.run(test_websocket())
