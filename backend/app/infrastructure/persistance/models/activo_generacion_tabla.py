from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, String, Float, Date, Enum, JSON, Boolean, DateTime
from sqlalchemy.orm import relationship
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from datetime import datetime

class ActivoGeneracion(Base):
    __tablename__ = 'ACTIVO_GENERACION_UNICA'
    
    # Campos comunes para todos los tipos de activos
    idActivoGeneracion = Column(Integer, primary_key=True, autoincrement=True)
    nombreDescriptivo = Column(String(255), nullable=False)
    fechaInstalacion = Column(Date, nullable=False)
    costeInstalacion_eur = Column(Float, nullable=False)
    vidaUtil_anios = Column(Integer, nullable=False)
    latitud = Column(Float, nullable=False)
    longitud = Column(Float, nullable=False)
    potenciaNominal_kWp = Column(Float, nullable=False)
    idComunidadEnergetica = Column(Integer, ForeignKey("COMUNIDAD_ENERGETICA.idComunidadEnergetica"), nullable=False)
    tipo_activo = Column(Enum(TipoActivoGeneracion), nullable=False)
    
    # Campos específicos para INSTALACION_FOTOVOLTAICA (pueden ser nulos)
    inclinacionGrados = Column(Float, nullable=True)
    azimutGrados = Column(Float, nullable=True)
    tecnologiaPanel = Column(String(255), nullable=True)
    perdidaSistema = Column(Float, nullable=True)
    posicionMontaje = Column(String(255), nullable=True)
    
    # Campos específicos para AEROGENERADOR (pueden ser nulos)
    curvaPotencia = Column(JSON, nullable=True)  # Objeto JSON que describe la curva de potencia
    
    # Campos para soft delete
    esta_activo = Column(Boolean, default=True, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Relaciones
    comunidad = relationship("ComunidadEnergetica", back_populates="activos_generacion")
    # Cambio: sin cascada para preservar resultados históricos
    resultados_simulacion = relationship("ResultadoSimulacionActivoGeneracion", back_populates="activo_generacion")

