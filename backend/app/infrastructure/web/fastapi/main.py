from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
import logging
from app.infrastructure.persistance.config import settings
from app.infrastructure.web.fastapi.routes import comunidad_energetica_routes
from app.infrastructure.web.fastapi.routes import usuario_routes
from app.infrastructure.web.fastapi.routes import participante_routes
from app.infrastructure.web.fastapi.routes import contrato_autoconsumo_routes
from app.infrastructure.web.fastapi.routes import activo_generacion_routes
from app.infrastructure.web.fastapi.routes import activo_almacenamiento_routes
from app.infrastructure.web.fastapi.routes import coeficiente_reparto_routes
from app.infrastructure.web.fastapi.routes import registro_consumo_routes
from app.infrastructure.web.fastapi.routes import simulacion_routes
from app.infrastructure.web.fastapi.routes import resultado_simulacion_routes
from app.infrastructure.web.fastapi.routes import datos_ambientales_routes
from app.infrastructure.web.fastapi.routes import resultado_simulacion_activo_almacenamiento_routes
from app.infrastructure.web.fastapi.routes import resultado_simulacion_participante_routes
from app.infrastructure.web.fastapi.routes import resultado_simulacion_activo_generacion_routes
from app.infrastructure.web.fastapi.routes import datos_intervalo_participante_routes
from app.infrastructure.web.fastapi.routes import datos_intervalo_activo_routes
from fastapi.middleware.cors import CORSMiddleware

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.PROJECT_DESCRIPTION,
    version=settings.PROJECT_VERSION
)

# Manejador de errores de validación personalizado
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    # Log detallado del error
    logger.error(f"Error de validación en {request.method} {request.url.path}")
    logger.error(f"Detalles del error: {exc.errors()}")
    logger.error(f"Cuerpo de la solicitud: {await request.body()}")
    
    # Respuesta detallada para el cliente
    return JSONResponse(
        status_code=422,
        content={
            "detail": exc.errors(),
            "body": exc.body if hasattr(exc, 'body') else None,
            "message": "Error de validación en los datos enviados"
        }
    )

# -- CORS middleware --
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple Hello World endpoint
@app.get("/")
def read_root():
    return {"message": "Hello World from Comunidad Energética API"}

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(comunidad_energetica_routes.router)
app.include_router(usuario_routes.router)
app.include_router(participante_routes.router)
app.include_router(contrato_autoconsumo_routes.router)
app.include_router(activo_generacion_routes.router)
app.include_router(activo_almacenamiento_routes.router)
app.include_router(coeficiente_reparto_routes.router)
app.include_router(registro_consumo_routes.router)
app.include_router(simulacion_routes.router)
app.include_router(resultado_simulacion_routes.router)
app.include_router(datos_ambientales_routes.router)
app.include_router(resultado_simulacion_activo_almacenamiento_routes.router)
app.include_router(resultado_simulacion_participante_routes.router)
app.include_router(resultado_simulacion_activo_generacion_routes.router)
app.include_router(datos_intervalo_participante_routes.router)
app.include_router(datos_intervalo_activo_routes.router)

# Include this for debugging when running directly
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
