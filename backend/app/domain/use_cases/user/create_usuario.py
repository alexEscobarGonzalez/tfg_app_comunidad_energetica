from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository

usuario_repo = SqlAlchemyUsuarioRepository()

def crear_usuario_use_case(usuario: UsuarioEntity, db: Session) -> UsuarioEntity:
    if usuario_repo.get_by_email(db, usuario.correo):
        raise HTTPException(status_code=400, detail="El correo ya está registrado")
    return usuario_repo.create(db, usuario)
