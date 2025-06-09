from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class DatosIntervaloActivo(Base):
    __tablename__ = "DATOS_INTERVALO_ACTIVO"
    
    idDatosIntervaloActivo = Column(Integer, primary_key=True, autoincrement=True)
    timestamp = Column(DateTime, nullable=False)
    energiaGenerada_kWh = Column(Float, nullable=True)
    energiaCargada_kWh = Column(Float, nullable=True)
    energiaDescargada_kWh = Column(Float, nullable=True)
    SoC_kWh = Column(Float, nullable=True)
    idResultadoActivoGen = Column(Integer, ForeignKey("RESULTADO_SIMULACION_ACTIVO_GENERACION.idResultadoActivoGen", ondelete="CASCADE"), nullable=True)
    idResultadoActivoAlm = Column(Integer, ForeignKey("RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO.idResultadoActivoAlm", ondelete="CASCADE"), nullable=True)
    
    # Relaciones con los resultados de simulación de activos
    resultado_activo_gen = relationship("ResultadoSimulacionActivoGeneracion", back_populates="datos_intervalos")
    resultado_activo_alm = relationship("ResultadoSimulacionActivoAlmacenamiento", back_populates="datos_intervalos")
    
    # Índices para mejorar las búsquedas
    __table_args__ = (
        Index('idx_intervalo_activo_timestamp', 'timestamp'),
        Index('idx_intervalo_activo_gen', 'idResultadoActivoGen', 'timestamp'),
        Index('idx_intervalo_activo_alm', 'idResultadoActivoAlm', 'timestamp'),
    )