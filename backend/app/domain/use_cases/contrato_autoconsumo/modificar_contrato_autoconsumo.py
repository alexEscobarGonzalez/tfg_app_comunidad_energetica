from fastapi import HTTPException
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.domain.repositories.contrato_autoconsumo_repository import ContratoAutoconsumoRepository

def modificar_contrato_autoconsumo_use_case(id_contrato: int, contrato_datos: ContratoAutoconsumoEntity, repo: ContratoAutoconsumoRepository) -> ContratoAutoconsumoEntity:
    
    # Verificar que el contrato existe
    contrato_existente = repo.get_by_id(id_contrato)
    if not contrato_existente:
        raise HTTPException(status_code=404, detail="Contrato de autoconsumo no encontrado")
    
    # Actualizar los datos manteniendo el ID original y el participante
    contrato_datos.idContrato = id_contrato
    contrato_datos.idParticipante = contrato_existente.idParticipante
    
    # Actualizar en la base de datos
    contrato_actualizado = repo.update(contrato_datos)
    return contrato_actualizado