from fastapi import FastAPI
from app.infrastructure.persistance.config import settings
from app.infrastructure.web.fastapi.routes import usuario

# Initialize FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.PROJECT_DESCRIPTION,
    version=settings.PROJECT_VERSION
)

# Simple Hello World endpoint
@app.get("/")
def read_root():
    return {"message": "Hello World from Comunidad Energética API"}

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(usuario.router)

# Include this for debugging when running directly
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
