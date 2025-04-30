# backend/app/infrastructure/persistance/models/datos_ambientales_tabla.py

from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class DatosAmbientales(Base):
    __tablename__ = 'DATOS_AMBIENTALES'

    idRegistro = Column(Integer, primary_key=True, autoincrement=True)
    timestamp = Column(DateTime, nullable=False)
    fuenteDatos = Column(String(100))
    radiacionGlobalHoriz_Wh_m2 = Column(Float)
    temperaturaAmbiente_C = Column(Float)
    velocidadViento_m_s = Column(Float)
    idSimulacion = Column(Integer, ForeignKey("SIMULACION.idSimulacion", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)

    simulacion = relationship("Simulacion", back_populates="datos_ambientales") 