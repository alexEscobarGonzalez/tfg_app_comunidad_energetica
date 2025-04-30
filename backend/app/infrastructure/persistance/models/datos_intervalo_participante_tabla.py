from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.infrastructure.persistance.database import Base

class DatosIntervaloParticipante(Base):
    __tablename__ = "DATOS_INTERVALO_PARTICIPANTE"
    
    idDatosIntervaloParticipante = Column(Integer, primary_key=True, autoincrement=True)
    timestamp = Column(DateTime, nullable=False)
    consumoReal_kWh = Column(Float)
    produccionPropia_kWh = Column(Float)
    energiaRecibidaReparto_kWh = Column(Float)
    energiaDesdeAlmacenamientoInd_kWh = Column(Float)
    energiaHaciaAlmacenamientoInd_kWh = Column(Float)
    energiaDesdeRed_kWh = Column(Float)
    excedenteVertidoCompensado_kWh = Column(Float)
    excedenteVertidoVendido_kWh = Column(Float)
    estadoAlmacenamientoInd_kWh = Column(Float)
    precioImportacionIntervalo = Column(Float)
    precioExportacionIntervalo = Column(Float)
    idResultadoParticipante = Column(Integer, ForeignKey("RESULTADO_SIMULACION_PARTICIPANTE.idResultadoParticipante", ondelete="CASCADE"), nullable=False)
    
    # Relación con el resultado de la simulación del participante
    resultado_simulacion_participante = relationship("ResultadoSimulacionParticipante", back_populates="datos_intervalos_participante")
    
