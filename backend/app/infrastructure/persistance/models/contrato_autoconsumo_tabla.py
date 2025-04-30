from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, String, Float, Enum, UniqueConstraint
from sqlalchemy.orm import relationship
from app.domain.entities.tipo_contrato import TipoContrato

class ContratoAutoconsumo(Base):
    __tablename__ = 'CONTRATO_AUTOCONSUMO'
    
    idContrato = Column(Integer, primary_key=True, autoincrement=True)
    tipoContrato = Column(Enum(TipoContrato), nullable=False)
    precioEnergiaImportacion_eur_kWh = Column(Float, nullable=False)
    precioCompensacionExcedentes_eur_kWh = Column(Float, nullable=False)
    potenciaContratada_kW = Column(Float, nullable=False)
    precioPotenciaContratado_eur_kWh = Column(Float, nullable=False)
    idParticipante = Column(Integer, ForeignKey("PARTICIPANTE.idParticipante"), nullable=False, unique=True)
    
    # Relación con Participante
    participante = relationship("Participante", back_populates="contrato")
    
    __table_args__ = (
        UniqueConstraint('idParticipante', name='uq_contrato_participante'),
    )