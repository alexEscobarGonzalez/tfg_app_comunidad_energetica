from dataclasses import dataclass
from datetime import datetime
from typing import Optional

@dataclass
class PvpcPreciosEntity:
    id: int = None
    timestamp: datetime = None
    precio_importacion: float = None  # Precio de compra en €/kWh
    precio_exportacion: float = None  # Precio de venta/compensación en €/kWh 