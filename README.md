# Simulador de Comunidades Energéticas

Aplicación web para la simulación y análisis de comunidades energéticas desarrollada como Trabajo de Fin de Grado. La aplicación permite modelar, simular y analizar el comportamiento energético y económico de comunidades de autoconsumo colectivo.

## Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación y Configuración](#instalación-y-configuración)
- [Guía de Usuario](#guía-de-usuario)
- [Documentación Técnica](#documentación-técnica)
- [Resolución de Problemas](#resolución-de-problemas)

## Descripción General

### Funcionalidades Principales

**Gestión de Comunidades Energéticas**
- Creación y configuración de comunidades energéticas
- Gestión de participantes (consumidores y prosumidores)
- Configuración de activos de generación (fotovoltaica, eólica)
- Sistemas de almacenamiento con gestión de degradación

**Motor de Simulación**
- Simulación temporal discreta con intervalos horarios
- Estrategias de gestión de excedentes configurables
- Integración con datos meteorológicos reales (PVGIS)
- Cálculo de precios dinámicos PVPC

**Análisis de Resultados**
- Indicadores económicos: ahorros, facturación, ROI
- Indicadores energéticos: autoconsumo, autosuficiencia, vertidos
- Análisis detallado por participante y activo
- Exportación de resultados y comparativas

### Stack Tecnológico

**Backend**
- FastAPI (Framework REST API)
- SQLAlchemy (ORM)
- MariaDB (Base de datos)
- Docker (Contenedorización)

**Frontend**
- Flutter Web (Framework de interfaz)
- Riverpod (Gestión de estado)
- FL Chart (Visualización de datos)

**Servicios Externos**
- PVGIS (Datos de radiación solar)
- REE España (Precios PVPC)

## Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Web   │    │   FastAPI       │    │   MariaDB       │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
│   Puerto 8080   │    │   Puerto 8000   │    │   Puerto 3306   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   APIs Externas │
                    │   - PVGIS       │
                    └─────────────────┘
```

## Requisitos del Sistema

### Software Requerido
- Docker Desktop
- Docker Compose
- 4GB RAM disponible
- 10GB espacio en disco

### Puertos Utilizados
- **8000**: Backend API (FastAPI)
- **8080**: Frontend Web (Flutter)
- **3307**: Base de datos (MariaDB, mapeado desde 3306)

## Instalación y Configuración

### 1. Obtener el Código Fuente

```bash
git clone <repository-url>
cd tfg-app-comunidad-energetica
```

### 2. Configurar Variables de Entorno

El archivo `backend/backend.env` contiene todas las configuraciones necesarias. Las variables por defecto son funcionales para desarrollo:

```env
# Configuración de Base de Datos
MYSQL_ROOT_PASSWORD=un_password_muy_seguro_para_root
MYSQL_DATABASE=comunidad_energetica_db
MYSQL_USER=usuario_app
MYSQL_PASSWORD=un_password_muy_seguro_para_app

# Conexión Backend a Base de Datos
DATABASE_HOSTNAME=db
DATABASE_PORT=3306
DATABASE_PASSWORD=${MYSQL_PASSWORD}
DATABASE_NAME=${MYSQL_DATABASE}
DATABASE_USERNAME=${MYSQL_USER}

# Configuración de Seguridad JWT
SECRET_KEY=otro_secreto_muy_largo_y_dificil_de_adivinar
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

**Nota**: Para producción, modifique las contraseñas y el `SECRET_KEY`.

### 3. Ejecutar la Aplicación

```bash
docker-compose up -d
```

Este comando:
- Construye las imágenes Docker necesarias
- Inicia MariaDB con los datos inicializados
- Inicia el backend FastAPI
- Inicia el frontend Flutter Web
- Configura la red entre contenedores

### 5. Verificar la Instalación

**Acceder a la aplicación:**
- Frontend: http://localhost:8080
- API Backend: http://localhost:8000
- Documentación API: http://localhost:8000/docs

## Guía de Usuario

### Flujo de Trabajo Completo

**Importar comunidad comunidad_export en el boton del header a la derecha**
**comunidad_export.zip**

### 0. Crear un usuario

### 1. Crear una Comunidad Energética

1. Hacer clic en "Nueva Comunidad" en el desplegable del header
2. Completar la información requerida

Las coordenadas geográficas son críticas para la obtención de datos meteorológicos.

### 2. Configurar Participantes

1. Seleccionar la comunidad creada
2. Navegar a "Participantes"
3. Añadir participantes
4. Introducir datos de contrato

### 3. Definir Activos de Generación

1. Ir a activos energeticos
2. Crear nuevo activo

### 4. Configurar Almacenamiento (Opcional)

Para sistemas con baterías:

1. Ir a activos energeticos
2. Definir características de la batería

### 5. Definir Coeficientes de Reparto

1. Acceder a "Coeficientes de Reparto"
2. Establecer cómo se distribuye la energía generada:
   
   **Reparto Fijo**:
   - Porcentaje constante para cada participante
   - Suma total debe ser 100%
   
   **Reparto Programado**:
   - Porcentajes variables según hora del día
   - Permite optimizar la distribución por patrones de consumo

### 6. Cargar Datos de Consumo

1. Ir a "Registro de Consumos"
2. Subir archivos CSV con formato específico:

```csv
timestamp,consumoEnergia
2024-01-01 00:00:00,1.5
2024-01-01 01:00:00,1.2
2024-01-01 02:00:00,0.8
```

**Utilizar ejemplo ya creado consumo_familia_lopez.csv**

### 7. Ejecutar Simulación

1. Navegar a "Simulaciones"
2. Crear nueva simulación:
3. Iniciar la simulación

### 8. Analizar Resultados

Una vez completada la simulación:

1. Acceder a "Resultados de Simulación"
2. Seleccionar la simulación ejecutada
3. Explorar las diferentes pestañas:

**Pestaña Económica**

**Pestaña Energética**

**Pestaña Activos**

**Tablas Comparativas**

**Gráficos**


**Trabajo de Fin de Grado - Desarrollo de una Aplicación Visual para Simular una Comunidad Energética** 