from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.interfaces.schemas_usuario import UsuarioCreate, UsuarioRead, UsuarioLogin
from app.domain.entities.usuario import UsuarioEntity
from app.infrastructure.persistance.repository.sqlalchemy_usuario_repository import SqlAlchemyUsuarioRepository
from app.infrastructure.persistance.database import get_db
from sqlalchemy.orm import Session
from app.domain.use_cases.user.crear_usuario import crear_usuario_use_case
from app.domain.use_cases.user.autenticar_usuario import autenticar_usuario_use_case
from app.domain.use_cases.comunidad_energetica.listar_comunidades_por_usuario import listar_comunidades_por_usuario_use_case
from app.interfaces.schemas_comunidad_energetica import ComunidadEnergeticaRead
from fastapi.security import OAuth2PasswordRequestForm
from app.interfaces.schemas_token import Token
from app.infrastructure.security import create_access_token

router = APIRouter(prefix="/usuarios", tags=["usuarios"])

@router.post("",  response_model=Token)
def crear_usuario(usuario: UsuarioCreate, db: Session = Depends(get_db)):
    user_entity = UsuarioEntity(nombre=usuario.nombre, correo=usuario.correo, hashContrasena=usuario.hashContrasena)
    nuevo_usuario = crear_usuario_use_case(user_entity, db)
    access_token = create_access_token({"sub": str(nuevo_usuario.idUsuario)})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "usuario": UsuarioRead(
            idUsuario=nuevo_usuario.idUsuario,
            nombre=nuevo_usuario.nombre,
            correo=nuevo_usuario.correo
        )
    }

@router.post("/login", response_model=Token)
def login(usuario: UsuarioLogin, db: Session = Depends(get_db)):
    user = autenticar_usuario_use_case(usuario.correo, usuario.contrasena, db)
    access_token = create_access_token({"sub": str(user.idUsuario)})
    reponse = {
        "access_token": access_token,
        "token_type": "bearer",
        "usuario": UsuarioRead(
            idUsuario=user.idUsuario,
            nombre=user.nombre,
            correo=user.correo
        )
    }
    return reponse

@router.get("/{id_usuario}/comunidades", response_model=List[ComunidadEnergeticaRead])
def listar_comunidades_usuario(id_usuario: int, db: Session = Depends(get_db)):
    """
    Obtiene todas las comunidades energéticas asociadas a un usuario específico.
    """
    comunidades = listar_comunidades_por_usuario_use_case(id_usuario, db)
    return [
        ComunidadEnergeticaRead(
            idComunidadEnergetica=c.idComunidadEnergetica,
            nombre=c.nombre,
            latitud=c.latitud,
            longitud=c.longitud,
            tipoEstrategiaExcedentes=c.tipoEstrategiaExcedentes,
            idUsuario=c.idUsuario
        ) for c in comunidades
    ]

@router.get("", response_model=List[UsuarioRead])
def listar_usuarios(db: Session = Depends(get_db)):
    """
    Obtiene todos los usuarios.
    """
    usuario_repo = SqlAlchemyUsuarioRepository(db)
    usuarios = usuario_repo.list()
    return [UsuarioRead(idUsuario=u.idUsuario, nombre=u.nombre, correo=u.correo) for u in usuarios]