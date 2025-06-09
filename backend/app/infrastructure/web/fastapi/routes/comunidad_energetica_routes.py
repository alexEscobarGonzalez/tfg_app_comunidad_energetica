from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import Optional
import os
import shutil
from datetime import datetime
import logging
import asyncio
import tempfile

from app.interfaces.schemas_comunidad_energetica import ComunidadEnergeticaCreate, ComunidadEnergeticaRead, ComunidadEnergeticaUpdate
from app.infrastructure.persistance.database import get_db
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.use_cases.comunidad_energetica.crear_comunidad_energetica import crear_comunidad_energetica_use_case
from app.domain.use_cases.comunidad_energetica.mostrar_comunidad_energetica import mostrar_comunidad_energetica_use_case
from app.domain.use_cases.comunidad_energetica.modificar_comunidad_energetica import modificar_comunidad_energetica_use_case
from app.domain.use_cases.comunidad_energetica.eliminar_comunidad_energetica import eliminar_comunidad_energetica_use_case
from app.domain.use_cases.comunidad_energetica.exportar_comunidad_completa import exportar_comunidad_completa_use_case
from app.domain.use_cases.comunidad_energetica.importar_comunidad_completa import importar_comunidad_completa_use_case
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository

# Configurar logger
logger = logging.getLogger(__name__)

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
    repo = SqlAlchemyComunidadEnergeticaRepository(db)
    nueva_comunidad = crear_comunidad_energetica_use_case(comunidad_entity, repo)
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
    repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad = mostrar_comunidad_energetica_use_case(id_comunidad, repo)
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
    comunidad_entity = ComunidadEnergeticaEntity(
        nombre=comunidad.nombre,
        latitud=comunidad.latitud,
        longitud=comunidad.longitud,
        tipoEstrategiaExcedentes=comunidad.tipoEstrategiaExcedentes
    )
    repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad_actualizada = modificar_comunidad_energetica_use_case(id_comunidad, comunidad_entity, repo)
    return ComunidadEnergeticaRead(
        idComunidadEnergetica=comunidad_actualizada.idComunidadEnergetica,
        nombre=comunidad_actualizada.nombre,
        latitud=comunidad_actualizada.latitud,
        longitud=comunidad_actualizada.longitud,
        tipoEstrategiaExcedentes=comunidad_actualizada.tipoEstrategiaExcedentes,
        idUsuario=comunidad_actualizada.idUsuario
    )

@router.delete("/{id_comunidad}", status_code=204)
def delete_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    eliminar_comunidad_energetica_use_case(id_comunidad, db)
    return None

@router.get("/{id_comunidad}/export-completo")
async def exportar_comunidad_completa(
    id_comunidad: int,
    fecha_inicio: Optional[str] = Query(None, description="Fecha inicio para filtrar datos (YYYY-MM-DD)"),
    fecha_fin: Optional[str] = Query(None, description="Fecha fin para filtrar datos (YYYY-MM-DD)"),
    db: Session = Depends(get_db)
):
    logger.info(f"Iniciando exportación para comunidad {id_comunidad}")
    logger.info(f"Parámetros: fecha_inicio={fecha_inicio}, fecha_fin={fecha_fin}")
    
    try:
        # Parsear fechas si se proporcionan
        fecha_inicio_dt = None
        fecha_fin_dt = None
        
        if fecha_inicio:
            try:
                fecha_inicio_dt = datetime.strptime(fecha_inicio, '%Y-%m-%d')
                logger.info(f"Fecha inicio parseada: {fecha_inicio_dt}")
            except ValueError as e:
                logger.error(f"Error parseando fecha_inicio: {e}")
                raise HTTPException(status_code=400, detail="Formato de fecha_inicio inválido. Use YYYY-MM-DD")
        
        if fecha_fin:
            try:
                fecha_fin_dt = datetime.strptime(fecha_fin, '%Y-%m-%d')
                logger.info(f"Fecha fin parseada: {fecha_fin_dt}")
            except ValueError as e:
                logger.error(f"Error parseando fecha_fin: {e}")
                raise HTTPException(status_code=400, detail="Formato de fecha_fin inválido. Use YYYY-MM-DD")
        
        logger.info("Llamando al caso de uso de exportación")
        
        # Ejecutar exportación
        ruta_zip, metadatos = exportar_comunidad_completa_use_case(
            comunidad_id=id_comunidad,
            db=db,
            fecha_inicio=fecha_inicio_dt,
            fecha_fin=fecha_fin_dt
        )
        
        logger.info(f"Exportación completada. Archivo generado: {ruta_zip}")
        
        # Verificar que el archivo existe
        if not os.path.exists(ruta_zip):
            logger.error(f"El archivo ZIP no existe: {ruta_zip}")
            raise HTTPException(status_code=500, detail="Error: archivo ZIP no generado")
        
        # Obtener información del archivo
        nombre_archivo = os.path.basename(ruta_zip)
        tamaño_archivo = os.path.getsize(ruta_zip)
        
        logger.info(f"Archivo listo para descarga: {nombre_archivo} ({tamaño_archivo} bytes)")
        
        # Guardar la ruta del directorio para limpiar después
        parent_dir = os.path.dirname(ruta_zip)
        
        # Crear response que descargue el archivo
        response = FileResponse(
            path=ruta_zip,
            filename=nombre_archivo,
            media_type='application/zip'
        )
        
        # Programar limpieza en background (sin await)
        async def cleanup_background():
            try:
                # Esperar un poco antes de limpiar para asegurar que la descarga termine
                await asyncio.sleep(2)
                logger.info(f"Limpiando directorio temporal: {parent_dir}")
                shutil.rmtree(parent_dir, ignore_errors=True)
            except Exception as e:
                logger.error(f"Error limpiando archivos temporales: {e}")
        
        # Ejecutar limpieza en background sin bloquear la respuesta
        asyncio.create_task(cleanup_background())
        
        return response
        
    except ValueError as e:
        logger.error(f"Error de validación: {e}")
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error interno en exportación: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {str(e)}")

@router.post("/import-completo")
async def importar_comunidad_completa(
    file: UploadFile = File(..., description="Archivo ZIP con datos de la comunidad"),
    id_usuario: int = Query(..., description="ID del usuario que realiza la importación"),
    db: Session = Depends(get_db)
):
    logger.info(f"Iniciando importación de comunidad para usuario {id_usuario}")
    logger.info(f"Archivo recibido: {file.filename} ({file.content_type})")
    
    # Verificar que es un archivo ZIP
    if not file.filename.endswith('.zip'):
        raise HTTPException(status_code=400, detail="El archivo debe ser un ZIP")
    
    # Crear archivo temporal para guardar el ZIP
    temp_zip_path = None
    try:
        # Crear archivo temporal
        with tempfile.NamedTemporaryFile(delete=False, suffix='.zip') as temp_file:
            temp_zip_path = temp_file.name
            
            # Escribir contenido del archivo subido
            content = await file.read()
            temp_file.write(content)
            
        logger.info(f"Archivo ZIP guardado temporalmente en: {temp_zip_path}")
        logger.info(f"Tamaño del archivo: {len(content)} bytes")
        
        # Ejecutar importación
        resultado = importar_comunidad_completa_use_case(
            archivo_zip_path=temp_zip_path,
            db=db,
            id_usuario=id_usuario
        )
        
        logger.info("Importación completada exitosamente")
        
        # Preparar respuesta con estadísticas
        response_data = {
            "success": True,
            "message": "Importación completada exitosamente",
            "estadisticas": {
                "comunidad_nombre": resultado['comunidad_creada'].nombre if resultado['comunidad_creada'] else None,
                "comunidad_id": resultado['comunidad_creada'].idComunidadEnergetica if resultado['comunidad_creada'] else None,
                "participantes_creados": resultado['participantes_creados'],
                "activos_generacion_creados": resultado['activos_generacion_creados'],
                "activos_almacenamiento_creados": resultado['activos_almacenamiento_creados'],
                "coeficientes_creados": resultado['coeficientes_creados'],
                "contratos_creados": resultado['contratos_creados'],
                "registros_consumo_creados": resultado['registros_consumo_creados']
            }
        }
        
        return response_data
        
    except Exception as e:
        logger.error(f"Error en importación: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error en la importación: {str(e)}")
    
    finally:
        # Limpiar archivo temporal
        if temp_zip_path and os.path.exists(temp_zip_path):
            try:
                os.unlink(temp_zip_path)
                logger.info(f"Archivo temporal eliminado: {temp_zip_path}")
            except Exception as e:
                logger.error(f"Error eliminando archivo temporal: {e}")


