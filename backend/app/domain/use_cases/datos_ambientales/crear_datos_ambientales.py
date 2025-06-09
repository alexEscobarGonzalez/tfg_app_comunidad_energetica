from fastapi import HTTPException
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository
from app.domain.repositories.simulacion_repository import SimulacionRepository

def crear_datos_ambientales_use_case(datos: DatosAmbientalesEntity, simulacion_repo: SimulacionRepository, datos_repo: DatosAmbientalesRepository) -> DatosAmbientalesEntity:
    # Verificar que la simulación existe
    if not simulacion_repo.get_by_id(datos.idSimulacion):
        raise HTTPException(status_code=404, detail=f"Simulación con ID {datos.idSimulacion} no encontrada")
    return datos_repo.create(datos)