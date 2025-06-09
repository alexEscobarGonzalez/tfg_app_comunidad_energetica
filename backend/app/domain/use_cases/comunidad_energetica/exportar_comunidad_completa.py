import os
import json
import csv
import zipfile
import tempfile
from datetime import datetime
from typing import Optional, Dict, Any
from sqlalchemy.orm import Session

def exportar_comunidad_completa_use_case(
    comunidad_id: int, 
    db: Session,
    fecha_inicio: Optional[datetime] = None,
    fecha_fin: Optional[datetime] = None
) -> tuple[str, Dict[str, Any]]:
    
    try:
        print(f"Iniciando exportación para comunidad {comunidad_id}")
        
        from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
        from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository
        from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository
        from app.infrastructure.persistance.repository.sqlalchemy_activo_almacenamiento_repository import SqlAlchemyActivoAlmacenamientoRepository
        from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository
        from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
        from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository
        
        # Inicializar repositorios
        comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
        participante_repo = SqlAlchemyParticipanteRepository(db)
        activo_gen_repo = SqlAlchemyActivoGeneracionRepository(db)
        activo_alm_repo = SqlAlchemyActivoAlmacenamientoRepository(db)
        coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
        registro_consumo_repo = SqlAlchemyRegistroConsumoRepository(db)
        contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
        
        print("Repositorios inicializados")
        
        # Verificar que la comunidad existe
        comunidad = comunidad_repo.get_by_id(comunidad_id)
        if not comunidad:
            raise ValueError(f"Comunidad con ID {comunidad_id} no encontrada")

        print(f"Comunidad encontrada: {comunidad.nombre}")

        # Crear directorio temporal
        temp_dir = tempfile.mkdtemp()
        print(f"Directorio temporal creado: {temp_dir}")
        
        # Recopilar todos los datos
        datos_comunidad = _recopilar_datos_comunidad(
            comunidad_id, 
            comunidad_repo,
            participante_repo,
            activo_gen_repo,
            activo_alm_repo,
            coeficiente_repo,
            contrato_repo
        )
        
        print("Datos de comunidad recopilados")
        
        # Crear estructura de directorios
        metadatos_dir = os.path.join(temp_dir, "metadatos")
        consumo_dir = os.path.join(temp_dir, "datos_consumo")
        os.makedirs(metadatos_dir, exist_ok=True)
        os.makedirs(consumo_dir, exist_ok=True)
        
        # Generar archivos JSON
        _generar_archivos_json(metadatos_dir, datos_comunidad)
        print("Archivos JSON generados")
        
        # Generar archivos CSV de consumo
        _generar_archivos_csv_consumo(
            consumo_dir, 
            datos_comunidad['participantes'], 
            registro_consumo_repo,
            fecha_inicio, 
            fecha_fin
        )
        print("Archivos CSV generados")
        
        # Crear archivo ZIP
        nombre_comunidad = comunidad.nombre.replace(" ", "_").replace("/", "_")
        fecha_str = datetime.now().strftime("%Y%m%d_%H%M%S")
        nombre_zip = f"comunidad_{nombre_comunidad}_{fecha_str}.zip"
        ruta_zip = os.path.join(temp_dir, nombre_zip)
        
        _crear_archivo_zip(temp_dir, ruta_zip, ['metadatos', 'datos_consumo'])
        print(f"Archivo ZIP creado: {ruta_zip}")
        
        # Crear metadatos de exportación
        metadatos = _crear_metadatos_exportacion(datos_comunidad, fecha_inicio, fecha_fin)
        
        return ruta_zip, metadatos
        
    except Exception as e:
        print(f"Error en exportación: {str(e)}")
        # Limpiar directorio temporal en caso de error
        import shutil
        if 'temp_dir' in locals():
            shutil.rmtree(temp_dir, ignore_errors=True)
        raise e

def _recopilar_datos_comunidad(
    comunidad_id: int,
    comunidad_repo,
    participante_repo,
    activo_gen_repo,
    activo_alm_repo,
    coeficiente_repo,
    contrato_repo
) -> Dict[str, Any]:
    
    try:
        print("Obteniendo datos básicos de la comunidad")
        # Datos básicos de la comunidad
        comunidad = comunidad_repo.get_by_id(comunidad_id)
        
        print("Obteniendo participantes")
        # Participantes - método correcto es get_by_comunidad
        participantes = participante_repo.get_by_comunidad(comunidad_id)
        print(f"Encontrados {len(participantes)} participantes")
        
        print("Obteniendo activos de generación")
        # Activos de generación - método correcto es get_by_comunidad
        try:
            activos_generacion = activo_gen_repo.get_by_comunidad(comunidad_id)
        except Exception as e:
            print(f"Error obteniendo activos de generación: {e}")
            activos_generacion = []
        
        print("Obteniendo activos de almacenamiento")
        # Activos de almacenamiento - método correcto es get_by_comunidad
        try:
            activos_almacenamiento = activo_alm_repo.get_by_comunidad(comunidad_id)
        except Exception as e:
            print(f"Error obteniendo activos de almacenamiento: {e}")
            activos_almacenamiento = []
        
        print("Obteniendo coeficientes de reparto")
        # Coeficientes de reparto - obtenemos por participante ya que no hay método por comunidad
        coeficientes = []
        try:
            for participante in participantes:
                try:
                    coeficiente = coeficiente_repo.get_by_participante_single(participante.idParticipante)
                    if coeficiente:
                        coeficientes.append(coeficiente)
                except Exception as e:
                    print(f"Error obteniendo coeficiente para participante {participante.idParticipante}: {e}")
                    continue
        except Exception as e:
            print(f"Error obteniendo coeficientes: {e}")
            coeficientes = []
        
        print("Obteniendo contratos")
        # Contratos de autoconsumo
        contratos = []
        for participante in participantes:
            try:
                contrato = contrato_repo.get_by_participante(participante.idParticipante)
                if contrato:
                    contratos.append(contrato)
            except Exception as e:
                print(f"Error obteniendo contrato para participante {participante.idParticipante}: {e}")
                continue  # Participante sin contrato
        
        return {
            'comunidad': comunidad,
            'participantes': participantes,
            'activos_generacion': activos_generacion,
            'activos_almacenamiento': activos_almacenamiento,
            'coeficientes': coeficientes,
            'contratos': contratos
        }
    except Exception as e:
        print(f"Error recopilando datos de comunidad: {e}")
        raise e

def _generar_archivos_json(metadatos_dir: str, datos: Dict[str, Any]):
    
    try:
        # Comunidad
        comunidad_dict = {
            'idComunidadEnergetica': datos['comunidad'].idComunidadEnergetica,
            'nombre': datos['comunidad'].nombre,
            'latitud': datos['comunidad'].latitud,
            'longitud': datos['comunidad'].longitud,
            'tipoEstrategiaExcedentes': datos['comunidad'].tipoEstrategiaExcedentes.value if hasattr(datos['comunidad'].tipoEstrategiaExcedentes, 'value') else str(datos['comunidad'].tipoEstrategiaExcedentes),
            'idUsuario': datos['comunidad'].idUsuario
        }
        
        with open(os.path.join(metadatos_dir, 'comunidad.json'), 'w', encoding='utf-8') as f:
            json.dump(comunidad_dict, f, indent=2, ensure_ascii=False)
        
        # Participantes
        participantes_list = []
        for p in datos['participantes']:
            participantes_list.append({
                'idParticipante': p.idParticipante,
                'nombre': p.nombre,
                'idComunidadEnergetica': p.idComunidadEnergetica
            })
        
        with open(os.path.join(metadatos_dir, 'participantes.json'), 'w', encoding='utf-8') as f:
            json.dump(participantes_list, f, indent=2, ensure_ascii=False)
        
        # Activos de generación
        activos_gen_list = []
        for a in datos['activos_generacion']:
            activos_gen_list.append({
                'idActivoGeneracion': a.idActivoGeneracion,
                'nombreDescriptivo': a.nombreDescriptivo,
                'tipo_activo': a.tipo_activo.value if hasattr(a.tipo_activo, 'value') else str(a.tipo_activo),
                'potenciaNominal_kWp': a.potenciaNominal_kWp,
                'latitud': a.latitud,
                'longitud': a.longitud,
                'azimutGrados': a.azimutGrados,
                'inclinacionGrados': a.inclinacionGrados,
                'tecnologiaPanel': a.tecnologiaPanel,
                'perdidaSistema': a.perdidaSistema,
                'posicionMontaje': a.posicionMontaje,
                'curvaPotencia': a.curvaPotencia,
                'fechaInstalacion': a.fechaInstalacion.isoformat() if a.fechaInstalacion else None,
                'costeInstalacion_eur': a.costeInstalacion_eur,
                'vidaUtil_anios': a.vidaUtil_anios,
                'idComunidadEnergetica': a.idComunidadEnergetica
            })
        
        with open(os.path.join(metadatos_dir, 'activos_generacion.json'), 'w', encoding='utf-8') as f:
            json.dump(activos_gen_list, f, indent=2, ensure_ascii=False)
        
        # Activos de almacenamiento
        activos_alm_list = []
        for a in datos['activos_almacenamiento']:
            activos_alm_list.append({
                'idActivoAlmacenamiento': a.idActivoAlmacenamiento,
                'capacidadNominal_kWh': a.capacidadNominal_kWh,
                'potenciaMaximaCarga_kW': a.potenciaMaximaCarga_kW,
                'potenciaMaximaDescarga_kW': a.potenciaMaximaDescarga_kW,
                'eficienciaCicloCompleto_pct': a.eficienciaCicloCompleto_pct,
                'profundidadDescargaMax_pct': a.profundidadDescargaMax_pct,
                'idComunidadEnergetica': a.idComunidadEnergetica
            })
        
        with open(os.path.join(metadatos_dir, 'activos_almacenamiento.json'), 'w', encoding='utf-8') as f:
            json.dump(activos_alm_list, f, indent=2, ensure_ascii=False)
        
        # Coeficientes de reparto
        coeficientes_list = []
        for c in datos['coeficientes']:
            coeficientes_list.append({
                'idCoeficienteReparto': c.idCoeficienteReparto,
                'tipoReparto': c.tipoReparto.value if hasattr(c.tipoReparto, 'value') else str(c.tipoReparto),
                'parametros': c.parametros,
                'idParticipante': c.idParticipante
            })
        
        with open(os.path.join(metadatos_dir, 'coeficientes_reparto.json'), 'w', encoding='utf-8') as f:
            json.dump(coeficientes_list, f, indent=2, ensure_ascii=False)
        
        # Contratos
        contratos_list = []
        for c in datos['contratos']:
            contratos_list.append({
                'idContrato': c.idContrato,
                'tipoContrato': c.tipoContrato.value if hasattr(c.tipoContrato, 'value') else str(c.tipoContrato),
                'precioEnergiaImportacion_eur_kWh': c.precioEnergiaImportacion_eur_kWh,
                'precioCompensacionExcedentes_eur_kWh': c.precioCompensacionExcedentes_eur_kWh,
                'potenciaContratada_kW': c.potenciaContratada_kW,
                'precioPotenciaContratado_eur_kWh': c.precioPotenciaContratado_eur_kWh,
                'idParticipante': c.idParticipante
            })
        
        with open(os.path.join(metadatos_dir, 'contratos.json'), 'w', encoding='utf-8') as f:
            json.dump(contratos_list, f, indent=2, ensure_ascii=False)
            
    except Exception as e:
        print(f"Error generando archivos JSON: {e}")
        raise e

def _generar_archivos_csv_consumo(consumo_dir: str, participantes: list, registro_consumo_repo, fecha_inicio: Optional[datetime] = None, fecha_fin: Optional[datetime] = None):
    
    for participante in participantes:
        try:
            print(f"Generando CSV para participante {participante.idParticipante}")
            
            # Obtener datos de consumo del participante usando el método correcto
            if fecha_inicio and fecha_fin:
                registros = registro_consumo_repo.get_by_participante_y_periodo(
                    participante.idParticipante,
                    fecha_inicio=fecha_inicio,
                    fecha_fin=fecha_fin
                )
            else:
                registros = registro_consumo_repo.get_by_participante(participante.idParticipante)
            
            print(f"Encontrados {len(registros)} registros para participante {participante.idParticipante}")
            
            if registros:
                nombre_archivo = f"participante_{participante.idParticipante}_{participante.nombre.replace(' ', '_')}_consumo.csv"
                ruta_archivo = os.path.join(consumo_dir, nombre_archivo)
                
                with open(ruta_archivo, 'w', newline='', encoding='utf-8') as csvfile:
                    fieldnames = ['timestamp', 'consumoEnergia_kWh', 'idParticipante']
                    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                    
                    writer.writeheader()
                    for registro in registros:
                        writer.writerow({
                            'timestamp': registro.timestamp.isoformat(),
                            'consumoEnergia_kWh': registro.consumoEnergia,
                            'idParticipante': registro.idParticipante
                        })
                        
        except Exception as e:
            print(f"Error generando CSV para participante {participante.idParticipante}: {e}")
            continue

def _crear_archivo_zip(temp_dir: str, ruta_zip: str, directorios: list):
    
    try:
        with zipfile.ZipFile(ruta_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for directorio in directorios:
                dir_path = os.path.join(temp_dir, directorio)
                if os.path.exists(dir_path):
                    for root, dirs, files in os.walk(dir_path):
                        for file in files:
                            file_path = os.path.join(root, file)
                            arc_name = os.path.relpath(file_path, temp_dir)
                            zipf.write(file_path, arc_name)
    except Exception as e:
        print(f"Error creando archivo ZIP: {e}")
        raise e

def _crear_metadatos_exportacion(datos: Dict[str, Any], fecha_inicio: Optional[datetime] = None, fecha_fin: Optional[datetime] = None) -> Dict[str, Any]:
    
    periodo_str = None
    if fecha_inicio and fecha_fin:
        periodo_str = f"{fecha_inicio.strftime('%Y-%m-%d')} a {fecha_fin.strftime('%Y-%m-%d')}"
    elif fecha_inicio:
        periodo_str = f"Desde {fecha_inicio.strftime('%Y-%m-%d')}"
    elif fecha_fin:
        periodo_str = f"Hasta {fecha_fin.strftime('%Y-%m-%d')}"
    else:
        periodo_str = "Todos los datos disponibles"
    
    return {
        'fecha_exportacion': datetime.now().isoformat(),
        'version_sistema': "1.0",
        'total_participantes': len(datos['participantes']),
        'total_activos_generacion': len(datos['activos_generacion']),
        'total_activos_almacenamiento': len(datos['activos_almacenamiento']),
        'periodo_datos_consumo': periodo_str
    } 