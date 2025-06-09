import os
from pydantic_settings import BaseSettings  # Importación corregida

class Settings(BaseSettings):
    # API configuration
    PROJECT_NAME: str = "Comunidad Energética API"
    PROJECT_DESCRIPTION: str = "API para gestionar una comunidad energética"
    PROJECT_VERSION: str = "0.1.0"
    
    # Database configuration
    DATABASE_HOSTNAME: str = os.getenv("DATABASE_HOSTNAME", "localhost")
    DATABASE_PORT: str = os.getenv("DATABASE_PORT", "3306")
    DATABASE_PASSWORD: str = os.getenv("DATABASE_PASSWORD", "")
    DATABASE_NAME: str = os.getenv("DATABASE_NAME", "")
    DATABASE_USERNAME: str = os.getenv("DATABASE_USERNAME", "")
    
    # Database URL
    DATABASE_URL: str = f"mysql+pymysql://{DATABASE_USERNAME}:{DATABASE_PASSWORD}@{DATABASE_HOSTNAME}:{DATABASE_PORT}/{DATABASE_NAME}"
    
    class Config:
        env_file = ".env"

# Create instance of settings
settings = Settings()
