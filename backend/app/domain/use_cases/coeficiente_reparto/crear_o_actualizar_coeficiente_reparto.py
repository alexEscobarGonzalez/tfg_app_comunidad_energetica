from fastapi import HTTPException
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.domain.entities.tipo_reparto import TipoReparto
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository

def crear_o_actualizar_coeficiente_reparto_use_case(
    coeficiente: CoeficienteRepartoEntity, 
    participante_repo: ParticipanteRepository, 
    coeficiente_repo: CoeficienteRepartoRepository
) -> CoeficienteRepartoEntity:
    """
    Crea o actualiza el coeficiente de reparto de un participante (relación 1:1)
    
    Args:
        coeficiente: Entidad con los datos del coeficiente de reparto
        participante_repo: Repositorio de participantes
        coeficiente_repo: Repositorio de coeficientes de reparto
        
    Returns:
        CoeficienteRepartoEntity: La entidad del coeficiente de reparto creada o actualizada
        
    Raises:
        HTTPException: Si el participante no existe o si los datos no son válidos
    """
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(coeficiente.idParticipante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Verificar que el tipo de reparto es válido
    tipos_reparto_validos = [tipo.value for tipo in TipoReparto]
    if coeficiente.tipoReparto not in tipos_reparto_validos:
        raise HTTPException(
            status_code=400, 
            detail=f"Tipo de reparto no válido. Debe ser uno de: {', '.join(tipos_reparto_validos)}"
        )
    
    # Verificar que los parámetros contienen datos coherentes con el tipo de reparto
    if coeficiente.tipoReparto == TipoReparto.REPARTO_FIJO.value and "valor" not in coeficiente.parametros:
        raise HTTPException(status_code=400, detail="El tipo de reparto fijo debe incluir el parámetro 'valor'")
    
    # Crear o actualizar el coeficiente de reparto
    return coeficiente_repo.create_or_update(coeficiente) 