from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_participante import ParticipanteCreate, ParticipanteRead, ParticipanteUpdate
from app.domain.entities.participante import ParticipanteEntity
from app.domain.use_cases.participante.crear_participante import crear_participante_use_case
from app.domain.use_cases.participante.mostrar_participante import mostrar_participante_use_case
from app.domain.use_cases.participante.modificar_participante import modificar_participante_use_case
from app.domain.use_cases.participante.eliminar_participante import eliminar_participante_use_case
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
from typing import List

router = APIRouter(prefix="/participantes", tags=["participantes"])

@router.post("/", response_model=ParticipanteRead)
def crear_participante(participante: ParticipanteCreate, db: Session = Depends(get_db)):
    participante_entity = ParticipanteEntity(
        nombre=participante.nombre,
        idComunidadEnergetica=participante.idComunidadEnergetica
    )
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    participante_repo = SqlAlchemyParticipanteRepository(db)
    nuevo_participante = crear_participante_use_case(participante_entity, comunidad_repo, participante_repo)
    return ParticipanteRead(
        idParticipante=nuevo_participante.idParticipante,
        nombre=nuevo_participante.nombre,
        idComunidadEnergetica=nuevo_participante.idComunidadEnergetica
    )

@router.get("/{id_participante}", response_model=ParticipanteRead)
def obtener_participante(id_participante: int, db: Session = Depends(get_db)):
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = mostrar_participante_use_case(id_participante, participante_repo)
    return ParticipanteRead(
        idParticipante=participante.idParticipante,
        nombre=participante.nombre,
        idComunidadEnergetica=participante.idComunidadEnergetica
    )

@router.get("/comunidad/{id_comunidad}", response_model=List[ParticipanteRead])
def listar_participantes_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participantes = participante_repo.get_by_comunidad(id_comunidad)
    return [
        ParticipanteRead(
            idParticipante=p.idParticipante,
            nombre=p.nombre,
            idComunidadEnergetica=p.idComunidadEnergetica
        ) for p in participantes
    ]

@router.put("/{id_participante}", response_model=ParticipanteRead)
def actualizar_participante(id_participante: int, participante: ParticipanteUpdate, db: Session = Depends(get_db)):
    participante_entity = ParticipanteEntity(nombre=participante.nombre)
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante_actualizado = modificar_participante_use_case(id_participante, participante_entity, participante_repo)
    return ParticipanteRead(
        idParticipante=participante_actualizado.idParticipante,
        nombre=participante_actualizado.nombre,
        idComunidadEnergetica=participante_actualizado.idComunidadEnergetica
    )

@router.delete("/{id_participante}")
def eliminar_participante(id_participante: int, db: Session = Depends(get_db)):
    participante_repo = SqlAlchemyParticipanteRepository(db)
    eliminar_participante_use_case(id_participante, participante_repo)
    return {"mensaje": "Participante eliminado correctamente"}