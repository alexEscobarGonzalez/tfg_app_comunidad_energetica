from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

class Participante(Base):
    __tablename__ = 'PARTICIPANTE'
    idParticipante = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(255), nullable=False)
    idComunidadEnergetica = Column(Integer, ForeignKey("COMUNIDAD_ENERGETICA.idComunidadEnergetica"), nullable=False)
    
    # Relaciones
    comunidad = relationship("ComunidadEnergetica", back_populates="participantes")
    resultados_simulacion = relationship("ResultadoSimulacionParticipante", back_populates="participante", cascade="all, delete-orphan")
    contrato = relationship("ContratoAutoconsumo", back_populates="participante", uselist=False, cascade="all, delete-orphan")
    coeficiente_reparto = relationship("CoeficienteReparto", back_populates="participante", uselist=False, cascade="all, delete-orphan")
    registros_consumo = relationship("RegistroConsumo", back_populates="participante", cascade="all, delete-orphan")