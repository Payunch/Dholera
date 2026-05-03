import sys
from pathlib import Path
from pydantic import EmailStr

ROOT_DIR = Path(__file__).resolve().parents[0]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from app.db.session import SessionLocal
from app.models.user import User
from app.api.routes.auth import login
from app.schemas.auth import LoginRequest
from sqlalchemy import select

def test():
    db = SessionLocal()
    try:
        user = db.scalar(select(User).where(User.email == "admin@example.com"))
        if not user:
            print("User not found")
            return
        
        print(f"Found user: {user.email}")
        
        # Test login function
        try:
            payload = LoginRequest(email="admin@example.com", password="ChangeMe123!")
            result = login(payload, db)
            print("Login successful!")
            print(f"Access Token: {result.access_token[:10]}...")
        except Exception as e:
            print(f"Login failed: {e}")
            
    finally:
        db.close()

if __name__ == "__main__":
    test()
