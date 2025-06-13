from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes
from app.domain.entities.tipo_reparto import TipoReparto
from app.domain.use_cases.simulacion.motor_simulacion.obtener_precio_energia import obtener_precio_energia

def aplicar_estrategia_intervalo(simulacion, comunidad, participantes, gen_activos,
                                      consumo_int, contratos, coefs, intervalo, estado_alm, activos_alm, pvpc_repo=None):
        
        try:
            # Valores por defecto para prevenir errores
            intervalo_participantes = []
            intervalo_activos_almacenamiento = []
            
            # Calcular valores agregados
            generacion_total = sum(gen_activos.values())
            
            # 1. Determinar tipo de estrategia de excedentes de la simulación
            estrategia = simulacion.tipoEstrategiaExcedentes
            
            # 2. Determinar reparto de generación entre participantes según coeficientes
            energia_asignada = {}  # {id_participante: energía_asignada_kWh}
            
            # Determinar tipo de reparto y asignar energía según coeficientes
            if generacion_total > 0:
                # Reparto por coeficientes según tipo configurado en la comunidad
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    coeficiente = _obtener_coeficiente_reparto(coefs.get(id_p, []), intervalo)
                    
                    # Asignar energía según coeficiente (nunca más que su consumo en caso de sin excedentes)
                    energia_asignada[id_p] = generacion_total * (coeficiente / 100)
                    
            
            # Procesar según tipo de estrategia
            if estrategia == TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES or estrategia == TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
                # Código 31: Individual sin excedentes
                # Código 32: Colectivo sin excedentes
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    autoconsumo = min(consumo, energia_asignada.get(id_p, 0))
                    energia_diferencia = energia_asignada.get(id_p, 0) - consumo

                    # Gestionar almacenamiento individual (si corresponde)
                    # Para este ejemplo, inicializar ciclos acumulados si no existen
                    ciclos_acumulados = {}
                    for activo in activos_alm:
                        if 'ciclos_acumulados' not in estado_alm[activo.idActivoAlmacenamiento]:
                            estado_alm[activo.idActivoAlmacenamiento]['ciclos_acumulados'] = 0.0
                        ciclos_acumulados[activo.idActivoAlmacenamiento] = estado_alm[activo.idActivoAlmacenamiento]['ciclos_acumulados']
                    
                    energia_gestionada, estado_alm, resultados_alm = _gestionar_almacenamiento(
                        comunidad, energia_diferencia, estado_alm, intervalo, activos_alm, ciclos_acumulados
                    )
                    
                    intervalo_activos_almacenamiento.extend(resultados_alm)
                    
                    contrato_p = contratos.get(id_p)
                    
                    # Obtener precio dinámico según tipo de contrato (solo importación para sin excedentes)
                    precio_importacion = obtener_precio_energia(contrato_p, intervalo, pvpc_repo, tipo_precio="importacion")
                    
                    intervalo_participantes.append(
                        {
                            'idParticipante': id_p,
                            'timestamp': intervalo,
                            'consumoReal_kWh': consumo,
                            'autoconsumo_kWh': autoconsumo,
                            'energiaAlmacenamiento_kWh': energia_gestionada,
                            'energiaRecibidaReparto_kWh': energia_asignada.get(id_p, 0),
                            'energiaDiferencia_kWh': energia_diferencia,
                            'excedenteVertidoCompensado_kWh': 0,  # Sin excedentes
                            'precioImportacionIntervalo': precio_importacion,
                            'precioExportacionIntervalo': 0,
                        }
                    )
                    
            elif estrategia == TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION or estrategia == TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
                # Código 41: Individual con excedentes y compensación
                # Código 43: Colectivo con excedentes y compensación en red externa
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    energia_asignada_p = energia_asignada.get(id_p, 0)
                    
                    # El autoconsumo es el mínimo entre lo que consume y lo que le corresponde de la generación
                    autoconsumo = min(consumo, energia_asignada_p)
                    
                    # La diferencia puede ser positiva (excedente) o negativa (déficit)
                    energia_diferencia = energia_asignada_p - consumo
                    
                    # Gestionar almacenamiento, si hay excedentes intentará cargar baterías
                    # Si hay déficit intentará descargar las baterías para cubrir parte del consumo
                    # Para este ejemplo, inicializar ciclos acumulados si no existen
                    ciclos_acumulados = {}
                    for activo in activos_alm:
                        if 'ciclos_acumulados' not in estado_alm[activo.idActivoAlmacenamiento]:
                            estado_alm[activo.idActivoAlmacenamiento]['ciclos_acumulados'] = 0.0
                        ciclos_acumulados[activo.idActivoAlmacenamiento] = estado_alm[activo.idActivoAlmacenamiento]['ciclos_acumulados']
                    
                    energia_gestionada, estado_alm, resultados_alm = _gestionar_almacenamiento(
                        comunidad, energia_diferencia, estado_alm, intervalo, activos_alm, ciclos_acumulados
                    )
                    
                    intervalo_activos_almacenamiento.extend(resultados_alm)
                    
                    # Determinar excedentes después de la gestión de almacenamiento
                    # Solo hay excedente si después de almacenar sigue sobrando energía
                    excedente_compensacion = 0
                    if energia_diferencia > 0 and energia_gestionada < energia_diferencia:
                        # El excedente es lo que queda después de usar almacenamiento
                        excedente_compensacion = energia_diferencia - energia_gestionada
                    
                    contrato_p = contratos.get(id_p)
                    
                    # Obtener precios dinámicos según tipo de contrato
                    precio_importacion = obtener_precio_energia(contrato_p, intervalo, pvpc_repo, tipo_precio="importacion")
                    precio_exportacion = obtener_precio_energia(contrato_p, intervalo, pvpc_repo, tipo_precio="exportacion")
                    
                    intervalo_participantes.append(
                        {
                            'idParticipante': id_p,
                            'timestamp': intervalo,
                            'consumoReal_kWh': consumo,
                            'autoconsumo_kWh': autoconsumo,
                            'energiaAlmacenamiento_kWh': energia_gestionada,
                            'energiaRecibidaReparto_kWh': energia_asignada_p,
                            'energiaDiferencia_kWh': energia_diferencia,
                            'excedenteVertidoCompensado_kWh': excedente_compensacion,
                            'precioImportacionIntervalo': precio_importacion,
                            'precioExportacionIntervalo': precio_exportacion,
                        }
                    )
            
                    
                    
            
                    
            return intervalo_participantes, intervalo_activos_almacenamiento, estado_alm
        except Exception as e:
            # Devolver estructuras vacías pero válidas para evitar errores de desempaquetado
            return [], [], []
        
        
        
        
def _obtener_coeficiente_reparto(coeficientes, timestamp):
    
    if not coeficientes:
        return None
        
    
    # Buscar el coeficiente adecuado según tipo
    for coef in coeficientes:
        # Para reparto fijo, siempre se usa el mismo valor
        if coef.tipoReparto == TipoReparto.REPARTO_FIJO.value:
            # El valor está guardado en el diccionario parametros con la clave 'valor'
            return coef.parametros.get('valor', 0.0)
        
        elif coef.tipoReparto == TipoReparto.REPARTO_PROGRAMADO.value:
            # Obtener hora actual del timestamp (formato 'HH:00')
            hora_actual = f"{timestamp.hour:02d}:00"
            
            # Buscar el valor correspondiente a esta franja horaria
            if coef.parametros and 'parametros' in coef.parametros:
                franjas = coef.parametros['parametros']
                
                for franja in franjas:
                    if franja.get('franja') == hora_actual:
                        return franja.get('valor', 0.0)
                
                # Si no se encuentra la hora exacta, usar valor por defecto
                return coef.parametros.get('valor_default', 0.0)
            
            return coef.parametros.get('valor_default', 0.0)
    
    return None


def _calcular_degradacion_bateria(activo, ciclos_acumulados, tiempo_transcurrido_anos=0):
    
    # Degradación por ciclos (simplificado)
    degradacion_por_ciclo = 0.004  # 0.4% por ciclo completo
    degradacion_ciclos = ciclos_acumulados * degradacion_por_ciclo
    
    # Degradación calendario (opcional, simplificado)
    degradacion_calendario = tiempo_transcurrido_anos * 0.02  # 2% por año
    
    # Degradación total (combinada)
    degradacion_total = min(0.8, degradacion_ciclos + degradacion_calendario)  # Máximo 80%
    
    # Factores de reducción
    factor_capacidad = 1.0 - degradacion_total
    factor_eficiencia = 1.0 - (degradacion_total * 0.5)  # Eficiencia se degrada más lentamente
    
    return {
        'factor_capacidad': factor_capacidad,
        'factor_eficiencia': factor_eficiencia,
        'degradacion_pct': degradacion_total * 100
    }


def _gestionar_almacenamiento(comunidad, excedentes_o_deficit, estado_alm, intervalo, activos_alm, ciclos_acumulados=None):
    
    energia_gestionada = 0.0
    intervalo_activos_alm = []

    # Si no hay activos de almacenamiento, retornar inmediatamente
    if not activos_alm:
        return 0.0, estado_alm, []

    # Modo CARGA (excedentes > 0)
    if excedentes_o_deficit > 0:
        energia_restante = excedentes_o_deficit

        # Priorizar baterías con menor SoC relativo
        activos_ordenados = sorted(
            activos_alm,
            key=lambda a: estado_alm[a.idActivoAlmacenamiento]['soc_kwh'] / a.capacidadNominal_kWh
        )

        for activo in activos_ordenados:
            id_alm = activo.idActivoAlmacenamiento
            capacidad_nominal = activo.capacidadNominal_kWh
            soc_actual = estado_alm[id_alm]['soc_kwh']
            
            # APLICAR DEGRADACIÓN
            ciclos = ciclos_acumulados.get(id_alm, 0) if ciclos_acumulados else 0
            degradacion = _calcular_degradacion_bateria(activo, ciclos)
            capacidad = capacidad_nominal * degradacion['factor_capacidad']  # Capacidad degradada
            
            # 2. Calcular eficiencia de ciclo completo y derivar eficiencias de carga/descarga (CON DEGRADACIÓN)
            if activo.eficienciaCicloCompleto_pct <= 1.0:
                eta_total_nominal = activo.eficienciaCicloCompleto_pct  # Ya es decimal
            else:
                eta_total_nominal = activo.eficienciaCicloCompleto_pct / 100  # Convertir de porcentaje
            
                        # Aplicar degradación a la eficiencia
            eta_total = eta_total_nominal * degradacion['factor_eficiencia']
            eta_carga = eta_descarga = eta_total ** 0.5

            # 3.1. Calcular suelo (soc_min) y techo (soc_max) de SoC (CON CAPACIDAD DEGRADADA)
            if activo.profundidadDescargaMax_pct <= 1.0:
                profundidad_descarga = activo.profundidadDescargaMax_pct  # Ya es decimal
            else:
                profundidad_descarga = activo.profundidadDescargaMax_pct / 100  # Convertir de porcentaje
            soc_min = (1 - profundidad_descarga) * capacidad  # Usa capacidad degradada
            soc_max = capacidad  # Usa capacidad degradada

            # 3.2. Cuánto puedo meter hasta el techo
            capacidad_disponible = soc_max - soc_actual
            
            if capacidad_disponible <= 0 or energia_restante <= 0:
                # Añadir registro aunque no haya carga
                intervalo_activos_alm.append(
                    {
                        'timestamp': intervalo,
                        'energiaCargada_kWh': 0.0,
                        'energiaDescargada_kWh': 0.0,
                        'SoC_kWh': soc_actual,
                        'idActivoAlmacenamiento': id_alm,
                    }
                )
                continue

            # 3.3. Límite por potencia en 1 h
            energia_max_interval = activo.potenciaMaximaCarga_kW * 1  # kWh

            # 3.4. Energía a cargar (antes de pérdidas)
            energia_a_cargar = min(energia_restante, capacidad_disponible, energia_max_interval)
            
            # 3.5. Ajustar input según eficiencia de carga
            energia_input = energia_a_cargar / eta_carga
            
            # Calcular pérdidas por eficiencia
            perdidas_carga = energia_input - energia_a_cargar
            
            # 3.6. Actualizar SoC y contadores
            soc_anterior = estado_alm[id_alm]['soc_kwh']
            estado_alm[id_alm]['soc_kwh'] += energia_a_cargar
            energia_restante -= energia_input
            energia_gestionada += energia_a_cargar  # Solo energía neta almacenada

            intervalo_activos_alm.append(
                {
                    'timestamp': intervalo,
                    'energiaCargada_kWh': energia_a_cargar,
                    'energiaDescargada_kWh': 0.0,
                    'SoC_kWh': estado_alm[id_alm]['soc_kwh'],
                    'idActivoAlmacenamiento': id_alm,
                }
            )

    # 4. Modo DESCARGA (déficit < 0)
    elif excedentes_o_deficit < 0:
        deficit = -excedentes_o_deficit
        energia_descargada_total = 0.0

        # Priorizar baterías con mayor SoC relativo
        activos_ordenados = sorted(
            activos_alm,
            key=lambda a: estado_alm[a.idActivoAlmacenamiento]['soc_kwh'] / a.capacidadNominal_kWh,
            reverse=True
        )

        for activo in activos_ordenados:
            id_alm = activo.idActivoAlmacenamiento
            capacidad_nominal = activo.capacidadNominal_kWh
            soc_actual = estado_alm[id_alm]['soc_kwh']
            
            # APLICAR DEGRADACIÓN
            ciclos = ciclos_acumulados.get(id_alm, 0) if ciclos_acumulados else 0
            degradacion = _calcular_degradacion_bateria(activo, ciclos)
            capacidad = capacidad_nominal * degradacion['factor_capacidad']  # Capacidad degradada
            
            # Calcular eficiencia de ciclo completo y derivar eficiencias de carga/descarga (CON DEGRADACIÓN)
            if activo.eficienciaCicloCompleto_pct <= 1.0:
                eta_total_nominal = activo.eficienciaCicloCompleto_pct  # Ya es decimal
            else:
                eta_total_nominal = activo.eficienciaCicloCompleto_pct / 100  # Convertir de porcentaje
            
                        # Aplicar degradación a la eficiencia
            eta_total = eta_total_nominal * degradacion['factor_eficiencia']
            eta_carga = eta_descarga = eta_total ** 0.5

            # 4.1. Calcular suelo de SoC (CON CAPACIDAD DEGRADADA)
            if activo.profundidadDescargaMax_pct <= 1.0:
                profundidad_descarga = activo.profundidadDescargaMax_pct  # Ya es decimal
            else:
                profundidad_descarga = activo.profundidadDescargaMax_pct / 100  # Convertir de porcentaje
            soc_min = (1 - profundidad_descarga) * capacidad  # Usa capacidad degradada
            
            if soc_actual <= soc_min or deficit <= 0:
                # Añadir registro aunque no haya descarga
                intervalo_activos_alm.append(
                    {
                        'timestamp': intervalo,
                        'energiaCargada_kWh': 0.0,
                        'energiaDescargada_kWh': 0.0,
                        'SoC_kWh': soc_actual,
                        'idActivoAlmacenamiento': id_alm,
                    }
                )
                continue

            # 4.2. Cuánta energía neta puedo extraer sin bajar de soc_min
            energia_disponible = soc_actual - soc_min
            
            # 4.3. Límite por potencia en 1 h
            energia_max_descarga = activo.potenciaMaximaDescarga_kW * 1  # kWh
            
            # 4.4. Energía bruta a descargar (antes de pérdidas)
            deficit_ajustado = deficit / eta_descarga
            energia_a_descargar = min(deficit_ajustado, energia_disponible, energia_max_descarga)
            
            # 4.5. Energía neta que sale tras eficiencia
            energia_output = energia_a_descargar * eta_descarga
            
            # Calcular pérdidas por eficiencia
            perdidas_descarga = energia_a_descargar - energia_output
            
            # 4.6. Actualizar SoC y contadores
            soc_anterior = estado_alm[id_alm]['soc_kwh']
            estado_alm[id_alm]['soc_kwh'] -= energia_a_descargar
            deficit -= energia_output
            energia_descargada_total += energia_output

            intervalo_activos_alm.append(
                {
                    'timestamp': intervalo,
                    'energiaCargada_kWh': 0.0,
                    'energiaDescargada_kWh': energia_output,
                    'SoC_kWh': estado_alm[id_alm]['soc_kwh'],
                    'idActivoAlmacenamiento': id_alm,
                }
            )

        # La energía gestionada será negativa (salida a la comunidad)
        energia_gestionada = -energia_descargada_total

    # 5. Sin carga ni descarga (excedentes_o_deficit = 0) o no se procesaron todos los activos
    else:
        # Crear registros para todos los activos cuando no hay excedentes ni déficit
        for activo in activos_alm:
            id_alm = activo.idActivoAlmacenamiento
            soc_actual = estado_alm[id_alm]['soc_kwh']
            capacidad = activo.capacidadNominal_kWh
            intervalo_activos_alm.append(
                {
                    'timestamp': intervalo,
                    'energiaCargada_kWh': 0.0,
                    'energiaDescargada_kWh': 0.0,
                    'SoC_kWh': estado_alm[id_alm]['soc_kwh'],
                    'idActivoAlmacenamiento': id_alm,
                }
            )

    return energia_gestionada, estado_alm, intervalo_activos_alm