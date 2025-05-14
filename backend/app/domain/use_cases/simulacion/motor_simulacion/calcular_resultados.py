"""
Módulo para cálculo de resultados de simulación.

Este módulo contiene las funciones necesarias para calcular los 
resultados globales y agregados de una simulación de comunidad energética.
"""
from typing import List, Dict, Any
from datetime import datetime

from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.entities.simulacion import SimulacionEntity
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity


def calcular_resultados_participantes(resultados_intervalo_participantes):
    """
    Calcula resultados agregados por participante a partir de los datos de intervalo.
    
    Args:
        resultados_intervalo_participantes: Lista de resultados por intervalo para cada participante
        
    Returns:
        List[ResultadoSimulacionParticipanteEntity]: Lista de entidades de resultado por participante
    """
    # Diccionario para agrupar por participante
    participantes_dict = {}
    
    
    # Agrupar datos por participante
    for resultado in resultados_intervalo_participantes:
        participante_id = resultado.get('idParticipante')
        if participante_id not in participantes_dict:
            participantes_dict[participante_id] = {
                'idParticipante': participante_id,
                'consumoTotal_kWh': 0.0,
                'energiaAutoconsumidaDirecta_kWh': 0.0,
                'energiaRecibidaRepartoConsumida_kWh': 0.0,
                'energiaAlmacenamiento_kWh': 0.0,
                'energiaImportadaRed_kWh': 0.0,
                'energiaExportadaRed_kWh': 0.0,
                'costeImportacion_eur': 0.0,
                'ingresoExportacion_eur': 0.0,
                'costeBaseEstimado_eur': 0.0,
                'numIntervalos': 0
            }
        
        # Sumar valores para este participante
        datos_part = participantes_dict[participante_id]
        
        # Valores energéticos
        consumo = resultado.get('consumoReal_kWh', 0) or 0
        autoconsumo = resultado.get('autoconsumo_kWh', 0) or 0
        energia_recibida_reparto = resultado.get('energiaRecibidaReparto_kWh', 0) or 0
        energia_almacenamiento = resultado.get('energiaAlmacenamiento_kWh', 0) or 0
        excedente_vertido = resultado.get('excedenteVertidoCompensado_kWh', 0) or 0
        diferencia = resultado.get('energiaDiferencia_kWh', 0) or 0
        
        # Importación: energía que se compra de la red (diferencia negativa)
        energia_importada = -diferencia if diferencia < 0 else 0
        
        # Precios para cálculos económicos
        precio_importacion = resultado.get('precioImportacionIntervalo', 0) or 0
        precio_exportacion = resultado.get('precioExportacionIntervalo', 0) or 0
        
        # Cálculos económicos
        coste_importacion = energia_importada * precio_importacion
        ingreso_exportacion = excedente_vertido * precio_exportacion
        
        # Acumular valores
        datos_part['consumoTotal_kWh'] += consumo
        datos_part['energiaAutoconsumidaDirecta_kWh'] += autoconsumo
        datos_part['energiaRecibidaRepartoConsumida_kWh'] += energia_recibida_reparto
        datos_part['energiaAlmacenamiento_kWh'] += energia_almacenamiento
        datos_part['energiaImportadaRed_kWh'] += energia_importada
        datos_part['energiaExportadaRed_kWh'] += excedente_vertido
        datos_part['costeImportacion_eur'] += coste_importacion
        datos_part['ingresoExportacion_eur'] += ingreso_exportacion
        datos_part['costeBaseEstimado_eur'] += consumo * precio_importacion
    
    # Crear entidades a partir del diccionario agrupado
    resultados = []
    for participante_id, datos in participantes_dict.items():
        # Calcular métricas
        consumo_total = datos['consumoTotal_kWh']
        energia_autoconsumida = datos['energiaAutoconsumidaDirecta_kWh']
        energia_reparto = datos['energiaRecibidaRepartoConsumida_kWh']
        energia_almacenamiento = datos['energiaAlmacenamiento_kWh']
        
        # Cálculos económicos
        coste_neto = datos['costeImportacion_eur'] - datos['ingresoExportacion_eur']
        
        # Calcular coste sin autoconsumo (todo el consumo a precio de importación)
        coste_base_estimado = datos['costeBaseEstimado_eur']
        
        # Ahorro (diferencia entre coste base y coste neto)
        ahorro_eur = coste_base_estimado - coste_neto
        ahorro_pct = (ahorro_eur / coste_base_estimado * 100) if coste_base_estimado > 0 else 0
        
        # Calcular tasas de autoconsumo y autosuficiencia
        tasa_autosuficiencia = (energia_autoconsumida / consumo_total * 100) 
    
        tasa_autoconsumo = (energia_autoconsumida / energia_reparto * 100) 
        
        # Crear la entidad
        resultado = ResultadoSimulacionParticipanteEntity(
            idParticipante=participante_id,
            energiaAutoconsumidaDirecta_kWh=energia_autoconsumida,
            energiaRecibidaRepartoConsumida_kWh=energia_reparto,
            tasaAutosuficienciaSSR_pct=tasa_autosuficiencia,
            tasaAutoconsumoSCR_pct=tasa_autoconsumo,
            costeNetoParticipante_eur=coste_neto,
            ahorroParticipante_eur=ahorro_eur,
            consumo_kWh=consumo_total,
            ahorroParticipante_pct=ahorro_pct
        )
        resultados.append(resultado)
    
    print(f"  ✓ Resultados por participante calculados: {len(resultados)} participantes (agrupados)")
    return resultados


def calcular_resultados_activos_gen(resultados_intervalo_activos, activos_gen):
    """
    Calcula resultados agregados por activo de generación a partir de los datos de intervalo.
    
    Args:
        resultados_intervalo_activos: Lista de resultados por intervalo para cada activo
        activos_gen: Lista de entidades de activos de generación, con información técnica
        
    Returns:
        List[ResultadoSimulacionActivoGeneracionEntity]: Lista de entidades de resultado por activo
    """
    # Diccionario para agrupar por activo de generación
    activos_gen_dict = {}
    
    # Crear un mapa de activos para acceso rápido a sus propiedades
    mapa_activos = {activo.idActivoGeneracion: activo for activo in activos_gen}
    
    # Determinar duración total de la simulación (en horas)
    if resultados_intervalo_activos:
        # Obtener todos los timestamps únicos
        timestamps = set(resultado.get('timestamp') for resultado in resultados_intervalo_activos)
        horas_simulacion = len(timestamps)
    else:
        horas_simulacion = 0
    
    print(f"  • Duración de la simulación: {horas_simulacion} horas")
    
    # Agrupar datos por activo
    for resultado in resultados_intervalo_activos:
        activo_id = resultado.get('idActivoGeneracion')
        if activo_id not in activos_gen_dict:
            activos_gen_dict[activo_id] = {
                'idActivoGeneracion': activo_id,
                'energiaTotalGenerada_kWh': 0.0,
                'horasProduccionEfectiva': 0,
                'potenciaTotal_kW': 0.0,
                'numIntervalos': 0,
                'radiacion_total': 0.0,    # Para calcular performanceRatio
                'intervalos_con_radiacion': 0  # Contar intervalos con radiación
            }
        
        # Sumar valores para este activo
        datos_activo = activos_gen_dict[activo_id]
        energia_generada = resultado.get('energiaGenerada_kWh', 0) or 0
        datos_activo['energiaTotalGenerada_kWh'] += energia_generada
        datos_activo['numIntervalos'] += 1
        datos_activo['potenciaTotal_kW'] += energia_generada  # Aproximación para calcular potencia media
        
        # Contar horas de producción efectiva (cuando hay generación > 0)
        if energia_generada > 0:
            datos_activo['horasProduccionEfectiva'] += 1
        
        # Si hay datos de radiación disponibles (para solar)
        radiacion = resultado.get('radiacion_kWh_m2', 0) or 0
        if radiacion > 0:
            datos_activo['radiacion_total'] += radiacion
            datos_activo['intervalos_con_radiacion'] += 1
    
    # Crear entidades a partir del diccionario agrupado
    resultados = []
    for activo_id, datos in activos_gen_dict.items():
        # Obtener el activo correspondiente
        activo = mapa_activos.get(activo_id)
        if not activo:
            print(f"  [WARN] No se encontró información del activo ID {activo_id}, usando valores predeterminados")
            continue
            
        # Extraer propiedades técnicas del activo
        potencia_nominal = getattr(activo, 'potenciaNominal_kW', 0) or 0
        eficiencia = getattr(activo, 'eficiencia_pct', 0) or 0
        
        # 1. energiaTotalGenerada_kWh - Ya calculada durante la agregación
        energia_total = datos['energiaTotalGenerada_kWh']
        
        # 2. factorCapacidad_pct: Relación entre energía real y máxima teórica
        factor_capacidad = 0
        if potencia_nominal > 0 and horas_simulacion > 0:
            energia_maxima_teorica = potencia_nominal * horas_simulacion
            factor_capacidad = (energia_total / energia_maxima_teorica) * 100
        
        # 3. performanceRatio_pct: Comparación con producción teórica según radiación
        performance_ratio = 0
        if datos['radiacion_total'] > 0 and eficiencia > 0:
            # Para sistemas fotovoltaicos
            area_efectiva = getattr(activo, 'areaEfectiva_m2', 0) or 0
            if area_efectiva > 0:
                energia_teorica = datos['radiacion_total'] * area_efectiva * (eficiencia / 100)
                if energia_teorica > 0:
                    performance_ratio = (energia_total / energia_teorica) * 100
        
        # 4. horasOperacionEquivalentes: Horas a plena potencia para producir la energía total
        horas_equivalentes = 0
        if potencia_nominal > 0:
            horas_equivalentes = energia_total / potencia_nominal
        
        resultado = ResultadoSimulacionActivoGeneracionEntity(
            idActivoGeneracion=activo_id,
            energiaTotalGenerada_kWh=energia_total,
            factorCapacidad_pct=factor_capacidad,
            performanceRatio_pct=performance_ratio,
            horasOperacionEquivalentes=horas_equivalentes
        )
        resultados.append(resultado)
        
        print(f"  • Activo Gen ID {activo_id}: Generación={energia_total:.2f} kWh, "
              f"Factor Cap.={factor_capacidad:.2f}%, Horas Eq.={horas_equivalentes:.2f}")
    
    print(f"  ✓ Resultados por activo de generación calculados: {len(resultados)} activos (agrupados)")
    return resultados


def calcular_resultados_activos_alm(resultados_intervalo_activos, activos_alm):
    """
    Calcula resultados agregados por activo de almacenamiento a partir de los datos de intervalo.
    
    Args:
        resultados_intervalo_activos: Lista de resultados por intervalo para cada activo
        activos_alm: Lista de entidades de activos de almacenamiento, con información técnica
        
    Returns:
        List[ResultadoSimulacionActivoAlmacenamientoEntity]: Lista de entidades de resultado por activo
    """
    # Diccionario para agrupar por activo de almacenamiento
    activos_alm_dict = {}
    
    # Crear un mapa de activos para acceso rápido a sus propiedades
    mapa_activos = {activo.idActivoAlmacenamiento: activo for activo in activos_alm}
    
    # Agrupar datos por activo
    for resultado in resultados_intervalo_activos:
        activo_id = resultado.get('idActivoAlmacenamiento')
        if activo_id not in activos_alm_dict:
            activos_alm_dict[activo_id] = {
                'idActivoAlmacenamiento': activo_id,
                'energiaTotalCargada_kWh': 0.0,
                'energiaTotalDescargada_kWh': 0.0,
                'ciclosCompletos': 0.0,
                'horasCarga': 0,
                'horasDescarga': 0,
                'horasInactivo': 0,
                'soc_suma_kWh': 0.0,
                'soc_valores': [],  # Para calcular el SoC medio
                'soc_max_kWh': 0.0,
                'soc_min_kWh': float('inf'),
                'numIntervalos': 0
            }
        
        # Sumar valores para este activo
        datos_activo = activos_alm_dict[activo_id]
        energia_cargada = resultado.get('energiaCargada_kWh', 0) or 0
        energia_descargada = resultado.get('energiaDescargada_kWh', 0) or 0
        soc_actual = resultado.get('SoC_kWh', 0) or 0
        
        # Acumular valores
        datos_activo['energiaTotalCargada_kWh'] += energia_cargada
        datos_activo['energiaTotalDescargada_kWh'] += energia_descargada
        datos_activo['soc_suma_kWh'] += soc_actual
        datos_activo['soc_valores'].append(soc_actual)
        datos_activo['numIntervalos'] += 1
        
        # Actualizar SoC máximo y mínimo
        if soc_actual > datos_activo['soc_max_kWh']:
            datos_activo['soc_max_kWh'] = soc_actual
        if soc_actual < datos_activo['soc_min_kWh']:
            datos_activo['soc_min_kWh'] = soc_actual
        
        # Contar horas de carga, descarga e inactividad
        if energia_cargada > 0:
            datos_activo['horasCarga'] += 1
        elif energia_descargada > 0:
            datos_activo['horasDescarga'] += 1
        else:
            datos_activo['horasInactivo'] += 1
    
    # Crear entidades a partir del diccionario agrupado
    resultados = []
    for activo_id, datos in activos_alm_dict.items():
        # Obtener el activo correspondiente
        activo = mapa_activos.get(activo_id)
        if not activo:
            print(f"  [WARN] No se encontró información del activo de almacenamiento ID {activo_id}, usando valores predeterminados")
            continue
            
        # Extraer propiedades técnicas del activo
        capacidad_nominal = activo.capacidadNominal_kWh or 1.0  # Evitar división por cero
        
        # 1. energiaTotalCargada_kWh - Ya calculada durante la agregación
        energia_cargada = datos['energiaTotalCargada_kWh']
        
        # 2. energiaTotalDescargada_kWh - Ya calculada durante la agregación
        energia_descargada = datos['energiaTotalDescargada_kWh']
        
        # 3. ciclosEquivalentes: Energía descargada / Capacidad nominal
        ciclos_equivalentes = energia_descargada / capacidad_nominal
        
        # 4. perdidasEficiencia_kWh: Diferencia entre energía cargada y descargada
        perdidas_eficiencia = energia_cargada - energia_descargada
        
        # 5. socMedio_pct: SoC medio como porcentaje de la capacidad nominal
        soc_medio_kwh = datos['soc_suma_kWh'] / datos['numIntervalos'] if datos['numIntervalos'] > 0 else 0
        soc_medio_pct = (soc_medio_kwh / capacidad_nominal) * 100
        
        # 6. socMin_pct: SoC mínimo como porcentaje de la capacidad nominal
        soc_min = datos['soc_min_kWh'] if datos['soc_min_kWh'] != float('inf') else 0
        soc_min_pct = (soc_min / capacidad_nominal) * 100
        
        # 7. socMax_pct: SoC máximo como porcentaje de la capacidad nominal
        soc_max = datos['soc_max_kWh']
        soc_max_pct = (soc_max / capacidad_nominal) * 100
        
        # 8. degradacionEstimada_pct: Estimación basada en ciclos y DoD
        # Implementación simplificada basada en ciclos equivalentes
        # Un modelo más complejo requeriría variables adicionales (temperatura, tiempo, etc.)
        degradacion_por_ciclo = 0.004  # 0.4% por ciclo completo (simplificación)
        degradacion_estimada = ciclos_equivalentes * degradacion_por_ciclo
        
        # Calcular DoD medio para ajustar estimación de degradación
        if len(datos['soc_valores']) > 1:
            # Calcular diferencias entre valores consecutivos de SoC
            dod_valores = []
            for i in range(1, len(datos['soc_valores'])):
                dif = datos['soc_valores'][i-1] - datos['soc_valores'][i]
                if dif > 0:  # Solo considerar descargas (dif positiva)
                    dod_valores.append(dif / capacidad_nominal * 100)
            
            # DoD medio como porcentaje
            dod_medio = sum(dod_valores) / len(dod_valores) if dod_valores else 0
            
            # Ajustar degradación según DoD medio (DoD más profundo acelera degradación)
            factor_dod = 1.0 + (dod_medio / 100)  # Factor que aumenta con DoD mayor
            degradacion_estimada *= factor_dod
        
        # Limitar degradación a valores razonables (0-100%)
        degradacion_estimada = min(100, max(0, degradacion_estimada))
        
        # 9. throughputTotal_kWh: Suma de energía cargada y descargada
        throughput_total = energia_cargada + energia_descargada
        
        # Calcular utilización (% de tiempo en carga o descarga)
        utilizacion_pct = ((datos['horasCarga'] + datos['horasDescarga']) / datos['numIntervalos'] * 100) if datos['numIntervalos'] > 0 else 0
        
        resultado = ResultadoSimulacionActivoAlmacenamientoEntity(
            idActivoAlmacenamiento=activo_id,
            energiaTotalCargada_kWh=energia_cargada,
            energiaTotalDescargada_kWh=energia_descargada,
            ciclosEquivalentes=ciclos_equivalentes,
            perdidasEficiencia_kWh=perdidas_eficiencia,
            socMedio_pct=soc_medio_pct,
            socMin_pct=soc_min_pct,
            socMax_pct=soc_max_pct,
            degradacionEstimada_pct=degradacion_estimada,
            throughputTotal_kWh=throughput_total
        )
        resultados.append(resultado)
        
        print(f"  • Activo Alm ID {activo_id}: Cargado={energia_cargada:.2f} kWh, "
              f"Descargado={energia_descargada:.2f} kWh, Ciclos={ciclos_equivalentes:.2f}, "
              f"SoC Medio={soc_medio_pct:.1f}%")
    
    print(f"  ✓ Resultados por activo de almacenamiento calculados: {len(resultados)} activos (agrupados)")
    return resultados


def calcular_resultados_globales(simulacion, resultados_intervalo_participantes,
                               resultados_intervalo_activos_generacion, 
                               resultados_intervalo_activos_almacenamiento,
                               activos_gen=None, activos_alm=None):
    """
    Calcula resultados globales de la simulación.
    
    Args:
        simulacion: Entidad de simulación
        resultados_intervalo_participantes: Lista de resultados por intervalo para cada participante
        resultados_intervalo_activos_generacion: Lista de resultados por intervalo para activos de generación
        resultados_intervalo_activos_almacenamiento: Lista de resultados por intervalo para activos de almacenamiento
        activos_gen: Lista de entidades de activos de generación (opcional, para cálculos financieros)
        activos_alm: Lista de entidades de activos de almacenamiento (opcional, para cálculos financieros)
        
    Returns:
        ResultadoSimulacionEntity: Entidad con los resultados globales de la simulación
    """
    # Sumar valores básicos por intervalo para calcular totales
    total_consumo = 0.0
    total_generacion = 0.0
    total_autoconsumo = 0.0
    total_importacion = 0.0
    total_exportacion = 0.0
    total_carga_alm = 0.0
    total_descarga_alm = 0.0
    total_coste_importacion = 0.0
    total_ingreso_exportacion = 0.0
    coste_base_estimado = 0.0     
    
    # Calcular consumo, autoconsumo, importación, exportación, etc.
    for resultado in resultados_intervalo_participantes:
        timestamp = resultado.get('timestamp')
        consumo = resultado.get('consumoReal_kWh', 0) or 0
        autoconsumo = resultado.get('autoconsumo_kWh', 0) or 0
        energia_reparto = resultado.get('energiaRecibidaReparto_kWh', 0) or 0
        excedente = resultado.get('excedenteVertidoCompensado_kWh', 0) or 0
        diferencia = resultado.get('energiaDiferencia_kWh', 0) or 0
        precio_importacion = resultado.get('precioImportacionIntervalo', 0) or 0

        
        # Importación: energía que se compra de la red (diferencia negativa)
        importacion = -diferencia if diferencia < 0 else 0
        
        # Acumular valores generales
        total_consumo += consumo
        total_autoconsumo += autoconsumo
        total_importacion += importacion
        total_exportacion += excedente
        coste_base_estimado += consumo * precio_importacion
        
        # Cálculos económicos con precios por intervalo
        precio_importacion = resultado.get('precioImportacionIntervalo', 0) or 0
        precio_exportacion = resultado.get('precioExportacionIntervalo', 0) or 0
        
        total_coste_importacion += importacion * precio_importacion
        total_ingreso_exportacion += excedente * precio_exportacion
        
    
    # Calcular generación total
    for resultado in resultados_intervalo_activos_generacion:
        total_generacion += resultado.get('energiaGenerada_kWh', 0) or 0
    
    # Calcular carga/descarga de almacenamiento
    for resultado in resultados_intervalo_activos_almacenamiento:
        total_carga_alm += resultado.get('energiaCargada_kWh', 0) or 0
        total_descarga_alm += resultado.get('energiaDescargada_kWh', 0) or 0
    
    # ---- Cálculos de tasas y métricas energéticas ----
    
    # 1. Tasas de autoconsumo y autosuficiencia
    tasa_autoconsumo = (total_autoconsumo / total_generacion * 100) if total_generacion > 0 else 0
    tasa_autosuficiencia = (total_autoconsumo / total_consumo * 100) if total_consumo > 0 else 0
    
    # ---- Cálculos económicos ----
    
    # 3. Coste total de energía
    # Asumimos costes fijos de 0 por ahora, se podrían añadir si hay datos disponibles
    costes_fijos = 0.0  
    coste_total_energia = total_coste_importacion - total_ingreso_exportacion + costes_fijos
    
    # 4. Ahorro total
    # Coste base: todo el consumo se pagaría al precio medio de importación
    coste_base_estimado = coste_base_estimado
    
    ahorro_total = coste_base_estimado - coste_total_energia
    
    # 5. Cálculos financieros (payback y ROI)
    # Todo Añadir mas información sobre costes de instalación y operación. (Inversion inicial)
    payback_period = None
    roi = None
    
    # Si tenemos datos de costes de instalación de activos
    inversion_inicial_total = 0
    if activos_gen:
        for activo in activos_gen:
            inversion_inicial_total += getattr(activo, 'costeInstalacion_eur', 0) or 0
    
    if activos_alm:
        for activo in activos_alm:
            inversion_inicial_total += getattr(activo, 'costeInstalacion_eur', 0) or 0
    
    # Estimación de ahorro anual y cálculos de retorno de inversión
    # Extrapolamos el ahorro del periodo simulado a un año completo
    periodo_simulacion_dias = (simulacion.fechaFin - simulacion.fechaInicio).days + 1
    if periodo_simulacion_dias > 0:
        factor_anual = 365.0 / periodo_simulacion_dias
        ahorro_anual_estimado = ahorro_total * factor_anual
        
        # Payback period (años)
        if ahorro_anual_estimado > 0:
            payback_period = inversion_inicial_total / ahorro_anual_estimado
            
            # ROI (%) anual
            roi = (ahorro_anual_estimado / inversion_inicial_total * 100) if inversion_inicial_total > 0 else 0
    
    # 6. Reducción de emisiones de CO2
    # Asumimos un factor de emisión promedio para España: 0.25 kgCO2eq/kWh
    # Este valor puede personalizarse según país o mix energético
    factor_emision_co2 = 0.25  # kgCO2eq/kWh
    energia_local_aprovechada = total_autoconsumo + total_exportacion
    reduccion_co2 = energia_local_aprovechada * factor_emision_co2
    
    # Crear la entidad de resultados globales, asegurando que los nombres coincidan exactamente con ResultadoSimulacionEntity
    resultado_global = ResultadoSimulacionEntity(
        costeTotalEnergia_eur=coste_total_energia,
        ahorroTotal_eur=ahorro_total,
        ingresoTotalExportacion_eur=total_ingreso_exportacion,
        paybackPeriod_anios=payback_period,
        roi_pct=roi,
        tasaAutoconsumoSCR_pct=tasa_autoconsumo,
        tasaAutosuficienciaSSR_pct=tasa_autosuficiencia,
        energiaTotalImportada_kWh=total_importacion,
        energiaTotalExportada_kWh=total_exportacion,
        reduccionCO2_kg=reduccion_co2,
        idSimulacion=simulacion.idSimulacion 
    )
    
    print(f"  ✓ Resultados globales calculados")
    print(f"    • Consumo total: {total_consumo:.2f} kWh")
    print(f"    • Generación total: {total_generacion:.2f} kWh")
    print(f"    • Autoconsumo: {total_autoconsumo:.2f} kWh ({tasa_autoconsumo:.1f}%)")
    print(f"    • Tasa autosuficiencia: {tasa_autosuficiencia:.1f}%")
    print(f"    • Ahorro estimado: {ahorro_total:.2f} €")
    if payback_period:
        print(f"    • Periodo de retorno: {payback_period:.1f} años")
    if roi:
        print(f"    • ROI anual: {roi:.1f}%")
    
    return resultado_global



def calcular_todos_resultados(simulacion: SimulacionEntity, 
                               resultados_intervalo_participantes: List[Dict[str, Any]],
                               resultados_intervalo_activos_generacion: List[Dict[str, Any]],
                               resultados_intervalo_activos_almacenamiento: List[Dict[str, Any]],
                               activos_gen: List[ActivoGeneracionEntity], activos_alm: List[ActivoAlmacenamientoEntity]) -> Dict[str, Any]:
    """
    Calcula todos los resultados de la simulación.
    
    Args:
        simulacion: Entidad de simulación
        resultados_intervalo_participantes: Lista de resultados por intervalo para cada participante
        resultados_intervalo_activos_generacion: Lista de resultados por intervalo para activos de generación
        resultados_intervalo_activos_almacenamiento: Lista de resultados por intervalo para activos de almacenamiento
        
    Returns:
        Dict[str, Any]: Diccionario con los resultados globales y por participante/activo
    """
    # Calcular resultados por participante
    resultados_participantes = calcular_resultados_participantes(resultados_intervalo_participantes)
    
    # Calcular resultados por activo de generación
    resultados_activos_gen = calcular_resultados_activos_gen(resultados_intervalo_activos_generacion, activos_gen)
    
    # Calcular resultados por activo de almacenamiento
    resultados_activos_alm = calcular_resultados_activos_alm(resultados_intervalo_activos_almacenamiento, activos_alm)
    
    # Calcular resultados globales
    resultado_global = calcular_resultados_globales(simulacion, 
                                                    resultados_intervalo_participantes,
                                                    resultados_intervalo_activos_generacion,
                                                    resultados_intervalo_activos_almacenamiento)
    
    return resultado_global, resultados_participantes, resultados_activos_gen, resultados_activos_alm