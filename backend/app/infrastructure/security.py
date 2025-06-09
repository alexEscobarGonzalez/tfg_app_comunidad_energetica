# filepath: backend/app/infrastructure/security.py
from datetime import datetime, timedelta
from jose import jwt
import os

SECRET_KEY = os.getenv("SECRET_KEY", "TU_SECRET_KEY_GENERADA_ALEATORIAMENTE")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# filepath: backend/app/infrastructure/security.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_token import TokenData

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="usuarios/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No autorizado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        token_data = TokenData(**payload)
        if token_data.sub is None:
            raise credentials_exception
        user = SqlAlchemyUsuarioRepository(db).get_by_id(int(token_data.sub))
        if user is None:
            raise credentials_exception
        return user
    except JWTError:
        raise credentials_exception