from pydantic import BaseModel
from typing import Optional, List
from datetime import date

class UsuarioBase(BaseModel):
    nombre: str
    correo: str

class UsuarioCreate(UsuarioBase):
    hashContrasena: str

class UsuarioRead(UsuarioBase):
    idUsuario: int
    class Config:
        orm_mode = True

class ComunidadEnergeticaBase(BaseModel):
    nombre: str
    latitud: Optional[float]
    longitud: Optional[float]
    tipoEstrategiaExcedentes: Optional[str]

class ComunidadEnergeticaCreate(ComunidadEnergeticaBase):
    idUsuario_gestor: int

class ComunidadEnergeticaRead(ComunidadEnergeticaBase):
    idComunidadEnergetica: int
    idUsuario_gestor: int
    class Config:
        orm_mode = True

class ParticipanteBase(BaseModel):
    nombre: str
    idComunidadEnergetica: int

class ParticipanteCreate(ParticipanteBase):
    pass

class ParticipanteRead(ParticipanteBase):
    idParticipante: int
    class Config:
        orm_mode = True

class ContratoAutoconsumoBase(BaseModel):
    tipoContrato: Optional[str]
    precioEnergiaImportacion_eur_kWh: Optional[float]
    precioCompensacionExcedentes_eur_kWh: Optional[float]
    potenciaContratada_kW: Optional[float]
    precioPotenciaContratado_eur_kWh: Optional[float]
    idParticipante: int

class ContratoAutoconsumoCreate(ContratoAutoconsumoBase):
    pass

class ContratoAutoconsumoRead(ContratoAutoconsumoBase):
    idContrato: int
    class Config:
        orm_mode = True

class CoeficienteRepartoBase(BaseModel):
    tipoReparto: Optional[str]
    parametrosCoeficientesFijo: Optional[float]
    idParticipante: int

class CoeficienteRepartoCreate(CoeficienteRepartoBase):
    pass

class CoeficienteRepartoRead(CoeficienteRepartoBase):
    idCoeficienteReparto: int
    class Config:
        orm_mode = True

class ParametroCoeficienteProgramadoBase(BaseModel):
    idCoeficienteReparto: int
    fecha: date
    valor: float

class ParametroCoeficienteProgramadoCreate(ParametroCoeficienteProgramadoBase):
    pass

class ParametroCoeficienteProgramadoRead(ParametroCoeficienteProgramadoBase):
    idParamCoefProg: int
    class Config:
        orm_mode = True

class RegistroConsumoBase(BaseModel):
    timestamp: str
    consumoEnergia: float
    idParticipante: int

class RegistroConsumoCreate(RegistroConsumoBase):
    pass

class RegistroConsumoRead(RegistroConsumoBase):
    idRegistroConsumo: int
    class Config:
        orm_mode = True

class ActivoGeneracionBase(BaseModel):
    nombreDescriptivo: Optional[str]
    fechaInstalacion: Optional[date]
    costeInstalacion_eur: Optional[float]
    vidaUtil_anios: Optional[int]
    latitud: Optional[float]
    longitud: Optional[float]
    potenciaNominal_kWp: Optional[float]
    tipoTecnologia: str
    idComunidadEnergetica: int

class ActivoGeneracionCreate(ActivoGeneracionBase):
    pass

class ActivoGeneracionRead(ActivoGeneracionBase):
    idActivoGeneracion: int
    class Config:
        orm_mode = True

class InstalacionFotovoltaicaBase(BaseModel):
    idActivoGeneracion: int
    inclinacionGrados: Optional[float]
    azimutGrados: Optional[float]
    tecnologiaPanel: Optional[str]
    perdidaSistema: Optional[float]
    posicionMontaje: Optional[str]

class InstalacionFotovoltaicaCreate(InstalacionFotovoltaicaBase):
    pass

class InstalacionFotovoltaicaRead(InstalacionFotovoltaicaBase):
    class Config:
        orm_mode = True

class AerogeneradorBase(BaseModel):
    idActivoGeneracion: int
    curvaPotencia: Optional[str]

class AerogeneradorCreate(AerogeneradorBase):
    pass

class AerogeneradorRead(AerogeneradorBase):
    class Config:
        orm_mode = True

class ActivoAlmacenamientoBase(BaseModel):
    nombreDescriptivo: Optional[str]
    capacidadNominal_kWh: float
    potenciaMaximaCarga_kW: Optional[float]
    potenciaMaximaDescarga_kW: Optional[float]
    eficienciaCicloCompleto_pct: Optional[float]
    profundidadDescargaMax_pct: Optional[float]
    idComunidadEnergetica: int

class ActivoAlmacenamientoCreate(ActivoAlmacenamientoBase):
    pass

class ActivoAlmacenamientoRead(ActivoAlmacenamientoBase):
    idActivoAlmacenamiento: int
    class Config:
        orm_mode = True

class SimulacionBase(BaseModel):
    nombreSimulacion: Optional[str]
    fechaInicio: date
    fechaFin: date
    tiempo_medicion: Optional[int]
    estado: Optional[str]
    tipoEstrategiaExcedentes: Optional[str]
    idUsuario_creador: int
    idComunidadEnergetica: int

class SimulacionCreate(SimulacionBase):
    pass

class SimulacionRead(SimulacionBase):
    idSimulacion: int
    class Config:
        orm_mode = True

class DatosAmbientalesBase(BaseModel):
    timestamp: str
    fuenteDatos: Optional[str]
    radiacionGlobalHoriz_Wh_m2: Optional[float]
    temperaturaAmbiente_C: Optional[float]
    velocidadViento_m_s: Optional[float]
    idSimulacion: int

class DatosAmbientalesCreate(DatosAmbientalesBase):
    pass

class DatosAmbientalesRead(DatosAmbientalesBase):
    idRegistro: int
    class Config:
        orm_mode = True

class ResultadoSimulacionBase(BaseModel):
    fechaCreacion: Optional[str]
    costeTotalEnergia_eur: Optional[float]
    ahorroTotal_eur: Optional[float]
    ingresoTotalExportacion_eur: Optional[float]
    paybackPeriod_anios: Optional[float]
    roi_pct: Optional[float]
    tasaAutoconsumoSCR_pct: Optional[float]
    tasaAutosuficienciaSSR_pct: Optional[float]
    energiaTotalImportada_kWh: Optional[float]
    energiaTotalExportada_kWh: Optional[float]
    energiaCompartidaInterna_kWh: Optional[float]
    reduccionPicoDemanda_kW: Optional[float]
    reduccionPicoDemanda_pct: Optional[float]
    reduccionCO2_kg: Optional[float]
    idSimulacion: int

class ResultadoSimulacionCreate(ResultadoSimulacionBase):
    pass

class ResultadoSimulacionRead(ResultadoSimulacionBase):
    idResultado: int
    class Config:
        orm_mode = True

class ResultadoSimulacionParticipanteBase(BaseModel):
    costeNetoParticipante_eur: Optional[float]
    ahorroParticipante_eur: Optional[float]
    ahorroParticipante_pct: Optional[float]
    energiaAutoconsumidaDirecta_kWh: Optional[float]
    energiaRecibidaRepartoConsumida_kWh: Optional[float]
    tasaAutoconsumoSCR_pct: Optional[float]
    tasaAutosuficienciaSSR_pct: Optional[float]
    idResultadoSimulacion: int
    idParticipante: int

class ResultadoSimulacionParticipanteCreate(ResultadoSimulacionParticipanteBase):
    pass

class ResultadoSimulacionParticipanteRead(ResultadoSimulacionParticipanteBase):
    idResultadoParticipante: int
    class Config:
        orm_mode = True

class ResultadoSimulacionActivoGeneracionBase(BaseModel):
    energiaTotalGenerada_kWh: Optional[float]
    factorCapacidad_pct: Optional[float]
    performanceRatio_pct: Optional[float]
    horasOperacionEquivalentes: Optional[float]
    idResultadoSimulacion: int
    idActivoGeneracion: int

class ResultadoSimulacionActivoGeneracionCreate(ResultadoSimulacionActivoGeneracionBase):
    pass

class ResultadoSimulacionActivoGeneracionRead(ResultadoSimulacionActivoGeneracionBase):
    idResultadoActivoGen: int
    class Config:
        orm_mode = True

class ResultadoSimulacionActivoAlmacenamientoBase(BaseModel):
    energiaTotalCargada_kWh: Optional[float]
    energiaTotalDescargada_kWh: Optional[float]
    ciclosEquivalentes: Optional[float]
    perdidasEficiencia_kWh: Optional[float]
    socMedio_pct: Optional[float]
    socMin_pct: Optional[float]
    socMax_pct: Optional[float]
    degradacionEstimada_pct: Optional[float]
    throughputTotal_kWh: Optional[float]
    idResultadoSimulacion: int
    idActivoAlmacenamiento: int

class ResultadoSimulacionActivoAlmacenamientoCreate(ResultadoSimulacionActivoAlmacenamientoBase):
    pass

class ResultadoSimulacionActivoAlmacenamientoRead(ResultadoSimulacionActivoAlmacenamientoBase):
    idResultadoActivoAlm: int
    class Config:
        orm_mode = True

class DatosIntervaloParticipanteBase(BaseModel):
    timestamp: str
    consumoReal_kWh: Optional[float]
    produccionPropia_kWh: Optional[float]
    energiaRecibidaReparto_kWh: Optional[float]
    energiaDesdeAlmacenamientoInd_kWh: Optional[float]
    energiaHaciaAlmacenamientoInd_kWh: Optional[float]
    energiaDesdeRed_kWh: Optional[float]
    excedenteVertidoCompensado_kWh: Optional[float]
    excedenteVertidoNoCompensado_kWh: Optional[float]
    estadoAlmacenamientoInd_kWh: Optional[float]
    precioImportacionIntervalo: Optional[float]
    precioExportacionIntervalo: Optional[float]
    idResultadoParticipante: int

class DatosIntervaloParticipanteCreate(DatosIntervaloParticipanteBase):
    pass

class DatosIntervaloParticipanteRead(DatosIntervaloParticipanteBase):
    idDatosIntervaloParticipante: int
    class Config:
        orm_mode = True

class DatosIntervaloActivoBase(BaseModel):
    timestamp: str
    energiaGenerada_kWh: Optional[float]
    energiaCargada_kWh: Optional[float]
    energiaDescargada_kWh: Optional[float]
    SoC_kWh: Optional[float]
    idResultadoActivoGen: Optional[int]
    idResultadoActivoAlm: Optional[int]

class DatosIntervaloActivoCreate(DatosIntervaloActivoBase):
    pass

class DatosIntervaloActivoRead(DatosIntervaloActivoBase):
    idDatosIntervaloActivo: int
    class Config:
        orm_mode = True