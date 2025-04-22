from typing import List, Optional
from app.domain.entities.usuario import UsuarioEntity

class UsuarioRepository:
    def get_by_id(self, db, user_id: int) -> Optional[UsuarioEntity]:
        raise NotImplementedError
    def get_by_email(self, db, email: str) -> Optional[UsuarioEntity]:
        raise NotImplementedError
    def list(self, db, skip: int = 0, limit: int = 100) -> List[UsuarioEntity]:
        raise NotImplementedError
    def create(self, db, user: UsuarioEntity) -> UsuarioEntity:
        raise NotImplementedError
    def update(self, db, user_id: int, user: UsuarioEntity) -> UsuarioEntity:
        raise NotImplementedError
    def delete(self, db, user_id: int) -> None:
        raise NotImplementedError
