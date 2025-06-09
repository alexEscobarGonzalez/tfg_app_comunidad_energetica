from datetime import datetime
from typing import Optional
from app.domain.entities.tipo_contrato import TipoContrato
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.domain.repositories.pvpc_precios_repository import PvpcPreciosRepository
import logging

def obtener_precio_energia(
    contrato: ContratoAutoconsumoEntity,
    timestamp: datetime,
    pvpc_repo: Optional[PvpcPreciosRepository] = None,
    tipo_precio: str = "importacion"
) -> float:
    
    if contrato.tipoContrato == TipoContrato.PVPC:
        if pvpc_repo is None:
            raise ValueError("Se requiere pvpc_repo para contratos PVPC")
        
        try:
            precio_pvpc = pvpc_repo.get_precio_by_timestamp(timestamp)
            
            if precio_pvpc is None:
                precio_fallback = (contrato.precioEnergiaImportacion_eur_kWh if tipo_precio == "importacion" 
                                 else contrato.precioCompensacionExcedentes_eur_kWh)
                logging.warning(f"No se encontró precio PVPC para timestamp {timestamp}. "
                              f"Usando precio fijo del contrato como fallback: {precio_fallback} €/kWh")
                return precio_fallback
            
            if tipo_precio == "importacion":
                precio = precio_pvpc.precio_importacion
                logging.debug(f"Precio PVPC importación obtenido para {timestamp}: {precio:.5f} €/kWh")
                return precio
            
            elif tipo_precio == "exportacion":
                if precio_pvpc.precio_exportacion is not None:
                    precio = precio_pvpc.precio_exportacion
                    logging.debug(f"Precio PVPC exportación obtenido para {timestamp}: {precio:.5f} €/kWh")
                    return precio
                else:
                    precio = contrato.precioCompensacionExcedentes_eur_kWh
                    logging.warning(f"No hay precio PVPC exportación para {timestamp}. "
                                  f"Usando precio del contrato: {precio:.5f} €/kWh")
                    return precio
            
        except Exception as e:
            precio_fallback = (contrato.precioEnergiaImportacion_eur_kWh if tipo_precio == "importacion" 
                             else contrato.precioCompensacionExcedentes_eur_kWh)
            logging.error(f"Error al obtener precio PVPC {tipo_precio} para timestamp {timestamp}: {str(e)}. "
                         f"Usando precio fijo del contrato como fallback: {precio_fallback} €/kWh")
            return precio_fallback
    
    elif contrato.tipoContrato == TipoContrato.MERCADO_LIBRE:
        if tipo_precio == "importacion":
            precio = contrato.precioEnergiaImportacion_eur_kWh
            logging.debug(f"Precio fijo mercado libre importación: {precio} €/kWh")
        else:
            precio = contrato.precioCompensacionExcedentes_eur_kWh
            logging.debug(f"Precio fijo mercado libre exportación: {precio} €/kWh")
        return precio
    
    else:
        precio_fallback = (contrato.precioEnergiaImportacion_eur_kWh if tipo_precio == "importacion" 
                         else contrato.precioCompensacionExcedentes_eur_kWh)
        logging.warning(f"Tipo de contrato no reconocido: {contrato.tipoContrato}. "
                       f"Usando precio fijo: {precio_fallback} €/kWh")
        return precio_fallback 