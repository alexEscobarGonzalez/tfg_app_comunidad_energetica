from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes
from app.domain.entities.tipo_reparto import TipoReparto

def aplicar_estrategia_intervalo(comunidad, participantes, gen_activos,
                                      consumo_int, contratos, coefs, intervalo, estado_alm, activos_alm):
        """
        Aplica la estrategia de reparto de energía según la configuración de la comunidad.
        
        Args:
            comunidad: Entidad de la comunidad energética
            participantes: Lista de participantes
            gen_activos: Diccionario de generación de activos {id_activo: generación_kWh}
            consumo_int: Diccionario de consumo {id_participante: consumo_kWh}
            contratos: Diccionario de contratos por participante
            coefs: Diccionario de coeficientes de reparto por participante
            intervalo: Timestamp del intervalo actual
            
        Returns:
            Tupla con (resultados del intervalo, estado actualizado de almacenamiento)
        """
        
        
        try:
            print(f"\n[DEBUG] Intervalo: {intervalo}")
            print(f"[DEBUG] Comunidad: {comunidad.nombre}")
            print(f"[DEBUG] Participantes: {len(participantes)}")
            print(f"[DEBUG] Activos generación: {len(gen_activos)} - Generación total: {sum(gen_activos.values()):.4f} kWh")
            print(f"[DEBUG] Consumos: {consumo_int}")
            
            
            # Valores por defecto para prevenir errores
            intervalo_participantes = []
            intervalo_activos_almacenamiento = []

            
            # Calcular valores agregados
            generacion_total = sum(gen_activos.values())
            consumo_total = sum(consumo_int.get(p.idParticipante, 0) for p in participantes)
            
            print(f"[DEBUG] Generación total: {generacion_total:.4f} kWh, Consumo total: {consumo_total:.4f} kWh")
            print(f"[DEBUG] Balance energético: {generacion_total - consumo_total:.4f} kWh")
            
            # 1. Determinar tipo de estrategia de excedentes de la comunidad
            estrategia = comunidad.tipoEstrategiaExcedentes
            
            # 2. Determinar reparto de generación entre participantes según coeficientes
            energia_asignada = {}  # {id_participante: energía_asignada_kWh}
            
            # Determinar tipo de reparto y asignar energía según coeficientes
            if generacion_total > 0:
                # Reparto por coeficientes según tipo configurado en la comunidad
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    coeficiente = _obtener_coeficiente_reparto(coefs.get(id_p, []), intervalo)
                    print(f"[DEBUG] Participante {id_p}: Coeficiente de reparto: {coeficiente}")
                    
                    
                    # Asignar energía según coeficiente (nunca más que su consumo en caso de sin excedentes)
                    energia_asignada[id_p] = generacion_total * coeficiente
                    print(f"[DEBUG] Participante {id_p}: Consumo={consumo:.4f} kWh, Coef={coeficiente:.4f}, Asignado={energia_asignada[id_p]:.4f} kWh")
                    
            
            print(f"[DEBUG] Aplicando estrategia: {estrategia.value}")
            
            
            # Procesar según tipo de estrategia
            if estrategia == TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES or estrategia == TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
                print("[DEBUG] Procesando estrategia: INDIVIDUAL_SIN_EXCEDENTES")
                # Código 31: Individual sin excedentes
                # Código 32: Colectivo sin excedentes
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    autoconsumo = min(consumo, energia_asignada.get(id_p, 0))
                    energia_diferencia = energia_asignada.get(id_p, 0) - consumo

                    # Gestionar almacenamiento individual (si corresponde)
                    energia_gestionada, estado_alm, resultados_alm = _gestionar_almacenamiento(
                        comunidad, energia_diferencia, estado_alm, intervalo, activos_alm
                    )
                    
                    intervalo_activos_almacenamiento.extend(resultados_alm)
                    
                    # Utilizar energía generada por activos de almacenamiento en caso de ser necesario
                    if energia_gestionada < 0:
                        autoconsumo += -energia_gestionada
                    
                    
                    contrato_p = contratos.get(id_p)
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
                            'precioImportacionIntervalo': contrato_p.precioEnergiaImportacion_eur_kWh,
                            'precioExportacionIntervalo': 0,
                        }
                    )
                    
            elif estrategia == TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION or estrategia == TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
                print("[DEBUG] Procesando estrategia: INDIVIDUAL_EXCEDENTES_COMPENSACION o COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA")
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
                    energia_gestionada, estado_alm, resultados_alm = _gestionar_almacenamiento(
                        comunidad, energia_diferencia, estado_alm, intervalo, activos_alm
                    )
                    
                    intervalo_activos_almacenamiento.extend(resultados_alm)
                    
                    # Si la gestión de almacenamiento ha descargado energía (negativo), 
                    # incrementa el autoconsumo con esa energía
                    if energia_gestionada < 0:
                        autoconsumo += -energia_gestionada
                    
                    # Determinar excedentes después de la gestión de almacenamiento
                    # Solo hay excedente si después de almacenar sigue sobrando energía
                    excedente_compensacion = 0
                    if energia_diferencia > 0 and energia_gestionada < energia_diferencia:
                        # El excedente es lo que queda después de usar almacenamiento
                        excedente_compensacion = energia_diferencia - energia_gestionada
                        print(f"[DEBUG] Participante {id_p}: Excedente para compensación: {excedente_compensacion:.4f} kWh")
                    
                    contrato_p = contratos.get(id_p)
                    precio_exportacion = contrato_p.precioEnergiaImportacion_eur_kWh 
                    
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
                            'precioImportacionIntervalo': contrato_p.precioEnergiaImportacion_eur_kWh,
                            'precioExportacionIntervalo': precio_exportacion,
                        }
                    )
            
                    
                    
            
                    
            return intervalo_participantes, intervalo_activos_almacenamiento, estado_alm
        except Exception as e:
            # Devolver estructuras vacías pero válidas para evitar errores de desempaquetado
            return [], [], []
        
        
        
        
def _obtener_coeficiente_reparto(coeficientes, timestamp):
    """
    Obtiene el coeficiente de reparto adecuado según el timestamp y tipo
    
    Args:
        coeficientes: Lista de coeficientes de reparto para un participante
        timestamp: Momento actual para el que se requiere el coeficiente
        
    Returns:
        float: Valor del coeficiente o None si no se encuentra
    """
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
    
    print(f"[DEBUG] No se encontró coeficiente de reparto para timestamp {timestamp}")      
    return None


def _gestionar_almacenamiento(comunidad, excedentes_o_deficit, estado_alm, intervalo, activos_alm):
    """
    Gestiona la carga o descarga de los sistemas de almacenamiento según la energía disponible o requerida.

    Args:
        comunidad: Entidad de la comunidad energética
        excedentes_o_deficit: Energía disponible (positivo) o déficit (negativo) en kWh
        estado_alm: Dict con el estado actual de SoC de cada activo de almacenamiento {id: {'soc_kwh': ...}}
        intervalo: Timestamp del inicio del intervalo (1 hora de duración)
        activos_alm: Lista de activos de almacenamiento disponibles

    Returns:
        tuple: (
            energia_gestionada: kWh intercambiados con la red (+ carga, - descarga),
            estado_alm_actualizado: estado_alm modificado con los nuevos SoC,
            resultados_activos_alm: lista de DatosIntervaloActivoEntity con detalle por activo
        )
    """
    energia_gestionada = 0.0
    intervalo_activos_alm = []

    print(f"[DEBUG] Gestionando almacenamiento: Energía={excedentes_o_deficit:.4f} kWh")

    # Si no hay activos de almacenamiento, retornar inmediatamente
    if not activos_alm:
        return 0.0, estado_alm, []

    

    # 3. Modo CARGA (excedentes > 0)
    if excedentes_o_deficit > 0:
        energia_restante = excedentes_o_deficit

        # Priorizar baterías con menor SoC relativo
        activos_ordenados = sorted(
            activos_alm,
            key=lambda a: estado_alm[a.idActivoAlmacenamiento]['soc_kwh'] / a.capacidadNominal_kWh
        )

        for activo in activos_ordenados:
            id_alm = activo.idActivoAlmacenamiento
            capacidad = activo.capacidadNominal_kWh
            soc_actual = estado_alm[id_alm]['soc_kwh']
            # 2. Calcular eficiencia de ciclo completo y derivar eficiencias de carga/descarga
            eta_total = activo.eficienciaCicloCompleto_pct / 100
            eta_carga = eta_descarga = eta_total ** 0.5

            # 3.1. Calcular suelo (soc_min) y techo (soc_max) de SoC
            soc_min = (1 - activo.profundidadDescargaMax_pct/100) * capacidad
            soc_max = capacidad

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

            # 3.6. Actualizar SoC y contadores
            estado_alm[id_alm]['soc_kwh'] += energia_a_cargar
            energia_restante -= energia_input
            energia_gestionada += energia_input

            print(f"[DEBUG] Cargando {id_alm}: +{energia_a_cargar:.4f} kWh netos "\
                f"({energia_input:.4f} kWh brutos, η={eta_carga:.2f})")

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
            capacidad = activo.capacidadNominal_kWh
            soc_actual = estado_alm[id_alm]['soc_kwh']
            eta_total = activo.eficienciaCicloCompleto_pct / 100
            eta_carga = eta_descarga = eta_total ** 0.5

            # 4.1. Calcular suelo de SoC
            soc_min = (1 - activo.profundidadDescargaMax_pct/100) * capacidad
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
            energia_a_descargar = min(deficit / eta_descarga,
                                    energia_disponible,
                                    energia_max_descarga)

            # 4.5. Energía neta que sale tras eficiencia
            energia_output = energia_a_descargar * eta_descarga

            # 4.6. Actualizar SoC y contadores
            estado_alm[id_alm]['soc_kwh'] -= energia_a_descargar
            deficit -= energia_output
            energia_descargada_total += energia_output

            print(f"[DEBUG] Descargando {id_alm}: -{energia_output:.4f} kWh netos "\
                f"({energia_a_descargar:.4f} kWh brutos, η={eta_descarga:.2f})")

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
        print(f"[DEBUG] Balance energético neutro: {excedentes_o_deficit:.4f} kWh, sin carga ni descarga")
        # Crear registros para todos los activos cuando no hay excedentes ni déficit
        for activo in activos_alm:
            id_alm = activo.idActivoAlmacenamiento
            intervalo_activos_alm.append(
                {
                    'timestamp': intervalo,
                    'energiaCargada_kWh': 0.0,
                    'energiaDescargada_kWh': 0.0,
                    'SoC_kWh': estado_alm[id_alm]['soc_kwh'],
                    'idActivoAlmacenamiento': id_alm,
                }
            )
            print(f"[DEBUG] Activo {id_alm}: Sin actividad, SoC={estado_alm[id_alm]['soc_kwh']:.4f} kWh")

    return energia_gestionada, estado_alm, intervalo_activos_alm