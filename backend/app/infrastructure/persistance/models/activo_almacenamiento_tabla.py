from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, Float, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

class ActivoAlmacenamiento(Base):
    __tablename__ = 'ACTIVO_ALMACENAMIENTO'
    
    idActivoAlmacenamiento = Column(Integer, primary_key=True, autoincrement=True)
    nombreDescriptivo = Column(String(255), nullable=False)
    capacidadNominal_kWh = Column(Float, nullable=False)
    potenciaMaximaCarga_kW = Column(Float, nullable=False)
    potenciaMaximaDescarga_kW = Column(Float, nullable=False)
    eficienciaCicloCompleto_pct = Column(Float, nullable=False)
    profundidadDescargaMax_pct = Column(Float, nullable=False)
    idComunidadEnergetica = Column(Integer, ForeignKey("COMUNIDAD_ENERGETICA.idComunidadEnergetica"), nullable=False)
    
    # Campos para soft delete
    esta_activo = Column(Boolean, default=True, nullable=False)
    fecha_eliminacion = Column(DateTime, nullable=True)
    
    # Relaciónes
    comunidad = relationship("ComunidadEnergetica", back_populates="activos_almacenamiento")
    resultados_simulacion = relationship("ResultadoSimulacionActivoAlmacenamiento", back_populates="activo_almacenamiento")