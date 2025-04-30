from sqlalchemy import Column, Integer, Float, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class ResultadoSimulacionActivoAlmacenamiento(Base):
    __tablename__ = "RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO"
    
    idResultadoActivoAlm = Column(Integer, primary_key=True, autoincrement=True)
    energiaTotalCargada_kWh = Column(Float)
    energiaTotalDescargada_kWh = Column(Float)
    ciclosEquivalentes = Column(Float)
    perdidasEficiencia_kWh = Column(Float)
    socMedio_pct = Column(Float)
    socMin_pct = Column(Float)
    socMax_pct = Column(Float)
    degradacionEstimada_pct = Column(Float)
    throughputTotal_kWh = Column(Float)
    idResultadoSimulacion = Column(Integer, ForeignKey("RESULTADO_SIMULACION.idResultado", ondelete="CASCADE"))
    idActivoAlmacenamiento = Column(Integer, ForeignKey("ACTIVO_ALMACENAMIENTO.idActivoAlmacenamiento", ondelete="CASCADE"))
    
    # Relaciones
    resultado_simulacion = relationship("ResultadoSimulacion", back_populates="resultados_activos_alm")
    activo_almacenamiento = relationship("ActivoAlmacenamiento", back_populates="resultados_simulacion")
    
    # Relación con los datos de intervalo (nueva relación)
    datos_intervalos = relationship("DatosIntervaloActivo", back_populates="resultado_activo_alm", cascade="all, delete-orphan")
    
    # Restricción única para evitar duplicados
    __table_args__ = (
        UniqueConstraint('idResultadoSimulacion', 'idActivoAlmacenamiento', name='uq_resultado_sim_activo_alm'),
    )