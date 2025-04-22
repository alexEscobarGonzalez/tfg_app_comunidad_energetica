from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.interfaces.schemas import UsuarioCreate, UsuarioRead
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository
from app.infrastructure.persistance.database import get_db
from sqlalchemy.orm import Session
from app.domain.use_cases.user.create_usuario import crear_usuario_use_case

router = APIRouter(prefix="/usuarios", tags=["usuarios"])

usuario_repo = SqlAlchemyUsuarioRepository()

@router.post("/", response_model=UsuarioRead)
def crear_usuario(usuario: UsuarioCreate, db: Session = Depends(get_db)):
    user_entity = UsuarioEntity(nombre=usuario.nombre, correo=usuario.correo, hashContrasena=usuario.hashContrasena)
    nuevo_usuario = crear_usuario_use_case(user_entity, db)
    return UsuarioRead(idUsuario=nuevo_usuario.idUsuario, nombre=nuevo_usuario.nombre, correo=nuevo_usuario.correo)