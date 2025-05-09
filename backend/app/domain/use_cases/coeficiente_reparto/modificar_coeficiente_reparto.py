from fastapi import HTTPException
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.domain.entities.tipo_reparto import TipoReparto
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository

def modificar_coeficiente_reparto_use_case(id_coeficiente: int, coeficiente_datos: CoeficienteRepartoEntity, repo: CoeficienteRepartoRepository) -> CoeficienteRepartoEntity:
    """
    Modifica los datos de un coeficiente de reparto existente
    
    Args:
        id_coeficiente: ID del coeficiente de reparto a modificar
        coeficiente_datos: Nuevos datos para el coeficiente de reparto
        repo: Repositorio de coeficientes de reparto
        
    Returns:
        CoeficienteRepartoEntity: Datos actualizados del coeficiente de reparto
        
    Raises:
        HTTPException: Si el coeficiente de reparto no existe o si los datos no son válidos
    """
    # Verificar que el coeficiente existe
    coeficiente_existente = repo.get_by_id(id_coeficiente)
    if not coeficiente_existente:
        raise HTTPException(status_code=404, detail="Coeficiente de reparto no encontrado")
    
    # Verificar que el tipo de reparto es válido
    tipos_reparto_validos = [tipo.value for tipo in TipoReparto]
    if coeficiente_datos.tipoReparto not in tipos_reparto_validos:
        raise HTTPException(
            status_code=400,
            detail=f"Tipo de reparto no válido. Debe ser uno de: {', '.join(tipos_reparto_validos)}"
        )
    
    # Verificar que los parámetros contienen datos coherentes con el tipo de reparto
    if coeficiente_datos.tipoReparto == TipoReparto.REPARTO_FIJO.value and "valor" not in coeficiente_datos.parametros:
        raise HTTPException(status_code=400, detail="El tipo de reparto fijo debe incluir el parámetro 'porcentaje'")
    
    # Mantener el ID y el ID del participante
    coeficiente_datos.idCoeficienteReparto = id_coeficiente
    coeficiente_datos.idParticipante = coeficiente_existente.idParticipante
    
    # Actualizar en la base de datos
    coeficiente_actualizado = repo.update(id_coeficiente, coeficiente_datos)
    return coeficiente_actualizado