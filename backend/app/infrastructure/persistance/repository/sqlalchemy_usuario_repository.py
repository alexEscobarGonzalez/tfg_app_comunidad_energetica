from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.models.usuario_tabla import Usuario as UsuarioModel
from app.domain.repositories.usuario_repository import UsuarioRepository

class SqlAlchemyUsuarioRepository(UsuarioRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: UsuarioModel) -> UsuarioEntity:
        """Convierte un modelo de tabla a una entidad de dominio"""
        return UsuarioEntity(
            idUsuario=model.idUsuario, 
            nombre=model.nombre, 
            correo=model.correo, 
            hashContrasena=model.hashContrasena
        )

    def get_by_id(self, user_id: int) -> Optional[UsuarioEntity]:
        model = self.db.query(UsuarioModel).filter(UsuarioModel.idUsuario == user_id).first()
        if model:
            return self._map_to_entity(model)
        return None

    def get_by_email(self, email: str) -> Optional[UsuarioEntity]:
        model = self.db.query(UsuarioModel).filter(UsuarioModel.correo == email).first()
        if model:
            return self._map_to_entity(model)
        return None

    def list(self, skip: int = 0, limit: int = 100) -> List[UsuarioEntity]:
        models = self.db.query(UsuarioModel).offset(skip).limit(limit).all()
        return [self._map_to_entity(model) for model in models]

    def create(self, user: UsuarioEntity) -> UsuarioEntity:
        model = UsuarioModel(
            nombre=user.nombre, 
            correo=user.correo, 
            hashContrasena=user.hashContrasena
        )
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)

    def update(self, user_id: int, user: UsuarioEntity) -> UsuarioEntity:
        model = self.db.query(UsuarioModel).filter(UsuarioModel.idUsuario == user_id).first()
        if not model:
            return None
        model.nombre = user.nombre
        model.correo = user.correo
        model.hashContrasena = user.hashContrasena
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)

    def delete(self, user_id: int) -> None:
        model = self.db.query(UsuarioModel).filter(UsuarioModel.idUsuario == user_id).first()
        if model:
            self.db.delete(model)
            self.db.commit()
