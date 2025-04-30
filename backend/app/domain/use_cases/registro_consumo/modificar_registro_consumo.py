from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository

def modificar_registro_consumo_use_case(id_registro: int, registro_datos: RegistroConsumoEntity, db: Session) -> RegistroConsumoEntity:
    """
    Modifica los datos de un registro de consumo existente
    
    Args:
        id_registro: ID del registro de consumo a modificar
        registro_datos: Nuevos datos para el registro de consumo
        db: Sesión de base de datos
        
    Returns:
        RegistroConsumoEntity: Datos actualizados del registro de consumo
        
    Raises:
        HTTPException: Si el registro no existe o si los datos no son válidos
    """
    repo = SqlAlchemyRegistroConsumoRepository(db)
    
    # Verificar que el registro existe
    registro_existente = repo.get_by_id(id_registro)
    if not registro_existente:
        raise HTTPException(status_code=404, detail="Registro de consumo no encontrado")
    
    # Verificar que los datos son válidos
    if registro_datos.consumoEnergia and registro_datos.consumoEnergia <= 0:
        raise HTTPException(status_code=400, detail="El consumo de energía debe ser un valor positivo")
    
    # Mantener el ID y el ID del participante
    registro_datos.idRegistroConsumo = id_registro
    registro_datos.idParticipante = registro_existente.idParticipante
    
    # Actualizar en la base de datos
    registro_actualizado = repo.update(registro_datos)
    return registro_actualizado