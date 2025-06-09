from fastapi import HTTPException
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.domain.repositories.contrato_autoconsumo_repository import ContratoAutoconsumoRepository

def mostrar_contrato_autoconsumo_use_case(id_contrato: int, repo: ContratoAutoconsumoRepository) -> ContratoAutoconsumoEntity:
    
    contrato = repo.get_by_id(id_contrato)
    if not contrato:
        raise HTTPException(status_code=404, detail="Contrato de autoconsumo no encontrado")
    return contrato