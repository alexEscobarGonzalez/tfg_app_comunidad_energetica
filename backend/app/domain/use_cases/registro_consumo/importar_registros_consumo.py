from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List, Dict, Any
from datetime import datetime
import json

from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def importar_registros_consumo_use_case(
    datos_json: str, 
    id_participante: int,
    db: Session
) -> Dict[str, Any]:
    """
    Importa múltiples registros de consumo desde un JSON para un participante específico.
    
    El formato esperado del JSON es:
    [
        {"timestamp": "2025-04-23T10:00:00", "consumoEnergia": 2.5},
        {"timestamp": "2025-04-23T11:00:00", "consumoEnergia": 3.2},
        ...
    ]
    
    Args:
        datos_json: String con el JSON que contiene los datos de consumo
        id_participante: ID del participante al que pertenecen los registros
        db: Sesión de base de datos
        
    Returns:
        Dict: Resumen de la importación (registros_creados, registros_fallidos)
        
    Raises:
        HTTPException: Si el participante no existe o si los datos no son válidos
    """
    # Verificar que el participante existe
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Parsear los datos JSON
    try:
        registros_data = json.loads(datos_json)
        if not isinstance(registros_data, list):
            raise HTTPException(status_code=400, detail="El JSON debe ser un array de registros")
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="JSON inválido. Verifique el formato.")
    
    # Inicializar repositorio y contadores
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    registros_creados = 0
    registros_fallidos = 0
    errores = []
    
    # Procesar cada registro
    for idx, item in enumerate(registros_data):
        try:
            # Validar los datos mínimos requeridos
            if "timestamp" not in item or "consumoEnergia" not in item:
                raise ValueError("Faltan campos obligatorios: timestamp y consumoEnergia")
            
            # Parsear timestamp
            timestamp = None
            if isinstance(item["timestamp"], str):
                try:
                    timestamp = datetime.fromisoformat(item["timestamp"].replace('Z', '+00:00'))
                except ValueError:
                    raise ValueError(f"Formato de fecha inválido: {item['timestamp']}")
            else:
                raise ValueError(f"El timestamp debe ser un string: {item['timestamp']}")
            
            # Validar consumoEnergia
            consumo = item["consumoEnergia"]
            if not isinstance(consumo, (int, float)) or consumo <= 0:
                raise ValueError(f"El consumo debe ser un número positivo: {consumo}")
            
            # Crear la entidad y guardarla
            registro_entity = RegistroConsumoEntity(
                timestamp=timestamp,
                consumoEnergia=consumo,
                idParticipante=id_participante
            )
            
            registro_repo.create(registro_entity)
            registros_creados += 1
            
        except Exception as e:
            registros_fallidos += 1
            errores.append({
                "posicion": idx,
                "error": str(e),
                "datos": item
            })
    
    # Resumen de la importación
    resultado = {
        "registros_creados": registros_creados,
        "registros_fallidos": registros_fallidos,
        "id_participante": id_participante,
        "detalle_errores": errores if registros_fallidos > 0 else []
    }
    
    return resultado


def importar_registros_consumo_desde_archivo_use_case(
    ruta_archivo: str,
    id_participante: int, 
    db: Session
) -> Dict[str, Any]:
    """
    Importa registros de consumo desde un archivo JSON
    
    Args:
        ruta_archivo: Ruta del archivo JSON
        id_participante: ID del participante al que pertenecen los registros
        db: Sesión de base de datos
        
    Returns:
        Dict: Resumen de la importación
    """
    try:
        with open(ruta_archivo, 'r') as f:
            datos_json = f.read()
            
        return importar_registros_consumo_use_case(datos_json, id_participante, db)
        
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"Archivo no encontrado: {ruta_archivo}")
    except PermissionError:
        raise HTTPException(status_code=403, detail=f"Sin permisos para acceder al archivo: {ruta_archivo}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al procesar el archivo: {str(e)}")