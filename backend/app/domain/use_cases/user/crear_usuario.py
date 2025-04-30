from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository
import bcrypt

def crear_usuario_use_case(usuario: UsuarioEntity, db: Session) -> UsuarioEntity:
    usuario_repo = SqlAlchemyUsuarioRepository(db)
    if usuario_repo.get_by_email(usuario.correo):
        raise HTTPException(status_code=400, detail="El correo ya está registrado")
    # Encriptar la contraseña antes de guardar
    hashed = bcrypt.hashpw(usuario.hashContrasena.encode('utf-8'), bcrypt.gensalt())
    usuario.hashContrasena = hashed.decode('utf-8')
    return usuario_repo.create(usuario)
