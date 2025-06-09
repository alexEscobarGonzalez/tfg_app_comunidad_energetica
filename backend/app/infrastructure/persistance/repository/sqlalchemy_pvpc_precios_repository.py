from typing import Optional, List
from datetime import datetime
from sqlalchemy.orm import Session
from app.domain.repositories.pvpc_precios_repository import PvpcPreciosRepository
from app.domain.entities.pvpc_precios import PvpcPreciosEntity
from app.infrastructure.persistance.models.pvpc_precios_tabla import PvpcPrecios

class PvpcPreciosRepositoryImpl(PvpcPreciosRepository):
    """
    Implementación del repositorio para acceder a los precios PVPC en base de datos
    """
    
    def __init__(self, db_session: Session):
        self.db_session = db_session
    
    def get_precio_by_timestamp(self, timestamp: datetime) -> Optional[PvpcPreciosEntity]:
        """
        Obtiene el precio PVPC para un timestamp específico
        """
        result = self.db_session.query(PvpcPrecios).filter(
            PvpcPrecios.timestamp == timestamp
        ).first()
        
        if result:
            return PvpcPreciosEntity(
                id=result.id,
                timestamp=result.timestamp,
                precio_importacion=result.precio_importacion,
                precio_exportacion=result.precio_exportacion
            )
        return None
    
    def get_precios_range(self, fecha_inicio: datetime, fecha_fin: datetime) -> List[PvpcPreciosEntity]:
        """
        Obtiene todos los precios PVPC en un rango de fechas
        """
        results = self.db_session.query(PvpcPrecios).filter(
            PvpcPrecios.timestamp >= fecha_inicio,
            PvpcPrecios.timestamp <= fecha_fin
        ).order_by(PvpcPrecios.timestamp).all()
        
        return [
            PvpcPreciosEntity(
                id=result.id,
                timestamp=result.timestamp,
                precio_importacion=result.precio_importacion,
                precio_exportacion=result.precio_exportacion
            )
            for result in results
        ] 