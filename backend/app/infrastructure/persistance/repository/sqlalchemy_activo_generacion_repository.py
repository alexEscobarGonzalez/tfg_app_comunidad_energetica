from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.infrastructure.persistance.models.activo_generacion_tabla import ActivoGeneracion
from app.domain.repositories.activo_generacion_repository import ActivoGeneracionRepository
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion

class SqlAlchemyActivoGeneracionRepository(ActivoGeneracionRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: ActivoGeneracion) -> ActivoGeneracionEntity:
        """Convierte un modelo de tabla a una entidad de dominio"""
        return ActivoGeneracionEntity(
            idActivoGeneracion=model.idActivoGeneracion,
            nombreDescriptivo=model.nombreDescriptivo,
            fechaInstalacion=model.fechaInstalacion,
            costeInstalacion_eur=model.costeInstalacion_eur,
            vidaUtil_anios=model.vidaUtil_anios,
            latitud=model.latitud,
            longitud=model.longitud,
            potenciaNominal_kWp=model.potenciaNominal_kWp,
            idComunidadEnergetica=model.idComunidadEnergetica,
            tipo_activo=model.tipo_activo,
            inclinacionGrados=model.inclinacionGrados,
            azimutGrados=model.azimutGrados,
            tecnologiaPanel=model.tecnologiaPanel,
            perdidaSistema=model.perdidaSistema,
            posicionMontaje=model.posicionMontaje,
            curvaPotencia=model.curvaPotencia
        )
        
    def get_by_id(self, idActivoGeneracion: int) -> Optional[ActivoGeneracionEntity]:
        model = self.db.query(ActivoGeneracion).filter_by(idActivoGeneracion=idActivoGeneracion).first()
        if model:
            return self._map_to_entity(model)
        return None
        
    def get_by_comunidad(self, idComunidadEnergetica: int) -> List[ActivoGeneracionEntity]:
        models = self.db.query(ActivoGeneracion).filter_by(idComunidadEnergetica=idComunidadEnergetica).all()
        return [self._map_to_entity(model) for model in models]
    
    def get_by_comunidad_y_tipo(self, idComunidadEnergetica: int, tipo_activo: TipoActivoGeneracion) -> List[ActivoGeneracionEntity]:
        models = self.db.query(ActivoGeneracion).filter_by(
            idComunidadEnergetica=idComunidadEnergetica,
            tipo_activo=tipo_activo
        ).all()
        return [self._map_to_entity(model) for model in models]
    
    def list(self) -> List[ActivoGeneracionEntity]:
        models = self.db.query(ActivoGeneracion).all()
        return [self._map_to_entity(model) for model in models]
        
    def create(self, activo: ActivoGeneracionEntity) -> ActivoGeneracionEntity:
        model = ActivoGeneracion(
            nombreDescriptivo=activo.nombreDescriptivo,
            fechaInstalacion=activo.fechaInstalacion,
            costeInstalacion_eur=activo.costeInstalacion_eur,
            vidaUtil_anios=activo.vidaUtil_anios,
            latitud=activo.latitud,
            longitud=activo.longitud,
            potenciaNominal_kWp=activo.potenciaNominal_kWp,
            idComunidadEnergetica=activo.idComunidadEnergetica,
            tipo_activo=activo.tipo_activo
        )
        
        # Configurar campos específicos según el tipo de activo
        if activo.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
            model.inclinacionGrados = activo.inclinacionGrados
            model.azimutGrados = activo.azimutGrados
            model.tecnologiaPanel = activo.tecnologiaPanel
            model.perdidaSistema = activo.perdidaSistema
            model.posicionMontaje = activo.posicionMontaje
        elif activo.tipo_activo == TipoActivoGeneracion.AEROGENERADOR:
            model.curvaPotencia = activo.curvaPotencia
            
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)
        
    def update(self, activo: ActivoGeneracionEntity) -> ActivoGeneracionEntity:
        model = self.db.query(ActivoGeneracion).filter_by(idActivoGeneracion=activo.idActivoGeneracion).first()
        if model:
            # Actualizar campos comunes
            model.nombreDescriptivo = activo.nombreDescriptivo
            model.costeInstalacion_eur = activo.costeInstalacion_eur
            model.vidaUtil_anios = activo.vidaUtil_anios
            model.potenciaNominal_kWp = activo.potenciaNominal_kWp
            
            # Actualizar campos específicos según el tipo de activo
            if model.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
                model.inclinacionGrados = activo.inclinacionGrados
                model.azimutGrados = activo.azimutGrados
                model.tecnologiaPanel = activo.tecnologiaPanel
                model.perdidaSistema = activo.perdidaSistema
                model.posicionMontaje = activo.posicionMontaje
            elif model.tipo_activo == TipoActivoGeneracion.AEROGENERADOR:
                model.curvaPotencia = activo.curvaPotencia
            
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        return None
        
    def delete(self, idActivoGeneracion: int) -> None:
        model = self.db.query(ActivoGeneracion).filter_by(idActivoGeneracion=idActivoGeneracion).first()
        if model:
            self.db.delete(model)
            self.db.commit()