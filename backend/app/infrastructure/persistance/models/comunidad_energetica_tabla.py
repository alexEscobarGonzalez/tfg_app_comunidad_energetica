from app.infrastructure.persistance.models.usuario_tabla import Usuario          
from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, String, Float, Enum
from sqlalchemy.orm import relationship
from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes

class ComunidadEnergetica(Base):
    __tablename__ = 'COMUNIDAD_ENERGETICA'
    idComunidadEnergetica = Column(Integer, primary_key=True, autoincrement=True)
    idUsuario = Column('idUsuario_gestor',Integer, ForeignKey("USUARIO.idUsuario"), nullable=False)
    nombre = Column(String, nullable=False)
    latitud = Column(Float, nullable=False)
    longitud = Column(Float, nullable=False)
    tipoEstrategiaExcedentes = Column(Enum(TipoEstrategiaExcedentes), nullable=False)
    usuario = relationship(Usuario, back_populates='comunidades')
    participantes = relationship("Participante", back_populates='comunidad', cascade="all, delete-orphan")
    simulaciones = relationship("Simulacion", back_populates='comunidad', cascade="all, delete-orphan")
    activos_generacion = relationship("ActivoGeneracion", back_populates='comunidad', cascade="all, delete-orphan")
    activos_almacenamiento = relationship("ActivoAlmacenamiento", back_populates='comunidad', cascade="all, delete-orphan")
