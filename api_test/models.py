from pydantic import BaseModel


# Modelo usuário
class Usuario(BaseModel):
    nome: str
    senha: str


# Modelo para criação de cliente
class ClienteCreate(BaseModel):
    nome: str
    usuarioId: int


# Modelo para criação de planta
class PlantaCreate(BaseModel):
    nome: str
    especie: str
    clienteId: int
    umidade: int
    luminosidade: int
    temperatura: int
    base64: str


# Modelo para criação de informação da planta
class PlantaInfoCreate(BaseModel):
    luminosidade: int
    temperatura: int
    umidade: int
    data: str
    plantaId: int

# Modelo para ativar planta no módulo desejado
class PlantaAtivar(BaseModel):
    plantaId: int
    moduloId: int
