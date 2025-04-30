from sqlalchemy import Column, Integer, Float, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class ResultadoSimulacionParticipante(Base):
    __tablename__ = 'RESULTADO_SIMULACION_PARTICIPANTE'

    idResultadoParticipante = Column(Integer, primary_key=True, autoincrement=True)
    costeNetoParticipante_eur = Column(Float, nullable=True)
    ahorroParticipante_eur = Column(Float, nullable=True)
    ahorroParticipante_pct = Column(Float, nullable=True)
    energiaAutoconsumidaDirecta_kWh = Column(Float, nullable=True)
    energiaRecibidaRepartoConsumida_kWh = Column(Float, nullable=True)
    tasaAutoconsumoSCR_pct = Column(Float, nullable=True)
    tasaAutosuficienciaSSR_pct = Column(Float, nullable=True)
    idResultadoSimulacion = Column(Integer, ForeignKey("RESULTADO_SIMULACION.idResultado", ondelete="CASCADE"), nullable=False)
    idParticipante = Column(Integer, ForeignKey("PARTICIPANTE.idParticipante", ondelete="CASCADE"), nullable=False)

    resultado_simulacion = relationship("ResultadoSimulacion") 
    participante = relationship("Participante") 
    datos_intervalos_participante = relationship("DatosIntervaloParticipante", back_populates="resultado_simulacion_participante", cascade="all, delete-orphan")
