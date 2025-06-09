import os
import json
import csv
import zipfile
import tempfile
from datetime import datetime
from typing import Dict, Any, List
from sqlalchemy.orm import Session

def importar_comunidad_completa_use_case(
    archivo_zip_path: str, 
    db: Session,
    id_usuario: int
) -> Dict[str, Any]:
    
    try:
        print(f"Iniciando importación desde: {archivo_zip_path}")
        
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
        
        # Crear directorio temporal para extraer ZIP
        temp_dir = tempfile.mkdtemp()
        print(f"Directorio temporal creado: {temp_dir}")
        
        # Extraer ZIP
        with zipfile.ZipFile(archivo_zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        
        print("Archivo ZIP extraído")
        
        # Leer y parsear datos
        datos_importacion = _leer_datos_zip(temp_dir)
        print("Datos del ZIP leídos y parseados")
        
        # Crear nuevas entidades en orden correcto
        resultado = _crear_entidades_bd(
            datos_importacion, 
            id_usuario,
            comunidad_repo,
            participante_repo,
            activo_gen_repo,
            activo_alm_repo,
            coeficiente_repo,
            registro_consumo_repo,
            contrato_repo
        )
        
        print("Entidades creadas en base de datos")
        
        # Limpiar directorio temporal
        import shutil
        shutil.rmtree(temp_dir, ignore_errors=True)
        
        return resultado
        
    except Exception as e:
        print(f"Error en importación: {str(e)}")
        # Limpiar directorio temporal en caso de error
        import shutil
        if 'temp_dir' in locals():
            shutil.rmtree(temp_dir, ignore_errors=True)
        raise e

def _leer_datos_zip(temp_dir: str) -> Dict[str, Any]:
    
    datos = {}
    
    # Leer JSONs de metadatos
    metadatos_dir = os.path.join(temp_dir, "metadatos")
    if os.path.exists(metadatos_dir):
        # Comunidad
        comunidad_file = os.path.join(metadatos_dir, "comunidad.json")
        if os.path.exists(comunidad_file):
            with open(comunidad_file, 'r', encoding='utf-8') as f:
                datos['comunidad'] = json.load(f)
                print(f"Comunidad leída: {datos['comunidad']['nombre']}")
        
        # Participantes
        participantes_file = os.path.join(metadatos_dir, "participantes.json")
        if os.path.exists(participantes_file):
            with open(participantes_file, 'r', encoding='utf-8') as f:
                datos['participantes'] = json.load(f)
                print(f"Participantes leídos: {len(datos['participantes'])}")
        
        # Activos de generación
        activos_gen_file = os.path.join(metadatos_dir, "activos_generacion.json")
        if os.path.exists(activos_gen_file):
            with open(activos_gen_file, 'r', encoding='utf-8') as f:
                datos['activos_generacion'] = json.load(f)
                print(f"Activos de generación leídos: {len(datos['activos_generacion'])}")
        
        # Activos de almacenamiento
        activos_alm_file = os.path.join(metadatos_dir, "activos_almacenamiento.json")
        if os.path.exists(activos_alm_file):
            with open(activos_alm_file, 'r', encoding='utf-8') as f:
                datos['activos_almacenamiento'] = json.load(f)
                print(f"Activos de almacenamiento leídos: {len(datos['activos_almacenamiento'])}")
        
        # Coeficientes de reparto
        coeficientes_file = os.path.join(metadatos_dir, "coeficientes_reparto.json")
        if os.path.exists(coeficientes_file):
            with open(coeficientes_file, 'r', encoding='utf-8') as f:
                datos['coeficientes'] = json.load(f)
                print(f"Coeficientes leídos: {len(datos['coeficientes'])}")
        
        # Contratos
        contratos_file = os.path.join(metadatos_dir, "contratos.json")
        if os.path.exists(contratos_file):
            with open(contratos_file, 'r', encoding='utf-8') as f:
                datos['contratos'] = json.load(f)
                print(f"Contratos leídos: {len(datos['contratos'])}")
    
    # Leer CSVs de datos de consumo
    consumo_dir = os.path.join(temp_dir, "datos_consumo")
    if os.path.exists(consumo_dir):
        datos['registros_consumo'] = []
        for archivo in os.listdir(consumo_dir):
            if archivo.endswith('.csv'):
                archivo_path = os.path.join(consumo_dir, archivo)
                with open(archivo_path, 'r', encoding='utf-8') as csvfile:
                    reader = csv.DictReader(csvfile)
                    registros = list(reader)
                    datos['registros_consumo'].extend(registros)
                    print(f"Registros de consumo leídos desde {archivo}: {len(registros)}")
    
    return datos

def _crear_entidades_bd(
    datos: Dict[str, Any],
    id_usuario: int,
    comunidad_repo,
    participante_repo,
    activo_gen_repo,
    activo_alm_repo,
    coeficiente_repo,
    registro_consumo_repo,
    contrato_repo
) -> Dict[str, Any]:
    
    from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
    from app.domain.entities.participante import ParticipanteEntity
    from app.domain.entities.activo_generacion import ActivoGeneracionEntity
    from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
    from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
    from app.domain.entities.registro_consumo import RegistroConsumoEntity
    from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
    from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes
    from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
    from app.domain.entities.tipo_reparto import TipoReparto
    from app.domain.entities.tipo_contrato import TipoContrato
    from datetime import datetime, date
    
    resultado = {
        'comunidad_creada': None,
        'participantes_creados': 0,
        'activos_generacion_creados': 0,
        'activos_almacenamiento_creados': 0,
        'coeficientes_creados': 0,
        'contratos_creados': 0,
        'registros_consumo_creados': 0,
        'mapeo_participantes': {}  # mapeo de ID original -> nuevo ID
    }
    
    # 1. Crear comunidad (sin ID para generar uno nuevo)
    if 'comunidad' in datos:
        comunidad_data = datos['comunidad']
        
        # Convertir enum si es necesario
        tipo_estrategia = TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES  # Valor por defecto
        if isinstance(comunidad_data.get('tipoEstrategiaExcedentes'), str):
            try:
                tipo_estrategia = TipoEstrategiaExcedentes(comunidad_data['tipoEstrategiaExcedentes'])
            except:
                pass
        
        nueva_comunidad = ComunidadEnergeticaEntity(
            nombre=f"{comunidad_data['nombre']}_importada_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
            latitud=comunidad_data.get('latitud'),
            longitud=comunidad_data.get('longitud'),
            tipoEstrategiaExcedentes=tipo_estrategia,  # Pasar el enum directamente
            idUsuario=id_usuario  # Usar el usuario actual
        )
        
        comunidad_creada = comunidad_repo.create(nueva_comunidad)
        resultado['comunidad_creada'] = comunidad_creada
        print(f"Comunidad creada con ID: {comunidad_creada.idComunidadEnergetica}")
    
    # 2. Crear participantes
    if 'participantes' in datos and resultado['comunidad_creada']:
        for participante_data in datos['participantes']:
            nuevo_participante = ParticipanteEntity(
                nombre=participante_data['nombre'],
                idComunidadEnergetica=resultado['comunidad_creada'].idComunidadEnergetica
            )
            
            participante_creado = participante_repo.create(nuevo_participante)
            
            # Mapear ID original -> nuevo ID
            id_original = participante_data['idParticipante']
            resultado['mapeo_participantes'][id_original] = participante_creado.idParticipante
            resultado['participantes_creados'] += 1
            
            print(f"Participante creado: {participante_creado.nombre} (ID: {participante_creado.idParticipante})")
    
    # 3. Crear activos de generación
    if 'activos_generacion' in datos and resultado['comunidad_creada']:
        for activo_data in datos['activos_generacion']:
            
            # Convertir enum si es necesario
            tipo_activo = TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA
            if isinstance(activo_data.get('tipo_activo'), str):
                try:
                    tipo_activo = TipoActivoGeneracion(activo_data['tipo_activo'])
                except:
                    pass
            
            # Convertir fecha si existe
            fecha_instalacion = None
            if activo_data.get('fechaInstalacion'):
                try:
                    fecha_instalacion = datetime.fromisoformat(activo_data['fechaInstalacion']).date()
                except:
                    pass
            
            nuevo_activo = ActivoGeneracionEntity(
                nombreDescriptivo=activo_data.get('nombreDescriptivo'),
                tipo_activo=tipo_activo,  # Pasar el enum directamente
                potenciaNominal_kWp=activo_data.get('potenciaNominal_kWp'),
                latitud=activo_data.get('latitud'),
                longitud=activo_data.get('longitud'),
                azimutGrados=activo_data.get('azimutGrados'),
                inclinacionGrados=activo_data.get('inclinacionGrados'),
                tecnologiaPanel=activo_data.get('tecnologiaPanel'),
                perdidaSistema=activo_data.get('perdidaSistema'),
                posicionMontaje=activo_data.get('posicionMontaje'),
                curvaPotencia=activo_data.get('curvaPotencia'),
                fechaInstalacion=fecha_instalacion,
                costeInstalacion_eur=activo_data.get('costeInstalacion_eur'),
                vidaUtil_anios=activo_data.get('vidaUtil_anios'),
                idComunidadEnergetica=resultado['comunidad_creada'].idComunidadEnergetica
            )
            
            activo_gen_repo.create(nuevo_activo)
            resultado['activos_generacion_creados'] += 1
    
    # 4. Crear activos de almacenamiento
    if 'activos_almacenamiento' in datos and resultado['comunidad_creada']:
        for activo_data in datos['activos_almacenamiento']:
            nuevo_activo = ActivoAlmacenamientoEntity(
                capacidadNominal_kWh=activo_data.get('capacidadNominal_kWh'),
                potenciaMaximaCarga_kW=activo_data.get('potenciaMaximaCarga_kW'),
                potenciaMaximaDescarga_kW=activo_data.get('potenciaMaximaDescarga_kW'),
                eficienciaCicloCompleto_pct=activo_data.get('eficienciaCicloCompleto_pct'),
                profundidadDescargaMax_pct=activo_data.get('profundidadDescargaMax_pct'),
                idComunidadEnergetica=resultado['comunidad_creada'].idComunidadEnergetica
            )
            
            activo_alm_repo.create(nuevo_activo)
            resultado['activos_almacenamiento_creados'] += 1
    
    # 5. Crear coeficientes de reparto
    if 'coeficientes' in datos and resultado['mapeo_participantes']:
        for coef_data in datos['coeficientes']:
            id_participante_original = coef_data['idParticipante']
            if id_participante_original in resultado['mapeo_participantes']:
                nuevo_id_participante = resultado['mapeo_participantes'][id_participante_original]
                
                # Convertir enum si es necesario
                tipo_reparto = TipoReparto.REPARTO_FIJO  # Valor por defecto
                if isinstance(coef_data.get('tipoReparto'), str):
                    try:
                        tipo_reparto = TipoReparto(coef_data['tipoReparto'])
                    except:
                        pass
                
                nuevo_coeficiente = CoeficienteRepartoEntity(
                    tipoReparto=tipo_reparto.value,  # Usar .value para obtener el string
                    parametros=coef_data.get('parametros', {}),
                    idParticipante=nuevo_id_participante
                )
                
                coeficiente_repo.create(nuevo_coeficiente)
                resultado['coeficientes_creados'] += 1
    
    # 6. Crear contratos
    if 'contratos' in datos and resultado['mapeo_participantes']:
        for contrato_data in datos['contratos']:
            id_participante_original = contrato_data['idParticipante']
            if id_participante_original in resultado['mapeo_participantes']:
                nuevo_id_participante = resultado['mapeo_participantes'][id_participante_original]
                
                # Convertir enum si es necesario
                tipo_contrato = TipoContrato.PVPC  # Valor por defecto
                if isinstance(contrato_data.get('tipoContrato'), str):
                    try:
                        tipo_contrato = TipoContrato(contrato_data['tipoContrato'])
                    except:
                        pass
                
                nuevo_contrato = ContratoAutoconsumoEntity(
                    tipoContrato=tipo_contrato,  # Pasar el enum directamente
                    precioEnergiaImportacion_eur_kWh=contrato_data.get('precioEnergiaImportacion_eur_kWh'),
                    precioCompensacionExcedentes_eur_kWh=contrato_data.get('precioCompensacionExcedentes_eur_kWh'),
                    potenciaContratada_kW=contrato_data.get('potenciaContratada_kW'),
                    precioPotenciaContratado_eur_kWh=contrato_data.get('precioPotenciaContratado_eur_kWh'),
                    idParticipante=nuevo_id_participante
                )
                
                contrato_repo.create(nuevo_contrato)
                resultado['contratos_creados'] += 1
    
    # 7. Crear registros de consumo
    if 'registros_consumo' in datos and resultado['mapeo_participantes']:
        for registro_data in datos['registros_consumo']:
            id_participante_original = int(registro_data['idParticipante'])
            if id_participante_original in resultado['mapeo_participantes']:
                nuevo_id_participante = resultado['mapeo_participantes'][id_participante_original]
                
                # Convertir timestamp
                timestamp = datetime.fromisoformat(registro_data['timestamp'])
                
                nuevo_registro = RegistroConsumoEntity(
                    timestamp=timestamp,
                    consumoEnergia=float(registro_data['consumoEnergia_kWh']),
                    idParticipante=nuevo_id_participante
                )
                
                registro_consumo_repo.create(nuevo_registro)
                resultado['registros_consumo_creados'] += 1
                
                # Mostrar progreso cada 100 registros
                if resultado['registros_consumo_creados'] % 100 == 0:
                    print(f"Registros de consumo creados: {resultado['registros_consumo_creados']}")
    
    print(f"Importación completada:")
    print(f"- Comunidad: {resultado['comunidad_creada'].nombre if resultado['comunidad_creada'] else 'No creada'}")
    print(f"- Participantes: {resultado['participantes_creados']}")
    print(f"- Activos generación: {resultado['activos_generacion_creados']}")
    print(f"- Activos almacenamiento: {resultado['activos_almacenamiento_creados']}")
    print(f"- Coeficientes: {resultado['coeficientes_creados']}")
    print(f"- Contratos: {resultado['contratos_creados']}")
    print(f"- Registros consumo: {resultado['registros_consumo_creados']}")
    
    return resultado 