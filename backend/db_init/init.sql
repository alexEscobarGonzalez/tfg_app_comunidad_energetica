
CREATE DATABASE IF NOT EXISTS `comunidad_energetica_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `comunidad_energetica_db`;

-- Borrar tablas existentes (en orden inverso de creación para evitar problemas de FK)
DROP TABLE IF EXISTS `DATOS_INTERVALO_ACTIVO`;
DROP TABLE IF EXISTS `DATOS_INTERVALO_PARTICIPANTE`;
DROP TABLE IF EXISTS `RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO`;
DROP TABLE IF EXISTS `RESULTADO_SIMULACION_ACTIVO_GENERACION`;
DROP TABLE IF EXISTS `RESULTADO_SIMULACION_PARTICIPANTE`;
DROP TABLE IF EXISTS `RESULTADO_SIMULACION`;
DROP TABLE IF EXISTS `DATOS_AMBIENTALES`;
DROP TABLE IF EXISTS `SIMULACION`;
DROP TABLE IF EXISTS `ACTIVO_GENERACION_UNICA`;
DROP TABLE IF EXISTS `ACTIVO_ALMACENAMIENTO`;
DROP TABLE IF EXISTS `REGISTRO_CONSUMO`;
DROP TABLE IF EXISTS `COEFICIENTE_REPARTO`;
DROP TABLE IF EXISTS `CONTRATO_AUTOCONSUMO`;
DROP TABLE IF EXISTS `PARTICIPANTE`;
DROP TABLE IF EXISTS `COMUNIDAD_ENERGETICA`;
DROP TABLE IF EXISTS `USUARIO`;

-- Crear tablas

-- Tabla USUARIO
CREATE TABLE `USUARIO` (
    `idUsuario` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    `correo` VARCHAR(255) NOT NULL UNIQUE,
    `hashContrasena` VARCHAR(255) NOT NULL, -- Ajustar longitud según el método de hash
    PRIMARY KEY (`idUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla COMUNIDAD_ENERGETICA
CREATE TABLE `COMUNIDAD_ENERGETICA` (
    `idComunidadEnergetica` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    `latitud` FLOAT,
    `longitud` FLOAT,
    `tipoEstrategiaExcedentes` VARCHAR(100), -- Podría ser ENUM('Venta', 'Compensacion', 'Almacenamiento', ...)
    `idUsuario_gestor` INT NOT NULL,
    PRIMARY KEY (`idComunidadEnergetica`),
    FOREIGN KEY (`idUsuario_gestor`) REFERENCES `USUARIO`(`idUsuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla PARTICIPANTE
CREATE TABLE `PARTICIPANTE` (
    `idParticipante` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    `idComunidadEnergetica` INT NOT NULL,
    PRIMARY KEY (`idParticipante`),
    FOREIGN KEY (`idComunidadEnergetica`) REFERENCES `COMUNIDAD_ENERGETICA`(`idComunidadEnergetica`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla CONTRATO_AUTOCONSUMO
CREATE TABLE `CONTRATO_AUTOCONSUMO` (
    `idContrato` INT NOT NULL AUTO_INCREMENT,
    `tipoContrato` VARCHAR(100), -- Podría ser ENUM('Individual', 'Colectivo', ...)
    `precioEnergiaImportacion_eur_kWh` FLOAT,
    `precioCompensacionExcedentes_eur_kWh` FLOAT,
    `potenciaContratada_kW` FLOAT,
    `precioPotenciaContratado_eur_kWh` FLOAT, -- Revisar unidad, ¿quizás eur/kW/año?
    `idParticipante` INT NOT NULL UNIQUE, -- Asume un contrato por participante
    PRIMARY KEY (`idContrato`),
    FOREIGN KEY (`idParticipante`) REFERENCES `PARTICIPANTE`(`idParticipante`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `COEFICIENTE_REPARTO` (
    `idCoeficienteReparto` INT NOT NULL AUTO_INCREMENT,
    `tipoReparto` VARCHAR(100), -- Podría ser ENUM('Fijo', 'Variable', 'Programado', ...)
    `parametros` JSON, -- Campo JSON para almacenar todos los parámetros de forma flexible
    `idParticipante` INT NOT NULL,
    PRIMARY KEY (`idCoeficienteReparto`),
    FOREIGN KEY (`idParticipante`) REFERENCES `PARTICIPANTE`(`idParticipante`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla REGISTRO_CONSUMO
CREATE TABLE `REGISTRO_CONSUMO` (
    `idRegistroConsumo` INT NOT NULL AUTO_INCREMENT,
    `timestamp` DATETIME NOT NULL,
    `consumoEnergia` FLOAT NOT NULL, -- Asumiendo kWh
    `idParticipante` INT NOT NULL,
    PRIMARY KEY (`idRegistroConsumo`),
    FOREIGN KEY (`idParticipante`) REFERENCES `PARTICIPANTE`(`idParticipante`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_registro_consumo_participante_ts` (`idParticipante`, `timestamp`) -- Índice útil para búsquedas por participante y fecha
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla ACTIVO_GENERACION_UNICA (Combinación de las tablas anteriores)
CREATE TABLE `ACTIVO_GENERACION_UNICA` (
    `idActivoGeneracion` INT NOT NULL AUTO_INCREMENT,
    `nombreDescriptivo` VARCHAR(255),
    `fechaInstalacion` DATE,
    `costeInstalacion_eur` FLOAT,
    `vidaUtil_anios` INT,
    `latitud` FLOAT,
    `longitud` FLOAT,
    `potenciaNominal_kWp` FLOAT,
    `idComunidadEnergetica` INT NOT NULL,
    `tipo_activo` VARCHAR(100) NOT NULL, -- 'Fotovoltaica', 'Aerogenerador', etc.
    
    -- Atributos de INSTALACION_FOTOVOLTAICA (ahora NULLABLE)
    `inclinacionGrados` FLOAT NULL,
    `azimutGrados` FLOAT NULL,
    `tecnologiaPanel` VARCHAR(100) NULL,
    `perdidaSistema` FLOAT NULL,
    `posicionMontaje` VARCHAR(100) NULL,
    
    -- Atributos de AEROGENERADOR (ahora NULLABLE)
    `curvaPotencia` TEXT NULL,
    
    PRIMARY KEY (`idActivoGeneracion`),
    FOREIGN KEY (`idComunidadEnergetica`) REFERENCES `COMUNIDAD_ENERGETICA`(`idComunidadEnergetica`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla ACTIVO_ALMACENAMIENTO
CREATE TABLE `ACTIVO_ALMACENAMIENTO` (
    `idActivoAlmacenamiento` INT NOT NULL AUTO_INCREMENT,
    `nombreDescriptivo` VARCHAR(255), -- Añadido, suele ser útil
    `capacidadNominal_kWh` FLOAT NOT NULL,
    `potenciaMaximaCarga_kW` FLOAT,
    `potenciaMaximaDescarga_kW` FLOAT,
    `eficienciaCicloCompleto_pct` FLOAT,
    `profundidadDescargaMax_pct` FLOAT,
    `idComunidadEnergetica` INT NOT NULL,
    PRIMARY KEY (`idActivoAlmacenamiento`),
    FOREIGN KEY (`idComunidadEnergetica`) REFERENCES `COMUNIDAD_ENERGETICA`(`idComunidadEnergetica`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla SIMULACION
CREATE TABLE `SIMULACION` (
    `idSimulacion` INT NOT NULL AUTO_INCREMENT,
    `nombreSimulacion` VARCHAR(255),
    `fechaInicio` DATE NOT NULL,
    `fechaFin` DATE NOT NULL,
    `tiempo_medicion` INT, -- ¿Minutos, segundos? Añadir unidad en comentario o nombre
    `estado` VARCHAR(50), -- Podría ser ENUM('Pendiente', 'Ejecutando', 'Completada', 'Error')
    `tipoEstrategiaExcedentes` VARCHAR(100), -- Podría ser ENUM(...) Igual que en COMUNIDAD_ENERGETICA? O específico de la simulación?
    `idUsuario_creador` INT NOT NULL,
    `idComunidadEnergetica` INT NOT NULL,
    PRIMARY KEY (`idSimulacion`),
    FOREIGN KEY (`idUsuario_creador`) REFERENCES `USUARIO`(`idUsuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`idComunidadEnergetica`) REFERENCES `COMUNIDAD_ENERGETICA`(`idComunidadEnergetica`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla DATOS_AMBIENTALES (Datos de entrada para la simulación)
CREATE TABLE `DATOS_AMBIENTALES` (
    `idRegistro` INT NOT NULL AUTO_INCREMENT,
    `timestamp` DATETIME NOT NULL,
    `fuenteDatos` VARCHAR(100),
    `radiacionGlobalHoriz_Wh_m2` FLOAT,
    `temperaturaAmbiente_C` FLOAT,
    `velocidadViento_m_s` FLOAT,
    `idSimulacion` INT NOT NULL,
    PRIMARY KEY (`idRegistro`),
    FOREIGN KEY (`idSimulacion`) REFERENCES `SIMULACION`(`idSimulacion`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_datos_ambientales_sim_ts` (`idSimulacion`, `timestamp`) -- Índice útil
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla RESULTADO_SIMULACION (Resultados globales)
CREATE TABLE `RESULTADO_SIMULACION` (
    `idResultado` INT NOT NULL AUTO_INCREMENT,
    `fechaCreacion` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `costeTotalEnergia_eur` FLOAT,
    `ahorroTotal_eur` FLOAT,
    `ingresoTotalExportacion_eur` FLOAT,
    `paybackPeriod_anios` FLOAT,
    `roi_pct` FLOAT,
    `tasaAutoconsumoSCR_pct` FLOAT,
    `tasaAutosuficienciaSSR_pct` FLOAT,
    `energiaTotalImportada_kWh` FLOAT,
    `energiaTotalExportada_kWh` FLOAT,
    `energiaCompartidaInterna_kWh` FLOAT,
    `reduccionPicoDemanda_kW` FLOAT,
    `reduccionPicoDemanda_pct` FLOAT,
    `reduccionCO2_kg` FLOAT,
    `idSimulacion` INT NOT NULL UNIQUE, -- Asume un resultado global por simulación
    PRIMARY KEY (`idResultado`),
    FOREIGN KEY (`idSimulacion`) REFERENCES `SIMULACION`(`idSimulacion`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla RESULTADO_SIMULACION_PARTICIPANTE
CREATE TABLE `RESULTADO_SIMULACION_PARTICIPANTE` (
    `idResultadoParticipante` INT NOT NULL AUTO_INCREMENT,
    `costeNetoParticipante_eur` FLOAT,
    `ahorroParticipante_eur` FLOAT,
    `ahorroParticipante_pct` FLOAT,
    `energiaAutoconsumidaDirecta_kWh` FLOAT,
    `energiaRecibidaRepartoConsumida_kWh` FLOAT,
    `tasaAutoconsumoSCR_pct` FLOAT,
    `tasaAutosuficienciaSSR_pct` FLOAT,
    `idResultadoSimulacion` INT NOT NULL,
    `idParticipante` INT NOT NULL,
    PRIMARY KEY (`idResultadoParticipante`),
    FOREIGN KEY (`idResultadoSimulacion`) REFERENCES `RESULTADO_SIMULACION`(`idResultado`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`idParticipante`) REFERENCES `PARTICIPANTE`(`idParticipante`) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY `uq_resultado_sim_participante` (`idResultadoSimulacion`, `idParticipante`) -- Un resultado por participante por simulación
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla RESULTADO_SIMULACION_ACTIVO_GENERACION
CREATE TABLE `RESULTADO_SIMULACION_ACTIVO_GENERACION` (
    `idResultadoActivoGen` INT NOT NULL AUTO_INCREMENT,
    `energiaTotalGenerada_kWh` FLOAT,
    `factorCapacidad_pct` FLOAT,
    `performanceRatio_pct` FLOAT,
    `horasOperacionEquivalentes` FLOAT,
    `idResultadoSimulacion` INT NOT NULL,
    `idActivoGeneracion` INT NOT NULL,
    PRIMARY KEY (`idResultadoActivoGen`),
    FOREIGN KEY (`idResultadoSimulacion`) REFERENCES `RESULTADO_SIMULACION`(`idResultado`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`idActivoGeneracion`) REFERENCES `ACTIVO_GENERACION_UNICA`(`idActivoGeneracion`) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY `uq_resultado_sim_activo_gen` (`idResultadoSimulacion`, `idActivoGeneracion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO
CREATE TABLE `RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO` (
    `idResultadoActivoAlm` INT NOT NULL AUTO_INCREMENT,
    `energiaTotalCargada_kWh` FLOAT,
    `energiaTotalDescargada_kWh` FLOAT,
    `ciclosEquivalentes` FLOAT,
    `perdidasEficiencia_kWh` FLOAT,
    `socMedio_pct` FLOAT,
    `socMin_pct` FLOAT,
    `socMax_pct` FLOAT,
    `degradacionEstimada_pct` FLOAT,
    `throughputTotal_kWh` FLOAT,
    `idResultadoSimulacion` INT NOT NULL,
    `idActivoAlmacenamiento` INT NOT NULL,
    PRIMARY KEY (`idResultadoActivoAlm`),
    FOREIGN KEY (`idResultadoSimulacion`) REFERENCES `RESULTADO_SIMULACION`(`idResultado`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`idActivoAlmacenamiento`) REFERENCES `ACTIVO_ALMACENAMIENTO`(`idActivoAlmacenamiento`) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY `uq_resultado_sim_activo_alm` (`idResultadoSimulacion`, `idActivoAlmacenamiento`) -- Un resultado por activo alm por simulación
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla DATOS_INTERVALO_PARTICIPANTE (Datos detallados por intervalo)
CREATE TABLE `DATOS_INTERVALO_PARTICIPANTE` (
    `idDatosIntervaloParticipante` INT NOT NULL AUTO_INCREMENT,
    `timestamp` DATETIME NOT NULL,
    `consumoReal_kWh` FLOAT,
    `produccionPropia_kWh` FLOAT,
    `energiaRecibidaReparto_kWh` FLOAT,
    `energiaDesdeAlmacenamientoInd_kWh` FLOAT,
    `energiaHaciaAlmacenamientoInd_kWh` FLOAT,
    `energiaDesdeRed_kWh` FLOAT,
    `excedenteVertidoCompensado_kWh` FLOAT,
    `estadoAlmacenamientoInd_kWh` FLOAT, -- ¿Nivel de carga?
    `precioImportacionIntervalo` FLOAT,
    `precioExportacionIntervalo` FLOAT,
    `idResultadoParticipante` INT NOT NULL,
    PRIMARY KEY (`idDatosIntervaloParticipante`),
    FOREIGN KEY (`idResultadoParticipante`) REFERENCES `RESULTADO_SIMULACION_PARTICIPANTE`(`idResultadoParticipante`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_intervalo_participante_ts` (`idResultadoParticipante`, `timestamp`) -- Índice útil
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `DATOS_INTERVALO_ACTIVO` (
    `idDatosIntervaloActivo` INT NOT NULL AUTO_INCREMENT,
    `timestamp` DATETIME NOT NULL,
    `energiaGenerada_kWh` FLOAT NULL,
    `energiaCargada_kWh` FLOAT NULL,
    `energiaDescargada_kWh` FLOAT NULL,
    `SoC_kWh` FLOAT NULL, -- Estado de carga en kWh (o podría ser %)
    `idResultadoActivoGen` INT NULL, -- FK a resultado de generación (si aplica)
    `idResultadoActivoAlm` INT NULL, -- FK a resultado de almacenamiento (si aplica)
    PRIMARY KEY (`idDatosIntervaloActivo`),
    FOREIGN KEY (`idResultadoActivoGen`) REFERENCES `RESULTADO_SIMULACION_ACTIVO_GENERACION`(`idResultadoActivoGen`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`idResultadoActivoAlm`) REFERENCES `RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO`(`idResultadoActivoAlm`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_intervalo_activo_ts` (`timestamp`) -- Índice útil
    -- Se podría añadir un CHECK constraint para asegurar que al menos uno de los FKs no es NULL si fuera necesario
    -- CONSTRAINT `chk_activo_fk` CHECK (`idResultadoActivoGen` IS NOT NULL OR `idResultadoActivoAlm` IS NOT NULL) -- Opcional: asegura que el registro pertenece a un activo -> Removed due to compatibility issues
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;