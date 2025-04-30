from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import between

from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository
from app.infrastructure.persistance.models.datos_ambientales_tabla import DatosAmbientales

class SqlAlchemyDatosAmbientalesRepository(DatosAmbientalesRepository):
    def __init__(self, db: Session):
        self.db = db

    def _map_to_entity(self, model: DatosAmbientales) -> DatosAmbientalesEntity:
        return DatosAmbientalesEntity(
            idRegistro=model.idRegistro,
            timestamp=model.timestamp,
            fuenteDatos=model.fuenteDatos,
            radiacionGlobalHoriz_Wh_m2=model.radiacionGlobalHoriz_Wh_m2,
            temperaturaAmbiente_C=model.temperaturaAmbiente_C,
            velocidadViento_m_s=model.velocidadViento_m_s,
            idSimulacion=model.idSimulacion
        )

    def get_by_id(self, idRegistro: int) -> Optional[DatosAmbientalesEntity]:
        model = self.db.query(DatosAmbientales).filter_by(idRegistro=idRegistro).first()
        return self._map_to_entity(model) if model else None

    def get_by_simulacion(self, idSimulacion: int) -> List[DatosAmbientalesEntity]:
        models = self.db.query(DatosAmbientales).filter_by(idSimulacion=idSimulacion).order_by(DatosAmbientales.timestamp).all()
        return [self._map_to_entity(model) for model in models]

    def get_by_simulacion_and_periodo(self, idSimulacion: int, fecha_inicio: datetime, fecha_fin: datetime) -> List[DatosAmbientalesEntity]:
        models = self.db.query(DatosAmbientales).filter(
            DatosAmbientales.idSimulacion == idSimulacion,
            between(DatosAmbientales.timestamp, fecha_inicio, fecha_fin)
        ).order_by(DatosAmbientales.timestamp).all()
        return [self._map_to_entity(model) for model in models]

    def list(self) -> List[DatosAmbientalesEntity]:
        models = self.db.query(DatosAmbientales).order_by(DatosAmbientales.timestamp).all()
        return [self._map_to_entity(model) for model in models]

    def create(self, datos: DatosAmbientalesEntity) -> DatosAmbientalesEntity:
        model = DatosAmbientales(
            timestamp=datos.timestamp,
            fuenteDatos=datos.fuenteDatos,
            radiacionGlobalHoriz_Wh_m2=datos.radiacionGlobalHoriz_Wh_m2,
            temperaturaAmbiente_C=datos.temperaturaAmbiente_C,
            velocidadViento_m_s=datos.velocidadViento_m_s,
            idSimulacion=datos.idSimulacion
        )
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)

    def create_bulk(self, datos_list: List[DatosAmbientalesEntity]) -> List[DatosAmbientalesEntity]:
        models = [
            DatosAmbientales(
                timestamp=datos.timestamp,
                fuenteDatos=datos.fuenteDatos,
                radiacionGlobalHoriz_Wh_m2=datos.radiacionGlobalHoriz_Wh_m2,
                temperaturaAmbiente_C=datos.temperaturaAmbiente_C,
                velocidadViento_m_s=datos.velocidadViento_m_s,
                idSimulacion=datos.idSimulacion
            ) for datos in datos_list
        ]
        self.db.bulk_save_objects(models, return_defaults=True)
        self.db.commit()
        return [self._map_to_entity(model) for model in models]