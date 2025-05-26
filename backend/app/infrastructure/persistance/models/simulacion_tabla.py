from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class Simulacion(Base):
    __tablename__ = "SIMULACION"
    
    idSimulacion = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombreSimulacion = Column(String(255))
    fechaInicio = Column(DateTime, nullable=False)
    fechaFin = Column(DateTime, nullable=False)
    tiempo_medicion = Column(Integer)  
    estado = Column(String(50))  
    tipoEstrategiaExcedentes = Column(String(100))  
    idUsuario_creador = Column(Integer, ForeignKey("USUARIO.idUsuario", ondelete="RESTRICT", onupdate="CASCADE"), nullable=False)
    idComunidadEnergetica = Column(Integer, ForeignKey("COMUNIDAD_ENERGETICA.idComunidadEnergetica", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    
    # Relaciones
    usuario = relationship("Usuario")
    comunidad = relationship("ComunidadEnergetica")
    resultado = relationship("ResultadoSimulacion", back_populates="simulacion", uselist=False, cascade="all, delete-orphan")
    datos_ambientales = relationship("DatosAmbientales", back_populates="simulacion", cascade="all, delete-orphan")