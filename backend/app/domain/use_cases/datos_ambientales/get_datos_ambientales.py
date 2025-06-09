from typing import List
from datetime import date
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository

class GetDatosAmbientalesUseCase:
    def __init__(self, repository: DatosAmbientalesRepository):
        self.repository = repository

    def execute(self, lat: float, lon: float, start_date: date, end_date: date) -> List[DatosAmbientalesEntity]:
        return self.repository.get_datos_ambientales(lat, lon, start_date, end_date)