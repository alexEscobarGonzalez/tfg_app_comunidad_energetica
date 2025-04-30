from typing import List, Optional
from datetime import datetime
from app.domain.entities.registro_consumo import RegistroConsumoEntity

class RegistroConsumoRepository:
    """
    Interfaz para el repositorio de registros de consumo energético
    """
    def get_by_id(self, idRegistroConsumo: int) -> Optional[RegistroConsumoEntity]:
        """Obtiene un registro de consumo por su ID"""
        raise NotImplementedError

    def get_by_participante(self, idParticipante: int) -> List[RegistroConsumoEntity]:
        """Obtiene todos los registros de consumo de un participante"""
        raise NotImplementedError
    
    def get_by_periodo(self, fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        """Obtiene registros de consumo entre dos fechas"""
        raise NotImplementedError
    
    def get_by_participante_y_periodo(self, idParticipante: int, fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        """Obtiene registros de consumo de un participante entre dos fechas"""
        raise NotImplementedError
    
    def get_range_for_participantes(self, id_participantes: List[int], fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        """
        Obtiene registros de consumo para múltiples participantes dentro de un rango de fechas.
        
        Args:
            id_participantes: Lista de IDs de participantes
            fecha_inicio: Fecha de inicio del período
            fecha_fin: Fecha de fin del período
            
        Returns:
            Lista de registros de consumo que cumplen los criterios
        """
        raise NotImplementedError
    
    def list(self) -> List[RegistroConsumoEntity]:
        """Obtiene todos los registros de consumo"""
        raise NotImplementedError

    def create(self, registro: RegistroConsumoEntity) -> RegistroConsumoEntity:
        """Crea un nuevo registro de consumo"""
        raise NotImplementedError

    def update(self, registro: RegistroConsumoEntity) -> RegistroConsumoEntity:
        """Actualiza un registro de consumo existente"""
        raise NotImplementedError

    def delete(self, idRegistroConsumo: int) -> None:
        """Elimina un registro de consumo"""
        raise NotImplementedError