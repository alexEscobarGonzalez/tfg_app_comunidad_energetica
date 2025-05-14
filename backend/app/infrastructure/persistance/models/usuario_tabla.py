from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class Usuario(Base):
    __tablename__ = "USUARIO"
    idUsuario = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre = Column(String(255), nullable=False)
    correo = Column(String(255), nullable=False, unique=True)
    hashContrasena = Column(String(255), nullable=False)
    
    # Relaciones
    simulaciones = relationship("Simulacion", back_populates="usuario", cascade="all, delete-orphan")
    comunidades = relationship('ComunidadEnergetica', back_populates='usuario', cascade="all, delete-orphan")
