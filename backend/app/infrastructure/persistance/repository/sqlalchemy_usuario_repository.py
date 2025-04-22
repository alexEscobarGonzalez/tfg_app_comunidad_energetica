from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.models.user import Usuario
from app.domain.repositories.usuario_repository import UsuarioRepository

class SqlAlchemyUsuarioRepository(UsuarioRepository):
    def get_by_id(self, db: Session, user_id: int) -> Optional[UsuarioEntity]:
        user = db.query(Usuario).filter(Usuario.idUsuario == user_id).first()
        if user:
            return UsuarioEntity(idUsuario=user.idUsuario, nombre=user.nombre, correo=user.correo, hashContrasena=user.hashContrasena)
        return None

    def get_by_email(self, db: Session, email: str) -> Optional[UsuarioEntity]:
        user = db.query(Usuario).filter(Usuario.correo == email).first()
        if user:
            return UsuarioEntity(idUsuario=user.idUsuario, nombre=user.nombre, correo=user.correo, hashContrasena=user.hashContrasena)
        return None

    def list(self, db: Session, skip: int = 0, limit: int = 100) -> List[UsuarioEntity]:
        users = db.query(Usuario).offset(skip).limit(limit).all()
        return [UsuarioEntity(idUsuario=u.idUsuario, nombre=u.nombre, correo=u.correo, hashContrasena=u.hashContrasena) for u in users]

    def create(self, db: Session, user: UsuarioEntity) -> UsuarioEntity:
        db_user = Usuario(nombre=user.nombre, correo=user.correo, hashContrasena=user.hashContrasena)
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return UsuarioEntity(idUsuario=db_user.idUsuario, nombre=db_user.nombre, correo=db_user.correo, hashContrasena=db_user.hashContrasena)

    def update(self, db: Session, user_id: int, user: UsuarioEntity) -> UsuarioEntity:
        db_user = db.query(Usuario).filter(Usuario.idUsuario == user_id).first()
        if not db_user:
            return None
        db_user.nombre = user.nombre
        db_user.correo = user.correo
        db_user.hashContrasena = user.hashContrasena
        db.commit()
        db.refresh(db_user)
        return UsuarioEntity(idUsuario=db_user.idUsuario, nombre=db_user.nombre, correo=db_user.correo, hashContrasena=db_user.hashContrasena)

    def delete(self, db: Session, user_id: int) -> None:
        db_user = db.query(Usuario).filter(Usuario.idUsuario == user_id).first()
        if db_user:
            db.delete(db_user)
            db.commit()
