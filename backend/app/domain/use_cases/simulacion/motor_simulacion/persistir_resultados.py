from typing import List, Dict, Any
from datetime import datetime

from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity

import logging


def persistir_resultado_global(resultado_simulacion_repo, resultados_globales):
    try:
        resultado_global = resultado_simulacion_repo.create(resultados_globales)
        print(f"  ✓ Resultados globales guardados")
        return resultado_global
    except Exception as e:
        logging.error(f"Error al persistir resultados globales: {str(e)}")
        raise


def persistir_resultados_participantes(resultado_participante_repo, resultados_part, id_resultado_global):
    try:
        resultado_participantes = resultado_participante_repo.create_bulk(resultados_part, id_resultado_global)
        print(f"  ✓ Resultados de participantes guardados: {len(resultados_part)} participantes")
        return resultado_participantes
    except Exception as e:
        logging.error(f"Error al persistir resultados por participante: {str(e)}")
        raise


def persistir_resultados_activos_generacion(resultado_activo_gen_repo, resultados_activos_gen, id_resultado_global):
    try:
        resultado_activos_gen = resultado_activo_gen_repo.create_bulk(resultados_activos_gen, id_resultado_global)
        print(f"  ✓ Resultados de activos de generación guardados: {len(resultados_activos_gen)} activos")
        return resultado_activos_gen
    except Exception as e:
        logging.error(f"Error al persistir resultados por activo de generación: {str(e)}")
        raise


def persistir_resultados_activos_almacenamiento(resultado_activo_alm_repo, resultados_activos_alm, id_resultado_global):
    try:
        resultado_activos_alm = resultado_activo_alm_repo.create_bulk(resultados_activos_alm, id_resultado_global)
        print(f"  ✓ Resultados de activos de almacenamiento guardados: {len(resultados_activos_alm)} activos")
        return resultado_activos_alm
    except Exception as e:
        logging.error(f"Error al persistir resultados por activo de almacenamiento: {str(e)}")
        raise


def persistir_datos_ambientales(datos_ambientales_repo, datos_ambientales):
    try:
        datos_ambientales_persistidos = datos_ambientales_repo.create_bulk(datos_ambientales)
        print(f"  ✓ Datos ambientales guardados: {len(datos_ambientales)} registros")
        return datos_ambientales_persistidos
    except Exception as e:
        logging.error(f"Error al persistir datos ambientales: {str(e)}")
        raise


def convertir_y_persistir_intervalos_participantes(datos_intervalo_participante_repo, resultados_intervalo_participantes, resultados_participantes_dict):
    try:
        # Convertir diccionarios a entidades
        entidades_intervalo = []
        
        for resultado in resultados_intervalo_participantes:
            id_participante = resultado.get('idParticipante')
            if id_participante not in resultados_participantes_dict:
                print(f"[ADVERTENCIA] No se encontró ResultadoParticipante para participante ID {id_participante}")
                continue
                
            entidad = DatosIntervaloParticipanteEntity(
                idDatosIntervaloParticipante=None,  # Será asignado por la base de datos
                timestamp=resultado.get('timestamp'),
                consumoReal_kWh=resultado.get('consumoReal_kWh'),
                autoconsumo_kWh=resultado.get('autoconsumo_kWh'),
                energiaRecibidaReparto_kWh=resultado.get('energiaRecibidaReparto_kWh'),
                energiaAlmacenamiento_kWh=resultado.get('energiaAlmacenamiento_kWh'),
                energiaDiferencia_kWh=resultado.get('energiaDiferencia_kWh'),
                excedenteVertidoCompensado_kWh=resultado.get('excedenteVertidoCompensado_kWh'),
                precioImportacionIntervalo=resultado.get('precioImportacionIntervalo'),
                precioExportacionIntervalo=resultado.get('precioExportacionIntervalo'),
                idResultadoParticipante=resultados_participantes_dict[id_participante]  # Asignamos el ID correcto
            )
            entidades_intervalo.append(entidad)
        
        # Persistir entidades
        datos_persistidos = datos_intervalo_participante_repo.create_bulk(entidades_intervalo)
        print(f"  ✓ Intervalos de participantes guardados: {len(entidades_intervalo)} registros")
        return datos_persistidos
    except Exception as e:
        logging.error(f"Error al convertir y persistir intervalos de participantes: {str(e)}")
        raise


def convertir_y_persistir_intervalos_activos_generacion(datos_intervalo_activo_repo, resultados_intervalo_activos_generacion, resultados_activos_gen_dict):
    try:
        # Convertir diccionarios a entidades
        entidades_intervalo = []
        
        for resultado in resultados_intervalo_activos_generacion:
            id_activo = resultado.get('idActivoGeneracion')
            if id_activo not in resultados_activos_gen_dict:
                print(f"[ADVERTENCIA] No se encontró ResultadoActivoGeneracion para activo ID {id_activo}")
                continue
                
            entidad = DatosIntervaloActivoEntity(
                idDatosIntervaloActivo=None,  # Será asignado por la base de datos
                timestamp=resultado.get('timestamp'),
                energiaGenerada_kWh=resultado.get('energiaGenerada_kWh'),
                energiaCargada_kWh=None,
                energiaDescargada_kWh=None,
                SoC_kWh=None,
                idResultadoActivoGen=resultados_activos_gen_dict[id_activo],  # Asignamos el ID correcto
                idResultadoActivoAlm=None
            )
            entidades_intervalo.append(entidad)
        
        # Persistir entidades
        datos_persistidos = datos_intervalo_activo_repo.create_bulk(entidades_intervalo)
        print(f"  ✓ Intervalos de activos de generación guardados: {len(entidades_intervalo)} registros")
        return datos_persistidos
    except Exception as e:
        logging.error(f"Error al convertir y persistir intervalos de activos de generación: {str(e)}")
        raise


def convertir_y_persistir_intervalos_activos_almacenamiento(datos_intervalo_activo_repo, resultados_intervalo_activos_almacenamiento, resultados_activos_alm_dict):
    try:
        # Convertir diccionarios a entidades
        entidades_intervalo = []
        
        for resultado in resultados_intervalo_activos_almacenamiento:
            id_activo = resultado.get('idActivoAlmacenamiento')
            if id_activo not in resultados_activos_alm_dict:
                print(f"[ADVERTENCIA] No se encontró ResultadoActivoAlmacenamiento para activo ID {id_activo}")
                continue
                
            entidad = DatosIntervaloActivoEntity(
                idDatosIntervaloActivo=None,  # Será asignado por la base de datos
                timestamp=resultado.get('timestamp'),
                energiaGenerada_kWh=None,
                energiaCargada_kWh=resultado.get('energiaCargada_kWh'),
                energiaDescargada_kWh=resultado.get('energiaDescargada_kWh'),
                SoC_kWh=resultado.get('SoC_kWh'),
                idResultadoActivoGen=None,
                idResultadoActivoAlm=resultados_activos_alm_dict[id_activo]  # Asignamos el ID correcto
            )
            entidades_intervalo.append(entidad)
        
        # Persistir entidades
        datos_persistidos = datos_intervalo_activo_repo.create_bulk(entidades_intervalo)
        print(f"  ✓ Intervalos de activos de almacenamiento guardados: {len(entidades_intervalo)} registros")
        return datos_persistidos
    except Exception as e:
        logging.error(f"Error al convertir y persistir intervalos de activos de almacenamiento: {str(e)}")
        raise


def persistir_todos_los_resultados(
    repos, 
    resultados_globales,
    resultados_part,
    resultados_activos_gen,
    resultados_activos_alm,
    datos_ambientales,
    resultados_intervalo_participantes,
    resultados_intervalo_activos_generacion,
    resultados_intervalo_activos_almacenamiento
):
    try:
        print(f"\nPersistiendo resultados en base de datos...")
        
        # 1. Persistir resultado global
        resultado_global = persistir_resultado_global(repos['resultado_simulacion_repo'], resultados_globales)
        
        # 2. Persistir resultados por participante
        resultados_participantes = persistir_resultados_participantes(
            repos['resultado_participante_repo'], 
            resultados_part, 
            resultado_global.idResultado
        )
        
        # Crear diccionario de mapeo para participantes (id_participante -> id_resultado_participante)
        participantes_dict = {}
        for resultado_participante in resultados_participantes:
            participantes_dict[resultado_participante.idParticipante] = resultado_participante.idResultadoParticipante
        
        # 3. Persistir resultados por activo de generación
        resultados_activos_generacion = persistir_resultados_activos_generacion(
            repos['resultado_activo_gen_repo'], 
            resultados_activos_gen, 
            resultado_global.idResultado
        )
        
        # Crear diccionario de mapeo para activos de generación
        activos_gen_dict = {}
        for resultado_activo in resultados_activos_generacion:
            activos_gen_dict[resultado_activo.idActivoGeneracion] = resultado_activo.idResultadoActivoGen
        
        # 4. Persistir resultados por activo de almacenamiento
        resultados_activos_almacenamiento = persistir_resultados_activos_almacenamiento(
            repos['resultado_activo_alm_repo'], 
            resultados_activos_alm, 
            resultado_global.idResultado
        )
        
        # Crear diccionario de mapeo para activos de almacenamiento
        activos_alm_dict = {}
        for resultado_activo in resultados_activos_almacenamiento:
            activos_alm_dict[resultado_activo.idActivoAlmacenamiento] = resultado_activo.idResultadoActivoAlm
        
        # 5. Persistir datos ambientales
        datos_ambientales_persistidos = persistir_datos_ambientales(
            repos['datos_ambientales_repo'], 
            datos_ambientales
        )
        
        # 6. Convertir y persistir intervalos de participantes
        print(f"  • Persistiendo intervalos de participantes con {len(participantes_dict)} mapeos de ID")
        intervalos_participantes = convertir_y_persistir_intervalos_participantes(
            repos['datos_intervalo_participante_repo'], 
            resultados_intervalo_participantes,
            participantes_dict  # Pasamos el diccionario de mapeo
        )
        
        # 7. Convertir y persistir intervalos de activos de generación
        print(f"  • Persistiendo intervalos de activos de generación con {len(activos_gen_dict)} mapeos de ID")
        intervalos_activos_generacion = convertir_y_persistir_intervalos_activos_generacion(
            repos['datos_intervalo_activo_repo'], 
            resultados_intervalo_activos_generacion,
            activos_gen_dict  # Pasamos el diccionario de mapeo
        )
        
        # 8. Convertir y persistir intervalos de activos de almacenamiento
        print(f"  • Persistiendo intervalos de activos de almacenamiento con {len(activos_alm_dict)} mapeos de ID")
        intervalos_activos_almacenamiento = convertir_y_persistir_intervalos_activos_almacenamiento(
            repos['datos_intervalo_activo_repo'], 
            resultados_intervalo_activos_almacenamiento,
            activos_alm_dict  # Pasamos el diccionario de mapeo
        )
        
        print(f"  ✓ Todos los resultados guardados exitosamente")
        
        return {
            'resultado_global': resultado_global,
            'resultados_participantes': resultados_participantes,
            'resultados_activos_generacion': resultados_activos_generacion,
            'resultados_activos_almacenamiento': resultados_activos_almacenamiento,
            'datos_ambientales': datos_ambientales_persistidos,
            'intervalos_participantes': intervalos_participantes,
            'intervalos_activos_generacion': intervalos_activos_generacion,
            'intervalos_activos_almacenamiento': intervalos_activos_almacenamiento
        }
    except Exception as e:
        logging.error(f"Error al persistir todos los resultados: {str(e)}")
        raise