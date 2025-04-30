from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, String, JSON
from sqlalchemy.orm import relationship

class CoeficienteReparto(Base):
    __tablename__ = 'COEFICIENTE_REPARTO'
    
    idCoeficienteReparto = Column(Integer, primary_key=True, autoincrement=True)
    tipoReparto = Column(String, nullable=False)
    parametros = Column(JSON, nullable=False)
    idParticipante = Column(Integer, ForeignKey("PARTICIPANTE.idParticipante"), nullable=False)
    
    # Relación con el participante
    participante = relationship("Participante", back_populates="coeficientes_reparto")