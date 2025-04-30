from sqlalchemy import Column, ForeignKey, Integer, Float, DateTime
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class RegistroConsumo(Base):
    __tablename__ = 'REGISTRO_CONSUMO'
    
    idRegistroConsumo = Column(Integer, primary_key=True, autoincrement=True)
    timestamp = Column(DateTime, nullable=False)
    consumoEnergia = Column(Float, nullable=False)
    idParticipante = Column(Integer, ForeignKey("PARTICIPANTE.idParticipante"), nullable=False)
    
    # Relación con el participante
    participante = relationship("Participante", back_populates="registros_consumo")