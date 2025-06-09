from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.infrastructure.persistance.database import Base

class ResultadoSimulacion(Base):
    __tablename__ = "RESULTADO_SIMULACION"
    
    idResultado = Column(Integer, primary_key=True, index=True, autoincrement=True)
    fechaCreacion = Column(DateTime, default=func.current_timestamp())
    costeTotalEnergia_eur = Column(Float, nullable=True)
    ahorroTotal_eur = Column(Float, nullable=True)
    ingresoTotalExportacion_eur = Column(Float, nullable=True)
    paybackPeriod_anios = Column(Float, nullable=True)
    roi_pct = Column(Float, nullable=True)
    tasaAutoconsumoSCR_pct = Column(Float, nullable=True)
    tasaAutosuficienciaSSR_pct = Column(Float, nullable=True)
    energiaTotalImportada_kWh = Column(Float, nullable=True)
    energiaTotalExportada_kWh = Column(Float, nullable=True)
    reduccionCO2_kg = Column(Float, nullable=True)
    idSimulacion = Column(Integer, ForeignKey("SIMULACION.idSimulacion", ondelete="CASCADE"), nullable=False, unique=True)
    
    # Relaciones
    simulacion = relationship("Simulacion", back_populates="resultado")
    resultados_activos_alm = relationship("ResultadoSimulacionActivoAlmacenamiento", back_populates="resultado_simulacion", cascade="all, delete-orphan")
    resultados_activo_generacion = relationship("ResultadoSimulacionActivoGeneracion", back_populates="resultado_simulacion", cascade="all, delete-orphan")
    resultados_participante = relationship("ResultadoSimulacionParticipante", back_populates="resultado_simulacion", cascade="all, delete-orphan")