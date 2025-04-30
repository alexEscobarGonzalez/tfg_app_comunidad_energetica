from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.interfaces.schemas_comunidad_energetica import ComunidadEnergeticaCreate, ComunidadEnergeticaRead, ComunidadEnergeticaUpdate
from app.infrastructure.persistance.database import get_db
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.use_cases.comunidad_energetica.crear_comunidad_energetica import crear_comunidad_energetica_use_case
from app.domain.use_cases.comunidad_energetica.mostrar_comunidad_energetica import mostrar_comunidad_energetica_use_case
from app.domain.use_cases.comunidad_energetica.modificar_comunidad_energetica import modificar_comunidad_energetica_use_case

router = APIRouter(prefix="/comunidades", tags=["comunidades"])

@router.post("/", response_model=ComunidadEnergeticaRead)
def create_comunidad(comunidad: ComunidadEnergeticaCreate, db: Session = Depends(get_db)):
    comunidad_entity = ComunidadEnergeticaEntity(
        nombre=comunidad.nombre,
        latitud=comunidad.latitud,
        longitud=comunidad.longitud,
        tipoEstrategiaExcedentes=comunidad.tipoEstrategiaExcedentes,
        idUsuario=comunidad.idUsuario
    )
    nueva_comunidad = crear_comunidad_energetica_use_case(comunidad_entity, db)
    return ComunidadEnergeticaRead(
        idComunidadEnergetica=nueva_comunidad.idComunidadEnergetica,
        nombre=nueva_comunidad.nombre,
        latitud=nueva_comunidad.latitud,
        longitud=nueva_comunidad.longitud,
        tipoEstrategiaExcedentes=nueva_comunidad.tipoEstrategiaExcedentes,
        idUsuario=nueva_comunidad.idUsuario
    )

@router.get("/{id_comunidad}", response_model=ComunidadEnergeticaRead)
def get_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de una comunidad energética por su ID
    """
    comunidad = mostrar_comunidad_energetica_use_case(id_comunidad, db)
    return ComunidadEnergeticaRead(
        idComunidadEnergetica=comunidad.idComunidadEnergetica,
        nombre=comunidad.nombre,
        latitud=comunidad.latitud,
        longitud=comunidad.longitud,
        tipoEstrategiaExcedentes=comunidad.tipoEstrategiaExcedentes,
        idUsuario=comunidad.idUsuario
    )

@router.put("/{id_comunidad}", response_model=ComunidadEnergeticaRead)
def update_comunidad(id_comunidad: int, comunidad: ComunidadEnergeticaUpdate, db: Session = Depends(get_db)):
    """
    Modifica los datos de una comunidad energética existente
    """
    # Convertir el schema de actualización al entity
    comunidad_entity = ComunidadEnergeticaEntity(
        nombre=comunidad.nombre,
        latitud=comunidad.latitud,
        longitud=comunidad.longitud,
        tipoEstrategiaExcedentes=comunidad.tipoEstrategiaExcedentes
    )
    
    # Llamar al caso de uso para actualizar
    comunidad_actualizada = modificar_comunidad_energetica_use_case(id_comunidad, comunidad_entity, db)
    
    # Convertir entity a schema de respuesta
    return ComunidadEnergeticaRead(
        idComunidadEnergetica=comunidad_actualizada.idComunidadEnergetica,
        nombre=comunidad_actualizada.nombre,
        latitud=comunidad_actualizada.latitud,
        longitud=comunidad_actualizada.longitud,
        tipoEstrategiaExcedentes=comunidad_actualizada.tipoEstrategiaExcedentes,
        idUsuario=comunidad_actualizada.idUsuario
    )


