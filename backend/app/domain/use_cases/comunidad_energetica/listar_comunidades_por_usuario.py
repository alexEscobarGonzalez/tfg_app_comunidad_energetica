from sqlalchemy.orm import Session
from typing import List
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository
from fastapi import HTTPException

def listar_comunidades_por_usuario_use_case(id_usuario: int, db: Session) -> List[ComunidadEnergeticaEntity]:
    # Verificar que el usuario existe
    usuario_repo = SqlAlchemyUsuarioRepository(db)
    usuario = usuario_repo.get_by_id(id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Buscar las comunidades asociadas al usuario
    repo = SqlAlchemyComunidadEnergeticaRepository(db)
    return repo.get_by_usuario(id_usuario)