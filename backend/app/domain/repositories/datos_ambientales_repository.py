from typing import List, Optional
from datetime import datetime
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity

class DatosAmbientalesRepository:
    def get_by_id(self, idRegistro: int) -> Optional[DatosAmbientalesEntity]:
        raise NotImplementedError

    def get_by_simulacion(self, idSimulacion: int) -> List[DatosAmbientalesEntity]:
        raise NotImplementedError

    def get_by_simulacion_and_periodo(self, idSimulacion: int, fecha_inicio: datetime, fecha_fin: datetime) -> List[DatosAmbientalesEntity]:
        raise NotImplementedError

    def list(self) -> List[DatosAmbientalesEntity]:
        raise NotImplementedError

    def create(self, datos: DatosAmbientalesEntity) -> DatosAmbientalesEntity:
        raise NotImplementedError

    def create_bulk(self, datos_list: List[DatosAmbientalesEntity]) -> List[DatosAmbientalesEntity]:
        raise NotImplementedError
    
    def get_datos_ambientales(self, lat: float, lon: float, start_date: datetime, end_date: datetime) -> List[DatosAmbientalesEntity]:
        raise NotImplementedError
    
