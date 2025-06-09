from typing import List, Optional
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity

class ContratoAutoconsumoRepository:
    def get_by_id(self, idContrato: int) -> Optional[ContratoAutoconsumoEntity]:
        raise NotImplementedError

    def get_by_participante(self, idParticipante: int) -> Optional[ContratoAutoconsumoEntity]:
        raise NotImplementedError
        
    def list(self) -> List[ContratoAutoconsumoEntity]:
        raise NotImplementedError

    def create(self, contrato: ContratoAutoconsumoEntity) -> ContratoAutoconsumoEntity:
        raise NotImplementedError

    def update(self, contrato: ContratoAutoconsumoEntity) -> ContratoAutoconsumoEntity:
        raise NotImplementedError

    def delete(self, idContrato: int) -> None:
        raise NotImplementedError