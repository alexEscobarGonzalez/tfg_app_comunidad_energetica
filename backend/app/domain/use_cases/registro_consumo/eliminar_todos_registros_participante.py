from typing import Dict, Any
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository

def eliminar_todos_registros_participante_use_case(
    idParticipante: int,
    participante_repo: ParticipanteRepository,
    registro_repo: RegistroConsumoRepository
) -> Dict[str, Any]:
    """
    Elimina todos los registros de consumo de un participante específico
    
    Args:
        idParticipante: ID del participante
        participante_repo: Repositorio de participantes
        registro_repo: Repositorio de registros de consumo
        
    Returns:
        Diccionario con el resultado de la operación
    """
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(idParticipante)
    if not participante:
        raise ValueError(f"Participante con ID {idParticipante} no encontrado")
    
    # Eliminar todos los registros del participante
    registros_eliminados = registro_repo.delete_all_by_participante(idParticipante)
    
    return {
        "mensaje": f"Todos los registros de consumo del participante {participante.nombre} han sido eliminados exitosamente",
        "idParticipante": idParticipante,
        "nombreParticipante": participante.nombre,
        "registrosEliminados": registros_eliminados,
        "estado": "exitoso"
    } 