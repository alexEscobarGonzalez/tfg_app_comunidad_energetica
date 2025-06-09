from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository
import json
from fastapi import HTTPException
from typing import Dict, Any
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from datetime import datetime

def importar_registros_consumo_use_case(
    datos_json: str,
    id_participante: int,
    participante_repo: ParticipanteRepository,
    registro_repo: RegistroConsumoRepository
) -> Dict[str, Any]:
    # Verificar que el participante existe
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
    
    # Inicializar contadores
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

