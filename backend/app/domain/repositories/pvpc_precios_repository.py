from abc import ABC, abstractmethod
from typing import Optional, List
from datetime import datetime
from app.domain.entities.pvpc_precios import PvpcPreciosEntity

class PvpcPreciosRepository(ABC):
    
    @abstractmethod
    def get_precio_by_timestamp(self, timestamp: datetime) -> Optional[PvpcPreciosEntity]:
        pass
    
    @abstractmethod 
    def get_precios_range(self, fecha_inicio: datetime, fecha_fin: datetime) -> List[PvpcPreciosEntity]:
        pass 