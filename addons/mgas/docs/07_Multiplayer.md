# Multiplayer & Networking

O MGAS foi desenhado "Network First".

## Replication

Atributos, Tags Ativas e Efeitos são replicados automaticamente do Servidor para os Clientes.

## Prediction

O Cliente pode executar habilidades localmente para responsividade imediata. O Servidor valida e, se houver divergência, o Cliente faz rollback (Correction).

## Owners & Avatars

- **Owner**: Quem possui a habilidade (Controller).
- **Avatar**: A representação física (CharacterBody).
