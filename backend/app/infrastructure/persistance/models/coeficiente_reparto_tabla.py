from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, String, JSON, UniqueConstraint
from sqlalchemy.orm import relationship

class CoeficienteReparto(Base):
    __tablename__ = 'COEFICIENTE_REPARTO'
    
    idCoeficienteReparto = Column(Integer, primary_key=True, autoincrement=True)
    tipoReparto = Column(String, nullable=False)
    parametros = Column(JSON, nullable=False)
    idParticipante = Column(Integer, ForeignKey("PARTICIPANTE.idParticipante"), nullable=False, unique=True)
    
    # Relación con el participante
    participante = relationship("Participante", back_populates="coeficiente_reparto")
    
    # Restricción única para asegurar que cada participante solo tenga un coeficiente
    __table_args__ = (
        UniqueConstraint('idParticipante', name='uq_coeficiente_participante'),
    )