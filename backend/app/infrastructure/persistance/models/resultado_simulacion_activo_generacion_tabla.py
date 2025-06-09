from sqlalchemy import Column, Integer, Float, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class ResultadoSimulacionActivoGeneracion(Base):
    __tablename__ = "RESULTADO_SIMULACION_ACTIVO_GENERACION"
    
    idResultadoActivoGen = Column(Integer, primary_key=True, autoincrement=True)
    energiaTotalGenerada_kWh = Column(Float)
    factorCapacidad_pct = Column(Float)
    performanceRatio_pct = Column(Float)
    horasOperacionEquivalentes = Column(Float)
    idResultadoSimulacion = Column(Integer, ForeignKey("RESULTADO_SIMULACION.idResultado", ondelete="CASCADE"))
    idActivoGeneracion = Column(Integer, ForeignKey("ACTIVO_GENERACION_UNICA.idActivoGeneracion", ondelete="SET NULL"), nullable=True)
    
    # Relaciones
    resultado_simulacion = relationship("ResultadoSimulacion", back_populates="resultados_activo_generacion")
    activo_generacion = relationship("ActivoGeneracion", back_populates="resultados_simulacion")
    
    # Relación con los datos de intervalo (nueva relación)
    datos_intervalos = relationship("DatosIntervaloActivo", back_populates="resultado_activo_gen", cascade="all, delete-orphan")
    
    # Restricción única para evitar duplicados
    __table_args__ = (
        UniqueConstraint('idResultadoSimulacion', 'idActivoGeneracion', name='uq_resultado_sim_activo_gen'),
    )