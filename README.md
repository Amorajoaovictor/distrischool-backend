# DistriSchool

Sistema distribuído de gerenciamento escolar utilizando arquitetura de microserviços.

## 🏗️ Arquitetura

O sistema é composto por 4 microserviços principais e infraestrutura de suporte:

### Microserviços
- **user-service** - Gerenciamento de usuários (porta 8081)
- **student-service** - Gerenciamento de alunos (porta 8082)
- **teacher-service** - Gerenciamento de professores (porta 8083)
- **admin-staff-service** - Gerenciamento de staff administrativo (porta 8084)

### Infraestrutura
- **PostgreSQL** - Banco de dados relacional (porta 5432)
- **Kafka** - Message broker para comunicação assíncrona (porta 9092)
- **Zookeeper** - Coordenação de serviços distribuídos (porta 2181)

## 🚀 Como executar

### Pré-requisitos
- Docker
- Docker Compose

### Subindo todos os serviços

```bash
cd infra/docker
docker-compose up -d --build
```

### Verificar status dos containers

```bash
docker ps
```

### Ver logs de um serviço específico

```bash
docker-compose logs -f user-service
docker-compose logs -f student-service
docker-compose logs -f teacher-service
docker-compose logs -f admin-staff-service
```

### Parar todos os serviços

```bash
docker-compose down
```

### Parar e remover volumes (limpar dados)

```bash
docker-compose down -v
```

### Kubernetes

### Pré-requisitos para Kubernetes
- kubectl (cliente Kubernetes)
- kind (para cluster local) ou minikube

### Criar cluster local

```bash
kind create cluster --name distrischool
```

Ou, para criar um cluster local usando o Minikube:

```bash
minikube start --profile distrischool
```

#### Deploy dos serviços

Use o script de deploy:

```bash
./deploy-k8s.sh
```

Ou aplique manualmente os manifestos:

```bash
kubectl apply -f infra/k8s/
```

#### Verificar status dos pods e serviços

```bash
kubectl get all -n distrischool
```

#### Acessar serviços (port-forward)

Como os serviços são ClusterIP, use port-forward para acessar localmente:

```bash
kubectl port-forward svc/user-service-svc 8081:80 -n distrischool &
kubectl port-forward svc/student-service-svc 8082:80 -n distrischool &
kubectl port-forward svc/teacher-service-svc 8083:80 -n distrischool &
kubectl port-forward svc/admin-staff-service-svc 8084:80 -n distrischool &
```

#### Parar e limpar cluster

```bash
kubectl delete -f infra/k8s/
kind delete cluster --name distrischool
```

## 🔧 Configuração

### Variáveis de Ambiente

Cada microserviço utiliza as seguintes variáveis de ambiente:

- `SPRING_DATASOURCE_URL` - URL de conexão com o PostgreSQL
- `SPRING_DATASOURCE_USERNAME` - Usuário do banco (padrão: admin)
- `SPRING_DATASOURCE_PASSWORD` - Senha do banco (padrão: admin)
- `PORT` - Porta interna do serviço (padrão: 8080)

### Portas Expostas

| Serviço | Porta Host | Porta Container |
|---------|------------|-----------------|
| PostgreSQL | 5432 | 5432 |
| Zookeeper | 2181 | 2181 |
| Kafka | 9092 | 9092 |
| user-service | 8081 | 8080 |
| student-service | 8082 | 8080 |
| teacher-service | 8083 | 8080 |
| admin-staff-service | 8084 | 8080 |

## 📝 Endpoints de Health Check

Cada serviço Spring Boot expõe endpoints de monitoramento:

- `http://localhost:8081/actuator/health` - User Service
- `http://localhost:8082/actuator/health` - Student Service
- `http://localhost:8083/actuator/health` - Teacher Service
- `http://localhost:8084/actuator/health` - Admin Staff Service

**Nota para Kubernetes**: Execute os comandos de port-forward antes de acessar os endpoints.

## 🛠️ Desenvolvimento

### Construir apenas um serviço específico

```bash
cd infra/docker
docker-compose build user-service
docker-compose up -d user-service
```

### Acessar logs em tempo real

```bash
docker-compose logs -f --tail=100
```

### Reconstruir após mudanças no código

```bash
docker-compose up -d --build <nome-do-serviço>
```

## 🐛 Troubleshooting

### Containers não iniciam

```bash
# Verificar logs de erro
docker-compose logs

# Verificar containers parados
docker ps -a

# Limpar tudo e recomeçar
docker-compose down -v
docker-compose up -d --build
```

### Problema de conexão com o banco

Aguarde o PostgreSQL ficar saudável antes que os serviços tentem conectar. O docker-compose já está configurado com health check.

### Porta já em uso

Se alguma porta já estiver em uso, edite o arquivo `infra/docker/docker-compose.yml` e altere a porta do host (primeira porta no mapeamento).

## 📦 Stack Tecnológica

- **Java 17** - Linguagem de programação
- **Spring Boot 3.5.6** - Framework para microserviços
- **PostgreSQL 16** - Banco de dados
- **Apache Kafka** - Message streaming
- **Docker & Docker Compose** - Containerização
- **Kubernetes** - Orquestração de containers
- **Maven** - Gerenciamento de dependências

## 🏗️ Estrutura do Projeto

```

## 📡 Monitoring (Prometheus)

This project includes a Prometheus configuration to scrape Spring Boot Actuator endpoints at `/actuator/prometheus`.

To run Prometheus with the Docker Compose setup:

```powershell
cd infra/docker
docker compose up -d prometheus
```

Open Prometheus at: http://localhost:9090

Open Grafana at: http://localhost:3001 (Grafana uses host port 3001 by default to avoid a conflict with the frontend running on 3000)

The default scrape targets are configured in `infra/docker/prometheus/prometheus.yml` and include all microservices and the gateway. Ensure each service exposes `/actuator/prometheus`. If you added dependencies and configuration to enable the Prometheus endpoint, rebuild the related service images and restart the stack.

If you are running in Kubernetes, apply the Prometheus manifests under `infra/k8s`:

```bash
kubectl apply -f infra/k8s/prometheus-configmap.yaml
kubectl apply -f infra/k8s/prometheus-deployment.yaml
```

Note: Prometheus scrapes `gateway:8080` and other service names within the Docker overlay network; if you need host ports or different service discovery, adjust `prometheus.yml` accordingly.

### Kafka exporter (optional)
Prometheus doesn't scrape Kafka broker HTTP metrics directly — you need a Kafka exporter (JMX exporter or a dedicated Kafka exporter) to expose broker metrics at an HTTP `/metrics` endpoint. The docker-compose file includes a commented template for a `kafka-exporter` service; to enable it:

1. Uncomment the `kafka-exporter` block in `infra/docker/docker-compose.yml` and replace the `image` with a supported exporter image (e.g., `banzaicloud/kafka-exporter` or `danielqsj/kafka_exporter`) depending on your environment.
2. Update `infra/docker/prometheus/prometheus.yml` (or `infra/k8s/prometheus-configmap.yaml` for Kubernetes) to point to that exporter job (the compose `prometheus.yml` includes `kafka-exporter` job already).
3. Run `docker compose up -d --build` to bring up the exporter and Prometheus.

Note: By default the Kafka exporter entry is commented out to avoid failing `docker-compose` when the exporter image isn't available.

### Internal Actuator metrics
Prometheus scrapes `/actuator/prometheus` within the internal Docker network. For security, these endpoints remain protected from public access. We intentionally skip JWT validation for the `GET /actuator/prometheus` path inside service filters so Prometheus can scrape metrics without a token. If you prefer to require auth for `/actuator/prometheus`, configure Prometheus to use credentials and secure them appropriately (Kubernetes Secrets or a vault) or expose an internal-only ingress.

distrischool/
├── admin-staff-service/     # Microserviço de staff administrativo
├── student-service/          # Microserviço de alunos
├── teacher-service/          # Microserviço de professores
├── user-service/             # Microserviço de usuários
├── deploy-k8s.sh             # Script de deploy Kubernetes
├── infra/
│   ├── docker/
│   │   └── docker-compose.yml  # Orquestração dos containers
│   └── k8s/                    # Manifestos Kubernetes
└── docs/                       # Documentação
```

## 📄 Licença

Repositório: [https://github.com/unifor-online/distrischool](https://github.com/unifor-online/distrischool)

Este projeto é parte de um trabalho acadêmico da UNIFOR.
