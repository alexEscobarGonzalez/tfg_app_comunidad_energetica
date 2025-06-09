from fastapi import APIRouter, Depends, status, Query, File, UploadFile, Form, Body, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from datetime import datetime
import json
import csv
import io
from pydantic import BaseModel

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_registro_consumo import (
    RegistroConsumoCreate, 
    RegistroConsumoUpdate, 
    RegistroConsumoRead,
    PrediccionConsumoRequest,
    PrediccionConsumoResponse
)
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.domain.use_cases.registro_consumo.crear_registro_consumo import crear_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.mostrar_registro_consumo import mostrar_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.modificar_registro_consumo import modificar_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.eliminar_registro_consumo import eliminar_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.eliminar_todos_registros_participante import eliminar_todos_registros_participante_use_case
from app.domain.use_cases.registro_consumo.importar_registros_consumo import importar_registros_consumo_use_case
from app.domain.use_cases.registro_consumo.listar_registros_consumo import (
    listar_registros_consumo_by_participante_use_case,
    listar_registros_consumo_by_periodo_use_case,
    listar_registros_consumo_by_participante_y_periodo_use_case,
    listar_todos_registros_consumo_use_case
)
from app.domain.use_cases.registro_consumo.predecir_consumo_use_case import predecir_consumo_rango_use_case, get_predictor
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

router = APIRouter(
    prefix="/registros-consumo",
    tags=["registros-consumo"],
    responses={404: {"description": "Registro de consumo no encontrado"}}
)

@router.post("", response_model=RegistroConsumoRead, status_code=status.HTTP_201_CREATED)
def crear_registro_consumo(registro_data: RegistroConsumoCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo registro de consumo energético asociado a un participante
    """
    registro_entity = RegistroConsumoEntity(
        timestamp=registro_data.timestamp,
        consumoEnergia=registro_data.consumoEnergia,
        idParticipante=registro_data.idParticipante
    )
    participante_repo = SqlAlchemyParticipanteRepository(db)
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return crear_registro_consumo_use_case(registro_entity, participante_repo, registro_repo)


@router.post("/importar/{id_participante}", response_model=Dict[str, Any])
def importar_registros_consumo(
    id_participante: int,
    archivo_csv: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    Importa múltiples registros de consumo para un participante desde un archivo CSV
    
    El archivo CSV debe tener las siguientes columnas (con encabezados):
    - timestamp: Fecha y hora en formato ISO (YYYY-MM-DDTHH:MM:SS) o YYYY-MM-DD HH:MM:SS
    - consumoEnergia: Valor numérico del consumo energético (flotante)
    
    Ejemplo de contenido del CSV:
    timestamp,consumoEnergia
    2025-04-23T10:00:00,2.5
    2025-04-23T11:00:00,3.2
    2025-04-23 12:00:00,1.8
    """
    # Validar que el archivo sea CSV
    if not archivo_csv.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="El archivo debe tener extensión .csv")
    
    try:
        # Leer el contenido del archivo
        contenido = archivo_csv.file.read().decode('utf-8')
        csv_reader = csv.DictReader(io.StringIO(contenido))
        
        # Convertir CSV a lista de diccionarios
        datos = []
        for fila in csv_reader:
            if 'timestamp' not in fila or 'consumoEnergia' not in fila:
                raise HTTPException(
                    status_code=400, 
                    detail="El CSV debe contener las columnas 'timestamp' y 'consumoEnergia'"
                )
            
            # Normalizar el formato de timestamp si es necesario
            timestamp = fila['timestamp'].strip()
            if ' ' in timestamp and 'T' not in timestamp:
                timestamp = timestamp.replace(' ', 'T')
            
            datos.append({
                'timestamp': timestamp,
                'consumoEnergia': float(fila['consumoEnergia'])
            })
        
        if not datos:
            raise HTTPException(status_code=400, detail="El archivo CSV está vacío o no contiene datos válidos")
        
        participante_repo = SqlAlchemyParticipanteRepository(db)
        registro_repo = SqlAlchemyRegistroConsumoRepository(db)
        datos_json = json.dumps(datos)
        return importar_registros_consumo_use_case(datos_json, id_participante, participante_repo, registro_repo)
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Error en el formato de los datos: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error procesando el archivo CSV: {str(e)}")
    finally:
        archivo_csv.file.close()

@router.get("", response_model=List[RegistroConsumoRead])
def listar_registros_consumo(
    fecha_inicio: datetime = None, 
    fecha_fin: datetime = None, 
    db: Session = Depends(get_db)
):
    """
    Obtiene todos los registros de consumo del sistema.
    Opcionalmente se pueden filtrar por rango de fechas.
    """
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    if fecha_inicio and fecha_fin:
        return listar_registros_consumo_by_periodo_use_case(fecha_inicio, fecha_fin, registro_repo)
    return listar_todos_registros_consumo_use_case(registro_repo)

@router.get("/participante/{id_participante}", response_model=List[RegistroConsumoRead])
def listar_registros_consumo_por_participante(
    id_participante: int, 
    fecha_inicio: datetime = None, 
    fecha_fin: datetime = None, 
    db: Session = Depends(get_db)
):
    """
    Obtiene todos los registros de consumo asociados a un participante específico.
    Opcionalmente se pueden filtrar por rango de fechas.
    """
    participante_repo = SqlAlchemyParticipanteRepository(db)
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    if fecha_inicio and fecha_fin:
        return listar_registros_consumo_by_participante_y_periodo_use_case(id_participante, fecha_inicio, fecha_fin, participante_repo, registro_repo)
    return listar_registros_consumo_by_participante_use_case(id_participante, participante_repo, registro_repo)

@router.get("/{id_registro}", response_model=RegistroConsumoRead)
def mostrar_registro_consumo(id_registro: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de un registro de consumo específico por su ID
    """
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return mostrar_registro_consumo_use_case(id_registro, registro_repo)

@router.put("/{id_registro}", response_model=RegistroConsumoRead)
def modificar_registro_consumo(
    id_registro: int, 
    registro_data: RegistroConsumoUpdate, 
    db: Session = Depends(get_db)
):
    """
    Modifica los datos de un registro de consumo existente
    """
    registro_entity = RegistroConsumoEntity(
        timestamp=registro_data.timestamp,
        consumoEnergia=registro_data.consumoEnergia
    )
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return modificar_registro_consumo_use_case(id_registro, registro_entity, registro_repo)

@router.delete("/participante/{id_participante}", response_model=Dict[str, Any])
def eliminar_todos_registros_participante(id_participante: int, db: Session = Depends(get_db)):
    """
    Elimina todos los registros de consumo de un participante específico
    
    Esta operación es irreversible y eliminará permanentemente todos los datos
    de consumo energético asociados al participante especificado.
    
    Args:
        id_participante: ID del participante cuyos registros se eliminarán
        
    Returns:
        Información sobre la operación de eliminación realizada
    """
    try:
        participante_repo = SqlAlchemyParticipanteRepository(db)
        registro_repo = SqlAlchemyRegistroConsumoRepository(db)
        return eliminar_todos_registros_participante_use_case(id_participante, participante_repo, registro_repo)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {str(e)}")

@router.delete("/{id_registro}", response_model=Dict[str, Any])
def eliminar_registro_consumo(id_registro: int, db: Session = Depends(get_db)):
    """
    Elimina un registro de consumo existente
    """
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return eliminar_registro_consumo_use_case(id_registro, registro_repo)

@router.post("/predecir-consumo", response_model=PrediccionConsumoResponse, status_code=status.HTTP_200_OK)
def predecir_consumo_energetico(request: PrediccionConsumoRequest):
    """
    Predice el consumo energético para un rango de fechas usando el Modelo Socioeconómico v3
    
    Utiliza un modelo LightGBM optimizado con **11 características** para generar predicciones 
    de consumo energético horario en intervalos regulares.
    
    ## 🔧 Características del Modelo (11 total)
    
    ### Socioeconómicas (2):
    - **tipo_vivienda**: 1=Casa pequeña, 2=Apartamento, 3=Casa mediana, 4=Casa grande
    - **num_personas**: Número de personas en el hogar (1-8)
    
    ### Temporales (5 - calculadas automáticamente):
    - **hora**: Hora del día (0-23)
    - **dia_semana**: Día de la semana (0-6, Lunes=0)
    - **es_finde**: Es fin de semana (0/1)
    - **mes**: Mes del año (1-12)
    - **tipo_tarifa**: Clasificación automática según hora
    
    ### Lags Mensuales (3):
    - **lag_mes1**: Consumo promedio del mes anterior
    - **lag_mes2**: Consumo promedio de hace 2 meses
    - **lag_mes3**: Consumo promedio de hace 3 meses
    
    ### Climática (1):
    - **temperatura**: Temperatura promedio en °C
    
    ## ⚡ Clasificación Automática de Tarifas
    
    - **Valle** (22:00-8:00): Tarifa más económica, menor demanda
    - **Normal** (8:00-18:00): Tarifa estándar, demanda moderada  
    - **Punta** (18:00-22:00): Tarifa más cara, mayor demanda
    
    ## 📊 Rendimiento del Modelo
    
    - **R²**: ~0.85 (85% de varianza explicada)
    - **MAE**: ~0.15 kWh (error absoluto medio)
    - **Rango típico**: 0.1 - 2.0 kWh por hora
    - **Tiempo predicción**: <10ms por muestra
    
    ## 🎯 Casos de Uso
    
    - Planificación diaria/semanal de consumo
    - Optimización de tarifas eléctricas  
    - Análisis de costos por período tarifario
    - Gestión inteligente de electrodomésticos
    - Estudios de eficiencia energética
    
    ## 📝 Ejemplo de Uso
    
    ```json
    {
        "fecha_inicio": "2024-06-15T00:00:00",
        "fecha_fin": "2024-06-15T23:00:00", 
        "intervalo_horas": 1,
        "tipo_vivienda": 2,
        "num_personas": 4,
        "temperatura": 22.0,
        "lag_mes1": 0.52,
        "lag_mes2": 0.48,
        "lag_mes3": 0.55
    }
    ```
    
    **Nota**: El modelo requiere datos históricos de consumo (lags) para óptimo rendimiento.
    """
    try:
        resultado = predecir_consumo_rango_use_case(
            fecha_inicio=request.fecha_inicio,
            fecha_fin=request.fecha_fin,
            intervalo_horas=request.intervalo_horas,
            tipo_vivienda=request.tipo_vivienda,
            num_personas=request.num_personas,
            temperatura=request.temperatura,
            lag_mes1=request.lag_mes1,
            lag_mes2=request.lag_mes2,
            lag_mes3=request.lag_mes3
        )
        
        return PrediccionConsumoResponse(**resultado)
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al realizar las predicciones: {str(e)}")

@router.get("/modelo/estado")
def obtener_estado_modelo():
    """
    Obtiene el estado del modelo de predicción de consumo (Modelo Socioeconómico v3)
    
    Retorna información sobre la disponibilidad del modelo, versión, y características técnicas.
    
    ## 📋 Información Retornada
    
    - **modelo_disponible**: Si el modelo está cargado y listo
    - **version**: Versión del modelo cargado
    - **algoritmo**: Algoritmo utilizado (LightGBM)
    - **caracteristicas**: Número de características (11)
    - **ubicacion**: Ruta donde se encontró el modelo
    - **mensaje**: Estado descriptivo del modelo
    
    ## 🔧 Ubicación del Modelo
    
    El modelo se busca en: `app/ml/`
    - `modelo_lightgbm_optimizado.pkl`: Archivo del modelo entrenado
    - `metadata.pkl`: Metadatos y configuración
    
    ## ⚠️ Troubleshooting
    
    Si `modelo_disponible: false`, verificar:
    1. Archivos del modelo en `app/ml/`
    2. Permisos de lectura
    3. Integridad de archivos .pkl
    4. Logs del servidor para errores específicos
    """
    try:
        predictor = get_predictor()
        
        return {
            "modelo_disponible": predictor.esta_disponible(),
            "version": predictor.metadata.get('version', 'desconocida') if predictor.metadata else 'desconocida',
            "descripcion": predictor.metadata.get('descripcion', 'Modelo Socioeconómico v3') if predictor.metadata else 'Modelo Socioeconómico v3',
            "algoritmo": "LightGBM",
            "caracteristicas": 11,
            "ubicacion": "app/ml/",
            "archivos_requeridos": [
                "modelo_lightgbm_optimizado.pkl",
                "metadata.pkl"
            ],
            "mensaje": "Modelo cargado correctamente" if predictor.esta_disponible() else "Modelo no disponible"
        }
        
    except Exception as e:
        return {
            "modelo_disponible": False,
            "error": str(e),
            "ubicacion": "app/ml/",
            "mensaje": "Error al verificar el estado del modelo",
            "solucion": "Verificar que los archivos del modelo existan en app/ml/ y tengan permisos de lectura"
        }