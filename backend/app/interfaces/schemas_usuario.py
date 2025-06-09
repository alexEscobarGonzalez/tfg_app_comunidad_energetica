from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import date

class UsuarioBase(BaseModel):
    nombre: str
    correo: str

class UsuarioCreate(UsuarioBase):
    hashContrasena: str

class UsuarioRead(UsuarioBase):
    idUsuario: int
    model_config = ConfigDict(from_attributes=True)

class UsuarioLogin(BaseModel):
    correo: str
    contrasena: str