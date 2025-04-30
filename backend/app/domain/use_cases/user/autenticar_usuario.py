from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository
import bcrypt

def autenticar_usuario_use_case(correo: str, contrasena: str, db: Session) -> UsuarioEntity:
    usuario_repo = SqlAlchemyUsuarioRepository(db)
    usuario = usuario_repo.get_by_email(correo)
    if not usuario:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")
    # Verificar contraseña
    if not bcrypt.checkpw(contrasena.encode('utf-8'), usuario.hashContrasena.encode('utf-8')):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")
    return usuario
