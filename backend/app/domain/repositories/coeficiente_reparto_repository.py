from typing import List, Optional
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity

class CoeficienteRepartoRepository:
    def get_by_id(self, coeficiente_id: int) -> Optional[CoeficienteRepartoEntity]:
        raise NotImplementedError

    def get_by_participante(self, participante_id: int) -> List[CoeficienteRepartoEntity]:
        raise NotImplementedError
    
    def get_by_participante_single(self, participante_id: int) -> Optional[CoeficienteRepartoEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[CoeficienteRepartoEntity]:
        raise NotImplementedError

    def create(self, coeficiente: CoeficienteRepartoEntity) -> CoeficienteRepartoEntity:
        raise NotImplementedError

    def create_or_update(self, coeficiente: CoeficienteRepartoEntity) -> CoeficienteRepartoEntity:
        raise NotImplementedError

    def update(self, coeficiente_id: int, coeficiente: CoeficienteRepartoEntity) -> CoeficienteRepartoEntity:
        raise NotImplementedError

    def delete(self, coeficiente_id: int) -> None:
        raise NotImplementedError
    
    def delete_by_participante(self, participante_id: int) -> None:
        raise NotImplementedError