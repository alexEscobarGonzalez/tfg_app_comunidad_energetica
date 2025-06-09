from fastapi import HTTPException
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository

def mostrar_coeficiente_reparto_use_case(id_coeficiente: int, repo: CoeficienteRepartoRepository) -> CoeficienteRepartoEntity:
    
    coeficiente = repo.get_by_id(id_coeficiente)
    if not coeficiente:
        raise HTTPException(status_code=404, detail="Coeficiente de reparto no encontrado")
    return coeficiente