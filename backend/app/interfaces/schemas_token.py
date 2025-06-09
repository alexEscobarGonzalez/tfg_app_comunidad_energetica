# filepath: backend/app/interfaces/schemas_token.py
from pydantic import BaseModel
from app.interfaces.schemas_usuario import UsuarioRead

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    usuario: UsuarioRead = None

class TokenData(BaseModel):
    sub: str | None = None