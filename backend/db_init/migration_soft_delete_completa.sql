-- ========================================
-- PARTE 1: ACTIVO_ALMACENAMIENTO
-- ========================================

-- 1.1. Agregar columnas para soft delete en ACTIVO_ALMACENAMIENTO
ALTER TABLE ACTIVO_ALMACENAMIENTO 
ADD COLUMN esta_activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE ACTIVO_ALMACENAMIENTO 
ADD COLUMN fecha_eliminacion DATETIME NULL;

-- 1.2. Modificar la foreign key en RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO
-- Primero eliminar la constraint existente
ALTER TABLE RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO 
DROP FOREIGN KEY `resultado_simulacion_activo_almacenamiento_ibfk_2`;

-- Modificar la columna para permitir NULL
ALTER TABLE RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO 
MODIFY COLUMN idActivoAlmacenamiento INT NULL;

-- Crear nueva foreign key con ON DELETE SET NULL
ALTER TABLE RESULTADO_SIMULACION_ACTIVO_ALMACENAMIENTO 
ADD CONSTRAINT `resultado_simulacion_activo_almacenamiento_ibfk_2` 
FOREIGN KEY (idActivoAlmacenamiento) 
REFERENCES ACTIVO_ALMACENAMIENTO(idActivoAlmacenamiento) 
ON DELETE SET NULL;

-- 1.3. Crear índice para mejorar consultas de activos activos
CREATE INDEX idx_activo_almacenamiento_esta_activo ON ACTIVO_ALMACENAMIENTO(esta_activo);

-- ========================================
-- PARTE 2: ACTIVO_GENERACION_UNICA
-- ========================================

-- 2.1. Agregar columnas para soft delete en ACTIVO_GENERACION_UNICA
ALTER TABLE ACTIVO_GENERACION_UNICA 
ADD COLUMN esta_activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE ACTIVO_GENERACION_UNICA 
ADD COLUMN fecha_eliminacion DATETIME NULL;

-- 2.2. Modificar la foreign key en RESULTADO_SIMULACION_ACTIVO_GENERACION
-- Primero eliminar la constraint existente
ALTER TABLE RESULTADO_SIMULACION_ACTIVO_GENERACION 
DROP FOREIGN KEY `resultado_simulacion_activo_generacion_ibfk_2`;

-- Modificar la columna para permitir NULL
ALTER TABLE RESULTADO_SIMULACION_ACTIVO_GENERACION 
MODIFY COLUMN idActivoGeneracion INT NULL;

-- Crear nueva foreign key con ON DELETE SET NULL
ALTER TABLE RESULTADO_SIMULACION_ACTIVO_GENERACION 
ADD CONSTRAINT `resultado_simulacion_activo_generacion_ibfk_2` 
FOREIGN KEY (idActivoGeneracion) 
REFERENCES ACTIVO_GENERACION_UNICA(idActivoGeneracion) 
ON DELETE SET NULL;

-- 2.3. Crear índice para mejorar consultas de activos activos
CREATE INDEX idx_activo_generacion_esta_activo ON ACTIVO_GENERACION_UNICA(esta_activo);

-- ========================================
-- PARTE 3: COMENTARIOS PARA DOCUMENTACIÓN
-- ========================================

-- Comentarios para ACTIVO_ALMACENAMIENTO
ALTER TABLE ACTIVO_ALMACENAMIENTO 
MODIFY COLUMN esta_activo BOOLEAN NOT NULL DEFAULT TRUE 
COMMENT 'Indica si el activo está activo (TRUE) o eliminado lógicamente (FALSE)';

ALTER TABLE ACTIVO_ALMACENAMIENTO 
MODIFY COLUMN fecha_eliminacion DATETIME NULL 
COMMENT 'Fecha y hora en que se realizó la eliminación lógica del activo';

-- Comentarios para ACTIVO_GENERACION_UNICA
ALTER TABLE ACTIVO_GENERACION_UNICA 
MODIFY COLUMN esta_activo BOOLEAN NOT NULL DEFAULT TRUE 
COMMENT 'Indica si el activo está activo (TRUE) o eliminado lógicamente (FALSE)';

ALTER TABLE ACTIVO_GENERACION_UNICA 
MODIFY COLUMN fecha_eliminacion DATETIME NULL 
COMMENT 'Fecha y hora en que se realizó la eliminación lógica del activo';

-- ========================================
-- VERIFICACIÓN DE LA MIGRACIÓN
-- ========================================

-- Verificar que las columnas se crearon correctamente
SELECT 
    'ACTIVO_ALMACENAMIENTO' as tabla,
    COUNT(*) as total_activos,
    SUM(CASE WHEN esta_activo = TRUE THEN 1 ELSE 0 END) as activos_activos,
    SUM(CASE WHEN esta_activo = FALSE THEN 1 ELSE 0 END) as activos_eliminados
FROM ACTIVO_ALMACENAMIENTO

UNION ALL

SELECT 
    'ACTIVO_GENERACION_UNICA' as tabla,
    COUNT(*) as total_activos,
    SUM(CASE WHEN esta_activo = TRUE THEN 1 ELSE 0 END) as activos_activos,
    SUM(CASE WHEN esta_activo = FALSE THEN 1 ELSE 0 END) as activos_eliminados
FROM ACTIVO_GENERACION_UNICA; 