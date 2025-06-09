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


def calcular_termino_potencia(contrato, fecha_inicio, fecha_fin):
    """Calcula el término de potencia según la fórmula española."""
    if not contrato or not hasattr(contrato, 'potenciaContratada_kW') or not hasattr(contrato, 'precioPotenciaContratado_eur_kWh'):
        return 0.0
    
    dias_periodo = (fecha_fin - fecha_inicio).days + 1
    potencia_contratada = contrato.potenciaContratada_kW or 0.0
    precio_potencia_dia = contrato.precioPotenciaContratado_eur_kWh or 0.0
    
    termino_potencia = potencia_contratada * precio_potencia_dia * dias_periodo
    return termino_potencia


def calcular_factura_completa_espanola(coste_energia_bruto, termino_potencia):
    """Calcula la factura eléctrica completa según la estructura fiscal española."""
    # Constantes fiscales españolas
    IMPUESTO_ELECTRICO_PCT = 5.1127
    IVA_PCT = 21.0
    
    base_sin_impuestos = coste_energia_bruto + termino_potencia
    impuesto_electrico = (IMPUESTO_ELECTRICO_PCT / 100) * base_sin_impuestos
    base_iva = base_sin_impuestos + impuesto_electrico
    iva = (IVA_PCT / 100) * base_iva
    coste_total = base_sin_impuestos + impuesto_electrico + iva
    
    return {
        'base_sin_impuestos': base_sin_impuestos,
        'impuesto_electrico': impuesto_electrico,
        'iva': iva,
        'coste_total': coste_total,
        'desglose': {
            'energia': coste_energia_bruto,
            'potencia': termino_potencia,
            'subtotal_pre_impuestos': base_sin_impuestos,
            'impuesto_electrico_pct': IMPUESTO_ELECTRICO_PCT,
            'iva_pct': IVA_PCT
        }
    }


def calcular_resultados_participantes(resultados_intervalo_participantes, contratos=None, simulacion=None):
    """Calcula resultados agregados por participante."""
    
    participantes_dict = _agregar_datos_energeticos_participantes(resultados_intervalo_participantes)
    
    resultados = []
    for participante_id, datos_agregados in participantes_dict.items():
        
        contrato = contratos.get(participante_id) if contratos else None
        
        costes_economicos = _calcular_costes_economicos_mensuales(
            datos_agregados, contrato, simulacion, participante_id
        )
        
        metricas_energeticas = _calcular_metricas_energeticas_globales(datos_agregados)
        
        if len(resultados) == 0:
            _mostrar_desglose_calculo(participante_id, costes_economicos, datos_agregados)
        
        resultado = ResultadoSimulacionParticipanteEntity(
            idParticipante=participante_id,
            energiaAutoconsumidaDirecta_kWh=datos_agregados['energiaAutoconsumidaDirecta_kWh'],
            energiaRecibidaRepartoConsumida_kWh=datos_agregados['energiaRecibidaRepartoConsumida_kWh'],
            tasaAutosuficienciaSSR_pct=metricas_energeticas['ssr_pct'],
            tasaAutoconsumoSCR_pct=metricas_energeticas['scr_pct'],
            costeNetoParticipante_eur=costes_economicos['coste_total_eur'],
            ahorroParticipante_eur=costes_economicos['ahorro_total_eur'],
            consumo_kWh=datos_agregados['consumoTotal_kWh'],
            ahorroParticipante_pct=costes_economicos['ahorro_porcentual_pct']
        )
        resultados.append(resultado)
    
    print(f"  ✓ Resultados por participante calculados: {len(resultados)} participantes (cálculo económico mensual)")
    return resultados


def _agregar_datos_energeticos_participantes(resultados_intervalo_participantes):
    """Agrupa y suma los datos energéticos por participante."""
    participantes_dict = {}
    
    for resultado in resultados_intervalo_participantes:
        participante_id = resultado.get('idParticipante')
        timestamp = resultado.get('timestamp')
        
        if participante_id not in participantes_dict:
            participantes_dict[participante_id] = {
                'consumoTotal_kWh': 0.0,
                'energiaAutoconsumidaDirecta_kWh': 0.0,
                'energiaRecibidaRepartoConsumida_kWh': 0.0,
                'energiaAlmacenamiento_kWh': 0.0,
                'energiaAlmacenamientoDescargada_kWh': 0.0,
                'energiaAlmacenamientoCargada_kWh': 0.0,
                'energiaImportadaRed_kWh': 0.0,
                'energiaExportadaRed_kWh': 0.0,
                'costeImportacion_eur': 0.0,
                'ingresoExportacion_eur': 0.0,
                'costeBaseEstimado_eur': 0.0,
                'numIntervalos': 0,
                'datos_mensuales': {}
            }
        
        datos_part = participantes_dict[participante_id]
        
        mes_key = _obtener_clave_mes(timestamp)
        
        if mes_key not in datos_part['datos_mensuales']:
            datos_part['datos_mensuales'][mes_key] = {
                'consumoTotal_kWh': 0.0,
                'energiaAutoconsumidaDirecta_kWh': 0.0,
                'energiaRecibidaRepartoConsumida_kWh': 0.0,
                'energiaAlmacenamiento_kWh': 0.0,
                'energiaAlmacenamientoDescargada_kWh': 0.0,
                'energiaAlmacenamientoCargada_kWh': 0.0,
                'energiaImportadaRed_kWh': 0.0,
                'energiaExportadaRed_kWh': 0.0,
                'costeImportacion_eur': 0.0,
                'ingresoExportacion_eur': 0.0,
                'costeBaseEstimado_eur': 0.0,
                'numIntervalos': 0
            }
        
        datos_mes = datos_part['datos_mensuales'][mes_key]
        
        consumo = resultado.get('consumoReal_kWh', 0) or 0
        autoconsumo = resultado.get('autoconsumo_kWh', 0) or 0
        energia_recibida_reparto = resultado.get('energiaRecibidaReparto_kWh', 0) or 0
        energia_almacenamiento = resultado.get('energiaAlmacenamiento_kWh', 0) or 0
        excedente_vertido = resultado.get('excedenteVertidoCompensado_kWh', 0) or 0
        diferencia = resultado.get('energiaDiferencia_kWh', 0) or 0
        
        
        if diferencia < 0:
            energia_importada = abs(diferencia - energia_almacenamiento)
        else:
            energia_importada = 0
            
                    
        precio_importacion = resultado.get('precioImportacionIntervalo', 0) or 0
        precio_exportacion = resultado.get('precioExportacionIntervalo', 0) or 0
        
        coste_importacion = energia_importada * precio_importacion
        ingreso_exportacion = excedente_vertido * precio_exportacion
        
        datos_part['consumoTotal_kWh'] += consumo
        datos_part['energiaAutoconsumidaDirecta_kWh'] += autoconsumo
        datos_part['energiaRecibidaRepartoConsumida_kWh'] += energia_recibida_reparto
        datos_part['energiaAlmacenamiento_kWh'] += energia_almacenamiento
        datos_part['energiaAlmacenamientoDescargada_kWh'] += energia_almacenamiento if energia_almacenamiento < 0 else 0
        datos_part['energiaAlmacenamientoCargada_kWh'] += energia_almacenamiento if energia_almacenamiento > 0 else 0
        datos_part['energiaImportadaRed_kWh'] += energia_importada
        datos_part['energiaExportadaRed_kWh'] += excedente_vertido
        datos_part['costeImportacion_eur'] += coste_importacion
        datos_part['ingresoExportacion_eur'] += ingreso_exportacion
        datos_part['costeBaseEstimado_eur'] += consumo * precio_importacion
        datos_part['numIntervalos'] += 1
        
        datos_mes['consumoTotal_kWh'] += consumo
        datos_mes['energiaAutoconsumidaDirecta_kWh'] += autoconsumo
        datos_mes['energiaRecibidaRepartoConsumida_kWh'] += energia_recibida_reparto
        datos_mes['energiaAlmacenamiento_kWh'] += energia_almacenamiento
        datos_mes['energiaAlmacenamientoDescargada_kWh'] += energia_almacenamiento if energia_almacenamiento < 0 else 0
        datos_mes['energiaAlmacenamientoCargada_kWh'] += energia_almacenamiento if energia_almacenamiento > 0 else 0
        datos_mes['energiaImportadaRed_kWh'] += energia_importada
        datos_mes['energiaExportadaRed_kWh'] += excedente_vertido
        datos_mes['costeImportacion_eur'] += coste_importacion
        datos_mes['ingresoExportacion_eur'] += ingreso_exportacion
        datos_mes['costeBaseEstimado_eur'] += consumo * precio_importacion
        datos_mes['numIntervalos'] += 1
    
    return participantes_dict


def _calcular_costes_economicos_mensuales(datos_agregados, contrato, simulacion, participante_id):
    """
    Calcula los costes económicos procesando cada mes por separado como una factura independiente.
    Los resultados se agregan para devolver totales globales.
    
    Args:
        datos_agregados: Diccionario con datos energéticos agregados (incluye datos_mensuales)
        contrato: Contrato del participante para calcular término de potencia
        simulacion: Entidad de simulación con fechas
        participante_id: ID del participante para logs
        
    Returns:
        dict: Diccionario con costes económicos agregados
        {
            'coste_total_eur': float,      # Suma de todas las facturas mensuales
            'ahorro_total_eur': float,     # Suma de ahorros mensuales
            'ahorro_porcentual_pct': float # Porcentaje sobre el coste base total
        }
    """
    
    if 'datos_mensuales' not in datos_agregados or not datos_agregados['datos_mensuales']:
        return _calcular_costes_economicos_fallback(datos_agregados, contrato, simulacion)
    
    coste_total_acumulado = 0.0
    coste_base_acumulado = 0.0
    facturas_procesadas = 0
    
    for mes_key, datos_mes in datos_agregados['datos_mensuales'].items():
        
        coste_energia_mes = datos_mes['costeImportacion_eur'] - datos_mes['ingresoExportacion_eur']
        coste_energia_mes = max(0.0, coste_energia_mes)
        
        termino_potencia_mes = _calcular_termino_potencia_mes(contrato, mes_key)
        
        factura_mes = calcular_factura_completa_espanola(coste_energia_mes, termino_potencia_mes)
        
        coste_base_energia_mes = datos_mes['costeBaseEstimado_eur']
        factura_base_mes = calcular_factura_completa_espanola(coste_base_energia_mes, termino_potencia_mes)
        
        coste_total_acumulado += factura_mes['coste_total']
        coste_base_acumulado += factura_base_mes['coste_total']
        facturas_procesadas += 1
    
    ahorro_total = coste_base_acumulado - coste_total_acumulado
    ahorro_total = max(0.0, ahorro_total)
    
    ahorro_porcentual = 0.0
    if coste_base_acumulado > 0:
        ahorro_porcentual = (ahorro_total / coste_base_acumulado) * 100
        ahorro_porcentual = max(0.0, min(100.0, ahorro_porcentual))
    
    return {
        'coste_total_eur': coste_total_acumulado,
        'ahorro_total_eur': ahorro_total,
        'ahorro_porcentual_pct': ahorro_porcentual,
        'facturas_procesadas': facturas_procesadas,
        'calculo_mensual': True
    }


def _calcular_termino_potencia_mes(contrato, mes_key):
    """
    Calcula el término de potencia para un mes específico.
    
    Args:
        contrato: Contrato del participante
        mes_key: Clave del mes en formato 'YYYY-MM'
        
    Returns:
        float: Término de potencia del mes en euros
    """
    if not contrato or not hasattr(contrato, 'potenciaContratada_kW'):
        return 0.0
    
    try:
        from datetime import datetime
        año, mes = map(int, mes_key.split('-'))
        
        if mes == 12:
            primer_dia_siguiente = datetime(año + 1, 1, 1)
        else:
            primer_dia_siguiente = datetime(año, mes + 1, 1)
        
        primer_dia_mes = datetime(año, mes, 1)
        dias_mes = (primer_dia_siguiente - primer_dia_mes).days
        
        potencia_contratada = contrato.potenciaContratada_kW or 0.0
        precio_potencia_dia = contrato.precioPotenciaContratado_eur_kWh or 0.0
        
        return potencia_contratada * precio_potencia_dia * dias_mes
        
    except (ValueError, AttributeError):
        return 0.0


def _calcular_costes_economicos_fallback(datos_agregados, contrato, simulacion):
    """
    Método de fallback para cuando no hay datos mensuales disponibles.
    """
    
    coste_energia_bruto = datos_agregados['costeImportacion_eur'] - datos_agregados['ingresoExportacion_eur']
    coste_energia_neto = max(0.0, coste_energia_bruto)
    
    termino_potencia = 0.0
    if contrato and simulacion:
        termino_potencia = calcular_termino_potencia(contrato, simulacion.fechaInicio, simulacion.fechaFin)
    
    factura_real = calcular_factura_completa_espanola(coste_energia_neto, termino_potencia)
    coste_total_real = factura_real['coste_total']
    
    coste_base_energia = datos_agregados['costeBaseEstimado_eur']
    factura_base = calcular_factura_completa_espanola(coste_base_energia, termino_potencia)
    coste_total_base = factura_base['coste_total']
    
    ahorro_absoluto = coste_total_base - coste_total_real
    ahorro_absoluto = max(0.0, ahorro_absoluto)
    
    ahorro_porcentual = 0.0
    if coste_total_base > 0:
        ahorro_porcentual = (ahorro_absoluto / coste_total_base) * 100
        ahorro_porcentual = max(0.0, min(100.0, ahorro_porcentual))
    
    return {
        'coste_total_eur': coste_total_real,
        'ahorro_total_eur': ahorro_absoluto,
        'ahorro_porcentual_pct': ahorro_porcentual,
        'facturas_procesadas': 1,
        'calculo_mensual': False
    }


def _obtener_clave_mes(timestamp):
    """
    Obtiene la clave del mes en formato 'YYYY-MM' a partir de un timestamp.
    
    Args:
        timestamp: Timestamp del intervalo (puede ser string o datetime)
        
    Returns:
        str: Clave del mes en formato 'YYYY-MM'
    """
    try:
        if isinstance(timestamp, str):
            from datetime import datetime
            # Intentar parsear diferentes formatos de fecha
            try:
                dt = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
            except:
                dt = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
        else:
            dt = timestamp
        
        return f"{dt.year:04d}-{dt.month:02d}"
    
    except (ValueError, AttributeError):
        # En caso de error, usar mes por defecto
        return "2024-01"


def _calcular_metricas_energeticas_globales(datos_agregados):
    """
    Calcula las métricas energéticas (SCR, SSR) a nivel global de toda la simulación.
    
    SCR: % de generación renovable utilizada localmente (no exportada)
    SSR: % del consumo cubierto por energía renovable local
    
    Args:
        datos_agregados: Diccionario con datos energéticos agregados globales
        
    Returns:
        dict: Diccionario con métricas energéticas globales
    """
    consumo_total = datos_agregados['consumoTotal_kWh']
    autoconsumo_directo = datos_agregados['energiaAutoconsumidaDirecta_kWh']
    energia_reparto = datos_agregados['energiaRecibidaRepartoConsumida_kWh']
    energia_almacenamiento_descargada = abs(datos_agregados['energiaAlmacenamientoDescargada_kWh'])
    energia_almacenamiento_cargada = datos_agregados.get('energiaAlmacenamientoCargada_kWh', 0) or 0
    energia_almacenamiento_cargada = abs(energia_almacenamiento_cargada)
    
    energia_para_consumo_real = autoconsumo_directo + energia_almacenamiento_descargada
    ssr_pct = (energia_para_consumo_real / consumo_total * 100) if consumo_total > 0 else 0.0
    
    energia_renovable_utilizada = autoconsumo_directo + energia_almacenamiento_cargada
    scr_pct = (energia_renovable_utilizada / energia_reparto * 100) if energia_reparto > 0 else 0.0
    
    print(f"    📊 MÉTRICAS ENERGÉTICAS - DATOS BASE:")
    print(f"    • Consumo total: {consumo_total:.2f} kWh")
    print(f"    • Autoconsumo directo: {autoconsumo_directo:.2f} kWh")  
    print(f"    • Energía de reparto: {energia_reparto:.2f} kWh")
    print(f"    • Energía almacenamiento cargada: {energia_almacenamiento_cargada:.2f} kWh")
    print(f"    • Energía almacenamiento descargada: {energia_almacenamiento_descargada:.2f} kWh")
    
    print(f"    🏠 CÁLCULO SSR (Self Sufficiency Ratio):")
    print(f"    • Propósito: % del consumo cubierto por energía renovable local")
    print(f"    • Fórmula: (Energía que satisface demanda / Consumo total) × 100")
    print(f"    • Energía satisface demanda: {autoconsumo_directo:.2f} + {energia_almacenamiento_descargada:.2f} = {energia_para_consumo_real:.2f} kWh")
    print(f"    • SSR = ({energia_para_consumo_real:.2f} / {consumo_total:.2f}) × 100 = {ssr_pct:.2f}%")
    
    print(f"    📊 CÁLCULO SCR (Self Consumption Ratio):")
    print(f"    • Propósito: % de generación renovable utilizada localmente (no exportada)")
    print(f"    • Fórmula: (Energía utilizada localmente / Energía total generada) × 100")
    
    if energia_renovable_utilizada > energia_reparto + 0.01:  # Tolerancia de 0.01 kWh
        print(f"    ⚠️  ADVERTENCIA: Energía utilizada ({energia_renovable_utilizada:.2f}) > Energía reparto ({energia_reparto:.2f})")
        print(f"    ⚠️  Diferencia: {energia_renovable_utilizada - energia_reparto:.2f} kWh")
        print(f"    ⚠️  Verificar que no se incluyan pérdidas de almacenamiento en energia_gestionada")
    
    print(f"    • Energía utilizada localmente: {autoconsumo_directo:.2f} + {energia_almacenamiento_cargada:.2f} = {energia_renovable_utilizada:.2f} kWh")
    
    
    if energia_para_consumo_real > consumo_total:
        print(f"    ⚠️  ADVERTENCIA: Energía para consumo ({energia_para_consumo_real:.2f}) > Consumo total ({consumo_total:.2f})")
    
    balance_almacenamiento = energia_almacenamiento_cargada + energia_almacenamiento_descargada  # descargada es negativa
    if abs(balance_almacenamiento) > 0.01:  # Tolerancia de 0.01 kWh
        print(f"    ℹ️  Balance almacenamiento neto: {balance_almacenamiento:.2f} kWh (energía restante en baterías)")
    
    print(f"    ✅ MÉTRICAS CALCULADAS: SSR={ssr_pct:.1f}%, SCR={scr_pct:.1f}%")
    
    return {
        'ssr_pct': ssr_pct,
        'scr_pct': scr_pct
    }


def _mostrar_desglose_calculo(participante_id, costes_economicos, datos_agregados):
    """
    Muestra el desglose detallado de los cálculos para debugging.
    
    Args:
        participante_id: ID del participante
        costes_economicos: Diccionario con costes económicos calculados
        datos_agregados: Datos energéticos agregados
    """
    
    print(f"  📊 Desglose cálculo participante {participante_id}:")
    
    if costes_economicos.get('calculo_mensual', False):
        print(f"    • Método: Facturación mensual ({costes_economicos['facturas_procesadas']} meses)")
        print(f"    • Meses procesados: {list(datos_agregados['datos_mensuales'].keys())}")
    else:
        print(f"    • Método: Cálculo agregado (fallback)")
    
    print(f"    • Coste total: {costes_economicos['coste_total_eur']:.2f} €")
    print(f"    • Ahorro total: {costes_economicos['ahorro_total_eur']:.2f} € ({costes_economicos['ahorro_porcentual_pct']:.1f}%)")
    print(f"    • Consumo total: {datos_agregados['consumoTotal_kWh']:.2f} kWh")
    print(f"    • Autoconsumo directo: {datos_agregados['energiaAutoconsumidaDirecta_kWh']:.2f} kWh")
    print(f"    • Energía de reparto: {datos_agregados['energiaRecibidaRepartoConsumida_kWh']:.2f} kWh")


def calcular_resultados_activos_gen(resultados_intervalo_activos, activos_gen):
    """
    Calcula resultados agregados por activo de generación a partir de los datos de intervalo.
    
    Args:
        resultados_intervalo_activos: Lista de resultados por intervalo para cada activo
        activos_gen: Lista de entidades de activos de generación, con información técnica
        
    Returns:
        List[ResultadoSimulacionActivoGeneracionEntity]: Lista de entidades de resultado por activo
    """
    activos_gen_dict = {}
    
    mapa_activos = {activo.idActivoGeneracion: activo for activo in activos_gen}
    
    if resultados_intervalo_activos:
        timestamps = set(resultado.get('timestamp') for resultado in resultados_intervalo_activos)
        horas_simulacion = len(timestamps)
    else:
        horas_simulacion = 0
    
    print(f"  • Duración de la simulación: {horas_simulacion} horas")
    
    for resultado in resultados_intervalo_activos:
        activo_id = resultado.get('idActivoGeneracion')
        if activo_id not in activos_gen_dict:
            activos_gen_dict[activo_id] = {
                'idActivoGeneracion': activo_id,
                'energiaTotalGenerada_kWh': 0.0,
                'horasProduccionEfectiva': 0,
                'potenciaTotal_kW': 0.0,
                'numIntervalos': 0,
                'radiacion_total': 0.0,    
                'intervalos_con_radiacion': 0  
            }
        
        datos_activo = activos_gen_dict[activo_id]
        energia_generada = resultado.get('energiaGenerada_kWh', 0) or 0
        datos_activo['energiaTotalGenerada_kWh'] += energia_generada
        datos_activo['numIntervalos'] += 1
        datos_activo['potenciaTotal_kW'] += energia_generada
        
        if energia_generada > 0:
            datos_activo['horasProduccionEfectiva'] += 1
        
        radiacion = resultado.get('radiacion_kWh_m2', 0) or 0
        if radiacion > 0:
            datos_activo['radiacion_total'] += radiacion
            datos_activo['intervalos_con_radiacion'] += 1
    
    resultados = []
    for activo_id, datos in activos_gen_dict.items():
        activo = mapa_activos.get(activo_id)
        if not activo:
            print(f"  [WARN] No se encontró información del activo ID {activo_id}, usando valores predeterminados")
            continue
            
        potencia_nominal = getattr(activo, 'potenciaNominal_kW', 0) or 0
        eficiencia = getattr(activo, 'eficiencia_pct', 0) or 0
        
        energia_total = datos['energiaTotalGenerada_kWh']
        
        factor_capacidad = 0
        if potencia_nominal > 0 and horas_simulacion > 0:
            energia_maxima_teorica = potencia_nominal * horas_simulacion
            factor_capacidad = (energia_total / energia_maxima_teorica) * 100
        
        performance_ratio = 0
        if datos['radiacion_total'] > 0 and eficiencia > 0:
            area_efectiva = getattr(activo, 'areaEfectiva_m2', 0) or 0
            if area_efectiva > 0:
                energia_teorica = datos['radiacion_total'] * area_efectiva * (eficiencia / 100)
                if energia_teorica > 0:
                    performance_ratio = (energia_total / energia_teorica) * 100
        
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
    activos_alm_dict = {}
    
    mapa_activos = {activo.idActivoAlmacenamiento: activo for activo in activos_alm}
    
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
                'soc_valores': [],  
                'soc_max_kWh': 0.0,
                'soc_min_kWh': float('inf'),
                'numIntervalos': 0
            }
        
        datos_activo = activos_alm_dict[activo_id]
        energia_cargada = resultado.get('energiaCargada_kWh', 0) or 0
        energia_descargada = resultado.get('energiaDescargada_kWh', 0) or 0
        soc_actual = resultado.get('SoC_kWh', 0) or 0
        
        datos_activo['energiaTotalCargada_kWh'] += energia_cargada
        datos_activo['energiaTotalDescargada_kWh'] += energia_descargada
        datos_activo['soc_suma_kWh'] += soc_actual
        datos_activo['soc_valores'].append(soc_actual)
        datos_activo['numIntervalos'] += 1
        
        if soc_actual > datos_activo['soc_max_kWh']:
            datos_activo['soc_max_kWh'] = soc_actual
        if soc_actual < datos_activo['soc_min_kWh']:
            datos_activo['soc_min_kWh'] = soc_actual
        
        if energia_cargada > 0:
            datos_activo['horasCarga'] += 1
        elif energia_descargada > 0:
            datos_activo['horasDescarga'] += 1
        else:
            datos_activo['horasInactivo'] += 1
    
    resultados = []
    for activo_id, datos in activos_alm_dict.items():
        activo = mapa_activos.get(activo_id)
        if not activo:
            print(f"  [WARN] No se encontró información del activo de almacenamiento ID {activo_id}, usando valores predeterminados")
            continue
            
        capacidad_nominal = activo.capacidadNominal_kWh or 1.0
        
        energia_cargada = datos['energiaTotalCargada_kWh']
        energia_descargada = datos['energiaTotalDescargada_kWh']
        
        ciclos_equivalentes = energia_descargada / capacidad_nominal
        
        perdidas_eficiencia = energia_cargada - energia_descargada
        
        soc_medio_kwh = datos['soc_suma_kWh'] / datos['numIntervalos'] if datos['numIntervalos'] > 0 else 0
        soc_medio_pct = (soc_medio_kwh / capacidad_nominal) * 100
        
        soc_min = datos['soc_min_kWh'] if datos['soc_min_kWh'] != float('inf') else 0
        soc_min_pct = (soc_min / capacidad_nominal) * 100
        
        soc_max = datos['soc_max_kWh']
        soc_max_pct = (soc_max / capacidad_nominal) * 100
        
        degradacion_por_ciclo = 0.004
        degradacion_estimada = ciclos_equivalentes * degradacion_por_ciclo
        
        if len(datos['soc_valores']) > 1:
            dod_valores = []
            for i in range(1, len(datos['soc_valores'])):
                dif = datos['soc_valores'][i-1] - datos['soc_valores'][i]
                if dif > 0:
                    dod_valores.append(dif / capacidad_nominal * 100)
            
            dod_medio = sum(dod_valores) / len(dod_valores) if dod_valores else 0
            
            factor_dod = 1.0 + (dod_medio / 100)
            degradacion_estimada *= factor_dod
        
        degradacion_estimada = min(100, max(0, degradacion_estimada))
        
        throughput_total = energia_cargada + energia_descargada
        
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


def calcular_resultados_globales(simulacion, resultados_participantes,
                               resultados_intervalo_activos_generacion, 
                               resultados_intervalo_activos_almacenamiento,
                               resultados_intervalo_participantes=None,
                               activos_gen=None, activos_alm=None):
    total_consumo = 0.0
    total_autoconsumo = 0.0
    total_energia_reparto = 0.0
    total_energia_almacenamiento_descargada = 0.0
    coste_total_energia = 0.0
    ahorro_total = 0.0
    total_ingreso_exportacion = 0.0
    
    for resultado_participante in resultados_participantes:
        total_consumo += resultado_participante.consumo_kWh
        total_autoconsumo += resultado_participante.energiaAutoconsumidaDirecta_kWh
        total_energia_reparto += resultado_participante.energiaRecibidaRepartoConsumida_kWh
        coste_total_energia += resultado_participante.costeNetoParticipante_eur
        ahorro_total += resultado_participante.ahorroParticipante_eur
    
    total_energia_almacenamiento_cargada = 0.0
    if resultados_intervalo_participantes:
        for resultado in resultados_intervalo_participantes:
            energia_almacenamiento = resultado.get('energiaAlmacenamiento_kWh', 0) or 0
            if energia_almacenamiento < 0:
                total_energia_almacenamiento_descargada += energia_almacenamiento
            elif energia_almacenamiento > 0:
                total_energia_almacenamiento_cargada += energia_almacenamiento
        
        print(f"    • [DEBUG] Almacenamiento calculado desde {len(resultados_intervalo_participantes)} intervalos:")
        print(f"      - Cargado: {total_energia_almacenamiento_cargada:.2f} kWh")
        print(f"      - Descargado: {total_energia_almacenamiento_descargada:.2f} kWh")
    
    total_generacion = 0.0
    total_importacion = 0.0
    total_exportacion = 0.0
    
    for resultado in resultados_intervalo_activos_generacion:
        total_generacion += resultado.get('energiaGenerada_kWh', 0) or 0
    
    # Calcular totales desde los datos agregados de participantes (no desde intervalos)
    participantes_dict = _agregar_datos_energeticos_participantes(resultados_intervalo_participantes) if resultados_intervalo_participantes else {}
    for participante_id, datos_agregados in participantes_dict.items():
        total_importacion += datos_agregados['energiaImportadaRed_kWh']
        total_exportacion += datos_agregados['energiaExportadaRed_kWh']
        total_ingreso_exportacion += datos_agregados['ingresoExportacion_eur']
    
    datos_agregados = {
        'consumoTotal_kWh': total_consumo,
        'energiaAutoconsumidaDirecta_kWh': total_autoconsumo,
        'energiaRecibidaRepartoConsumida_kWh': total_energia_reparto,
        'energiaAlmacenamientoDescargada_kWh': total_energia_almacenamiento_descargada,
        'energiaAlmacenamientoCargada_kWh': total_energia_almacenamiento_cargada
    }
    
    metricas_globales = _calcular_metricas_energeticas_globales(datos_agregados)
    tasa_autoconsumo = metricas_globales['scr_pct']
    tasa_autosuficiencia = metricas_globales['ssr_pct']
    
    inversion_inicial_total = 0.0
    if activos_gen:
        for activo in activos_gen:
            inversion_inicial_total += getattr(activo, 'costeInstalacion_eur', 0) or 0
    
    if activos_alm:
        for activo in activos_alm:
            inversion_inicial_total += getattr(activo, 'costeInstalacion_eur', 0) or 0
    
    periodo_simulacion_dias = (simulacion.fechaFin - simulacion.fechaInicio).days + 1
    
    payback_period = None
    roi = None
    
    if periodo_simulacion_dias > 0 and ahorro_total > 0:
        factor_anual = 365.0 / periodo_simulacion_dias
        ahorro_anual_estimado = ahorro_total * factor_anual
        
        if ahorro_anual_estimado > 0:
            payback_period = inversion_inicial_total / ahorro_anual_estimado
        
        if inversion_inicial_total > 0:
            roi = (ahorro_anual_estimado / inversion_inicial_total) * 100
    
    factor_emision_co2 = 0.25
    
    energia_renovable_consumida_localmente = total_autoconsumo + total_energia_reparto
    energia_renovable_desde_almacenamiento = abs(total_energia_almacenamiento_descargada)
    energia_renovable_exportada = total_exportacion
    
    energia_total_evita_red = (
        energia_renovable_consumida_localmente +
        energia_renovable_desde_almacenamiento +
        energia_renovable_exportada
    )
    
    reduccion_co2 = energia_total_evita_red * factor_emision_co2
    
    print(f"    • [CO2] Energía renovable consumida localmente: {energia_renovable_consumida_localmente:.2f} kWh")
    print(f"    • [CO2] Energía renovable desde almacenamiento: {energia_renovable_desde_almacenamiento:.2f} kWh")
    print(f"    • [CO2] Energía renovable exportada: {energia_renovable_exportada:.2f} kWh")
    print(f"    • [CO2] Total energía que evita red eléctrica: {energia_total_evita_red:.2f} kWh")
    print(f"    • [CO2] Factor emisión (mix eléctrico): {factor_emision_co2} kgCO2eq/kWh")
    print(f"    • [CO2] Reducción emisiones calculada: {reduccion_co2:.2f} kgCO2eq")
    
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
    
    print(f"  ✓ Resultados globales calculados (agregando {len(resultados_participantes)} participantes)")
    print(f"    • Consumo total: {total_consumo:.2f} kWh")
    print(f"    • Generación total: {total_generacion:.2f} kWh")
    print(f"    • Autoconsumo directo: {total_autoconsumo:.2f} kWh")
    print(f"    • Energía de reparto: {total_energia_reparto:.2f} kWh")
    print(f"    • Almacenamiento cargado: {total_energia_almacenamiento_cargada:.2f} kWh")
    print(f"    • Almacenamiento descargado: {total_energia_almacenamiento_descargada:.2f} kWh")
    print(f"    • Tasa autoconsumo (SCR): {tasa_autoconsumo:.1f}%")
    print(f"    • Tasa autosuficiencia (SSR): {tasa_autosuficiencia:.1f}%")
    print(f"    • Coste total energía: {coste_total_energia:.2f} €")
    print(f"    • Ahorro total: {ahorro_total:.2f} €")
    print(f"    • Ingreso total exportación: {total_ingreso_exportacion:.2f} €")
    print(f"    • Inversión inicial: {inversion_inicial_total:.2f} €")
    if payback_period:
        print(f"    • Periodo de retorno: {payback_period:.1f} años")
    if roi:
        print(f"    • ROI anual: {roi:.1f}%")
    
    return resultado_global


def calcular_todos_resultados(simulacion: SimulacionEntity, 
                               resultados_intervalo_participantes: List[Dict[str, Any]],
                               resultados_intervalo_activos_generacion: List[Dict[str, Any]],
                               resultados_intervalo_activos_almacenamiento: List[Dict[str, Any]],
                               activos_gen: List[ActivoGeneracionEntity], 
                               activos_alm: List[ActivoAlmacenamientoEntity],
                               contratos: Dict[int, Any] = None) -> Dict[str, Any]:
    resultados_participantes = calcular_resultados_participantes(resultados_intervalo_participantes, contratos, simulacion)
    
    resultados_activos_gen = calcular_resultados_activos_gen(resultados_intervalo_activos_generacion, activos_gen)
    
    resultados_activos_alm = calcular_resultados_activos_alm(resultados_intervalo_activos_almacenamiento, activos_alm)
    
    resultado_global = calcular_resultados_globales(simulacion, 
                                                    resultados_participantes,
                                                    resultados_intervalo_activos_generacion,
                                                    resultados_intervalo_activos_almacenamiento,
                                                    resultados_intervalo_participantes,
                                                    activos_gen, activos_alm)
    
    return resultado_global, resultados_participantes, resultados_activos_gen, resultados_activos_alm