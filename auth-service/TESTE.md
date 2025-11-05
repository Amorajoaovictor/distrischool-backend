# Guia de Teste - Auth Service

## Pré-requisitos

1. **Docker Desktop rodando**
2. Estar na raiz do projeto `distrischool`

## Passo 1: Iniciar o Docker Desktop

Abra o Docker Desktop e aguarde até que esteja totalmente iniciado.

## Passo 2: Subir as Dependências

```powershell
cd infra\docker
docker-compose up -d postgres zookeeper kafka
```

Aguarde até que todos os containers estejam healthy:
```powershell
docker-compose ps
```

## Passo 3: Subir o Auth Service

```powershell
docker-compose up -d auth-service
```

## Passo 4: Verificar os Logs

```powershell
docker-compose logs -f auth-service
```

Você deve ver:
- ✅ Conexão com PostgreSQL estabelecida
- ✅ Tabelas `users`, `roles`, `user_roles` criadas
- ✅ Roles padrão inseridas (ROLE_STUDENT, ROLE_TEACHER, ROLE_ADMIN, ROLE_PARENT)
- ✅ Aplicação iniciada na porta 8080 (interna)
- ✅ Mensagem: "Started AuthServiceApplication"

## Passo 5: Testar o Health Check

```powershell
curl http://localhost:8085/actuator/health
```

Resposta esperada:
```json
{
  "status": "UP"
}
```

## Passo 6: Testar o Registro

```powershell
curl -X POST http://localhost:8085/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"fullName\":\"João Silva\",\"email\":\"joao.silva@email.com\",\"password\":\"senha123\"}'
```

Resposta esperada:
```json
{
  "id": 1,
  "fullName": "João Silva",
  "email": "joao.silva@email.com",
  "roles": ["ROLE_STUDENT"],
  "enabled": false
}
```

## Passo 7: Verificar no Banco

```powershell
docker-compose exec postgres psql -U admin -d distrischool -c "SELECT id, full_name, email, enabled FROM users;"
```

## Passo 8: Testar Login (vai falhar pois email não verificado)

```powershell
curl -X POST http://localhost:8085/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"joao.silva@email.com\",\"password\":\"senha123\"}'
```

Deve retornar erro 401 porque o usuário não está habilitado.

## Passo 9: Habilitar Usuário Manualmente (para teste)

```powershell
docker-compose exec postgres psql -U admin -d distrischool -c "UPDATE users SET enabled = true WHERE email = 'joao.silva@email.com';"
```

## Passo 10: Testar Login Novamente

```powershell
curl -X POST http://localhost:8085/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"joao.silva@email.com\",\"password\":\"senha123\"}'
```

Resposta esperada:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "id": 1,
  "email": "joao.silva@email.com",
  "fullName": "João Silva",
  "roles": ["ROLE_STUDENT"]
}
```

## Passo 11: Testar Rota Protegida

Copie o token da resposta anterior e use:

```powershell
$token = "SEU_TOKEN_AQUI"
curl http://localhost:8085/api/users `
  -H "Authorization: Bearer $token"
```

Deve retornar lista de usuários.

## Passo 12: Verificar Evento Kafka

```powershell
docker-compose exec kafka kafka-console-consumer `
  --bootstrap-server localhost:9092 `
  --topic user-events `
  --from-beginning
```

Deve mostrar o evento de login.

## Passo 13: Testar via Gateway

```powershell
# Primeiro suba o gateway
docker-compose up -d gateway

# Teste via gateway (porta 8080)
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"joao.silva@email.com\",\"password\":\"senha123\"}'
```

## Troubleshooting

### Container não sobe
```powershell
docker-compose logs auth-service
```

### Erro de conexão com PostgreSQL
```powershell
# Verificar se postgres está rodando
docker-compose ps postgres

# Verificar logs do postgres
docker-compose logs postgres
```

### Erro de build
```powershell
# Forçar rebuild
docker-compose build --no-cache auth-service
docker-compose up -d auth-service
```

### Limpar tudo e recomeçar
```powershell
docker-compose down -v
docker-compose up -d postgres zookeeper kafka
# Aguardar 30 segundos
docker-compose up -d auth-service
```

## Importar no Postman

1. Abra o Postman
2. Import → File → Selecione `auth-service/Auth-Service-API.postman_collection.json`
3. Configure a variável `jwt_token` após fazer login
4. Teste todas as rotas

## Verificações Finais

- [ ] Auth service subiu sem erros
- [ ] Health check retorna UP
- [ ] Registro de usuário funciona
- [ ] Login retorna JWT válido
- [ ] Rotas protegidas funcionam com JWT
- [ ] Evento Kafka é publicado no login
- [ ] Gateway roteia corretamente para auth-service