from dataclasses import dataclass

@dataclass
class UsuarioEntity:
    idUsuario: int = None
    nombre: str = None
    correo: str = None
    hashContrasena: str = None
