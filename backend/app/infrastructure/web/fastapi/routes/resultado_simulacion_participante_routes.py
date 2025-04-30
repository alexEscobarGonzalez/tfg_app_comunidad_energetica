# backend/app/infrastructure/web/fastapi/routes/resultado_simulacion_participante_routes.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_resultado_simulacion_participante import (
    ResultadoSimulacionParticipanteCreate,
    ResultadoSimulacionParticipanteRead,
    ResultadoSimulacionParticipanteUpdate
)
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
# Importar repositorios necesarios
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_participante_repository import SqlAlchemyResultadoSimulacionParticipanteRepository
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository as ResultadoGlobalRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

# Importar casos de uso (si los creaste) o usar repositorios directamente
# from app.domain.use_cases.resultado_simulacion_participante.create_resultado_simulacion_participante import CreateResultadoSimulacionParticipante
# ... otros casos de uso

router = APIRouter(
    prefix="/resultados-simulacion-participante",
    tags=["resultados-simulacion-participante"],
    responses={404: {"description": "Resultado de simulación de participante no encontrado"}}
)

@router.post("", response_model=ResultadoSimulacionParticipanteRead, status_code=status.HTTP_201_CREATED)
def crear_resultado_participante(resultado: ResultadoSimulacionParticipanteCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo resultado de simulación para un participante específico dentro de un resultado global.
    """
    # Inicializar repositorios
    resultado_participante_repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db)
    resultado_global_repo = ResultadoGlobalRepository(db)
    participante_repo = SqlAlchemyParticipanteRepository(db)

    # Validar existencias y unicidad (Similar a como se haría en el caso de uso)
    if not resultado_global_repo.get_by_id(resultado.idResultadoSimulacion):
        raise HTTPException(status_code=404, detail=f"Resultado global de simulación con ID {resultado.idResultadoSimulacion} no encontrado")
    if not participante_repo.get_by_id(resultado.idParticipante):
        raise HTTPException(status_code=404, detail=f"Participante con ID {resultado.idParticipante} no encontrado")
    existente = resultado_participante_repo.get_by_resultado_and_participante(resultado.idResultadoSimulacion, resultado.idParticipante)
    if existente:
        raise HTTPException(status_code=400, detail="Ya existe un resultado para este participante en esta simulación")

    # Crear entidad y guardar
    resultado_entity = ResultadoSimulacionParticipanteEntity(**resultado.model_dump()) # Compatible con Pydantic v2
    nuevo_resultado = resultado_participante_repo.create(resultado_entity)
    return nuevo_resultado

@router.get("/resultado/{id_resultado_simulacion}", response_model=List[ResultadoSimulacionParticipanteRead])
def listar_resultados_por_simulacion_global(id_resultado_simulacion: int, db: Session = Depends(get_db)):
    """
    Obtiene todos los resultados de participantes asociados a un resultado de simulación global.
    """
    repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db)
    resultados = repo.get_by_resultado_simulacion(id_resultado_simulacion)
    if not resultados:
         raise HTTPException(status_code=404, detail=f"No se encontraron resultados para la simulación global con ID {id_resultado_simulacion}")
    return resultados

@router.get("/participante/{id_participante}", response_model=List[ResultadoSimulacionParticipanteRead])
def listar_resultados_por_participante(id_participante: int, db: Session = Depends(get_db)):
    """
    Obtiene todos los resultados de simulación para un participante específico.
    """
    repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db)
    resultados = repo.get_by_participante(id_participante)
    if not resultados:
         raise HTTPException(status_code=404, detail=f"No se encontraron resultados para el participante con ID {id_participante}")
    return resultados

@router.get("/{id_resultado_participante}", response_model=ResultadoSimulacionParticipanteRead)
def obtener_resultado_participante(id_resultado_participante: int, db: Session = Depends(get_db)):
    """
    Obtiene un resultado de simulación de participante por su ID específico.
    """
    repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db)
    resultado = repo.get_by_id(id_resultado_participante)
    if not resultado:
        raise HTTPException(status_code=404, detail=f"Resultado de participante con ID {id_resultado_participante} no encontrado")
    return resultado

@router.put("/{id_resultado_participante}", response_model=ResultadoSimulacionParticipanteRead)
def actualizar_resultado_participante(id_resultado_participante: int, resultado_update: ResultadoSimulacionParticipanteUpdate, db: Session = Depends(get_db)):
    """
    Actualiza un resultado de simulación de participante existente.
    """
    repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db)
    resultado_existente = repo.get_by_id(id_resultado_participante)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail=f"Resultado de participante con ID {id_resultado_participante} no encontrado")

    # Crear entidad con datos actualizados
    update_data = resultado_update.model_dump(exclude_unset=True) # Pydantic v2: Obtener solo campos proporcionados
    resultado_entity_update = ResultadoSimulacionParticipanteEntity(
        idResultadoParticipante=id_resultado_participante,
         # Copiar valores actualizables o mantener los existentes
        costeNetoParticipante_eur=update_data.get('costeNetoParticipante_eur', resultado_existente.costeNetoParticipante_eur),
        ahorroParticipante_eur=update_data.get('ahorroParticipante_eur', resultado_existente.ahorroParticipante_eur),
        ahorroParticipante_pct=update_data.get('ahorroParticipante_pct', resultado_existente.ahorroParticipante_pct),
        energiaAutoconsumidaDirecta_kWh=update_data.get('energiaAutoconsumidaDirecta_kWh', resultado_existente.energiaAutoconsumidaDirecta_kWh),
        energiaRecibidaRepartoConsumida_kWh=update_data.get('energiaRecibidaRepartoConsumida_kWh', resultado_existente.energiaRecibidaRepartoConsumida_kWh),
        tasaAutoconsumoSCR_pct=update_data.get('tasaAutoconsumoSCR_pct', resultado_existente.tasaAutoconsumoSCR_pct),
        tasaAutosuficienciaSSR_pct=update_data.get('tasaAutosuficienciaSSR_pct', resultado_existente.tasaAutosuficienciaSSR_pct),
        # Mantener FKs
        idResultadoSimulacion=resultado_existente.idResultadoSimulacion,
        idParticipante=resultado_existente.idParticipante
    )

    resultado_actualizado = repo.update(id_resultado_participante, resultado_entity_update)
    if not resultado_actualizado:
         raise HTTPException(status_code=404, detail="Error al actualizar el resultado del participante") # O podría ser 500
    return resultado_actualizado

@router.delete("/{id_resultado_participante}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_resultado_participante(id_resultado_participante: int, db: Session = Depends(get_db)):
    """
    Elimina un resultado de simulación de participante específico.
    """
    repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db)
    resultado_existente = repo.get_by_id(id_resultado_participante)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail=f"Resultado de participante con ID {id_resultado_participante} no encontrado")

    repo.delete(id_resultado_participante)
    return None # No content on success