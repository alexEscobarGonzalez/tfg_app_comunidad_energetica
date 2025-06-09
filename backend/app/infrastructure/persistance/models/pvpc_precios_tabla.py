from app.infrastructure.persistance.database import Base
from sqlalchemy import Column, Integer, DateTime, Float, Index

class PvpcPrecios(Base):
    """
    Tabla para almacenar los precios PVPC (Precio Voluntario para el Pequeño Consumidor)
    Incluye precios de importación y exportación de energía
    """
    __tablename__ = 'PVPC_PRECIOS'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    timestamp = Column(DateTime, nullable=False, unique=True)
    precio_importacion = Column(Float, nullable=False)  # Precio de compra €/kWh
    precio_exportacion = Column(Float, nullable=True)   # Precio de venta/compensación €/kWh
    
    # Índice para mejorar búsquedas por fecha
    __table_args__ = (
        Index('idx_pvpc_timestamp', 'timestamp'),
    ) 