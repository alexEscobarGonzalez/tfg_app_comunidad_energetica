from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from app.infrastructure.persistance.models.resultado_simulacion_participante_tabla import ResultadoSimulacionParticipante

class SqlAlchemyResultadoSimulacionParticipanteRepository(ResultadoSimulacionParticipanteRepository):
    def __init__(self, db: Session):
        self.db = db

    def _map_to_entity(self, model: ResultadoSimulacionParticipante) -> Optional[ResultadoSimulacionParticipanteEntity]:
        if not model:
            return None
        return ResultadoSimulacionParticipanteEntity(
            idResultadoParticipante=model.idResultadoParticipante,
            costeNetoParticipante_eur=model.costeNetoParticipante_eur,
            ahorroParticipante_eur=model.ahorroParticipante_eur,
            ahorroParticipante_pct=model.ahorroParticipante_pct,
            energiaAutoconsumidaDirecta_kWh=model.energiaAutoconsumidaDirecta_kWh,
            energiaRecibidaRepartoConsumida_kWh=model.energiaRecibidaRepartoConsumida_kWh,
            tasaAutoconsumoSCR_pct=model.tasaAutoconsumoSCR_pct,
            tasaAutosuficienciaSSR_pct=model.tasaAutosuficienciaSSR_pct,
            idResultadoSimulacion=model.idResultadoSimulacion,
            idParticipante=model.idParticipante
        )

    def get_by_id(self, resultado_participante_id: int) -> Optional[ResultadoSimulacionParticipanteEntity]:
        model = self.db.query(ResultadoSimulacionParticipante).filter_by(idResultadoParticipante=resultado_participante_id).first()
        return self._map_to_entity(model)

    def get_by_resultado_simulacion(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionParticipanteEntity]:
        models = self.db.query(ResultadoSimulacionParticipante).filter_by(idResultadoSimulacion=resultado_simulacion_id).all()
        return [self._map_to_entity(model) for model in models]

    def get_by_participante(self, participante_id: int) -> List[ResultadoSimulacionParticipanteEntity]:
        models = self.db.query(ResultadoSimulacionParticipante).filter_by(idParticipante=participante_id).all()
        return [self._map_to_entity(model) for model in models]

    def get_by_resultado_and_participante(self, resultado_simulacion_id: int, participante_id: int) -> Optional[ResultadoSimulacionParticipanteEntity]:
        model = self.db.query(ResultadoSimulacionParticipante).filter_by(
            idResultadoSimulacion=resultado_simulacion_id,
            idParticipante=participante_id
        ).first()
        return self._map_to_entity(model)

    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionParticipanteEntity]:
        models = self.db.query(ResultadoSimulacionParticipante).offset(skip).limit(limit).all()
        return [self._map_to_entity(model) for model in models]

    def create(self, resultado: ResultadoSimulacionParticipanteEntity) -> ResultadoSimulacionParticipanteEntity:
        model = ResultadoSimulacionParticipante(
            costeNetoParticipante_eur=resultado.costeNetoParticipante_eur,
            ahorroParticipante_eur=resultado.ahorroParticipante_eur,
            ahorroParticipante_pct=resultado.ahorroParticipante_pct,
            energiaAutoconsumidaDirecta_kWh=resultado.energiaAutoconsumidaDirecta_kWh,
            energiaRecibidaRepartoConsumida_kWh=resultado.energiaRecibidaRepartoConsumida_kWh,
            tasaAutoconsumoSCR_pct=resultado.tasaAutoconsumoSCR_pct,
            tasaAutosuficienciaSSR_pct=resultado.tasaAutosuficienciaSSR_pct,
            idResultadoSimulacion=resultado.idResultadoSimulacion,
            idParticipante=resultado.idParticipante
        )
        try:
            self.db.add(model)
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        except SQLAlchemyError as e:
            self.db.rollback()
            # Puedes añadir logging aquí
            raise e # O manejarlo de forma específica

    def update(self, resultado_participante_id: int, resultado: ResultadoSimulacionParticipanteEntity) -> Optional[ResultadoSimulacionParticipanteEntity]:
        model = self.db.query(ResultadoSimulacionParticipante).filter_by(idResultadoParticipante=resultado_participante_id).first()
        if not model:
            return None

        # Actualizar campos (excluyendo FKs usualmente)
        model.costeNetoParticipante_eur = resultado.costeNetoParticipante_eur if resultado.costeNetoParticipante_eur is not None else model.costeNetoParticipante_eur
        model.ahorroParticipante_eur = resultado.ahorroParticipante_eur if resultado.ahorroParticipante_eur is not None else model.ahorroParticipante_eur
        model.ahorroParticipante_pct = resultado.ahorroParticipante_pct if resultado.ahorroParticipante_pct is not None else model.ahorroParticipante_pct
        model.energiaAutoconsumidaDirecta_kWh = resultado.energiaAutoconsumidaDirecta_kWh if resultado.energiaAutoconsumidaDirecta_kWh is not None else model.energiaAutoconsumidaDirecta_kWh
        model.energiaRecibidaRepartoConsumida_kWh = resultado.energiaRecibidaRepartoConsumida_kWh if resultado.energiaRecibidaRepartoConsumida_kWh is not None else model.energiaRecibidaRepartoConsumida_kWh
        model.tasaAutoconsumoSCR_pct = resultado.tasaAutoconsumoSCR_pct if resultado.tasaAutoconsumoSCR_pct is not None else model.tasaAutoconsumoSCR_pct
        model.tasaAutosuficienciaSSR_pct = resultado.tasaAutosuficienciaSSR_pct if resultado.tasaAutosuficienciaSSR_pct is not None else model.tasaAutosuficienciaSSR_pct

        try:
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e

    def delete(self, resultado_participante_id: int) -> None:
        model = self.db.query(ResultadoSimulacionParticipante).filter_by(idResultadoParticipante=resultado_participante_id).first()
        if model:
            try:
                self.db.delete(model)
                self.db.commit()
            except SQLAlchemyError as e:
                self.db.rollback()
                raise e

    def delete_by_resultado_simulacion(self, resultado_simulacion_id: int) -> None:
        try:
            self.db.query(ResultadoSimulacionParticipante).filter_by(idResultadoSimulacion=resultado_simulacion_id).delete()
            self.db.commit()
        except SQLAlchemyError as e:
            self.db.rollback()
            raise e