# Auth Service

Serviço de Autenticação e Autorização da plataforma Distrischool.

## Funcionalidades

- **Cadastro de Usuários**: Registro com validação de email
- **Login/Logout**: Autenticação via JWT
- **Recuperação de Senha**: Processo completo de reset de senha via email
- **Verificação de Email**: Confirmação de email via token
- **Gerenciamento de Perfis**: Suporte para roles (STUDENT, TEACHER, ADMIN, PARENT)
- **Auditoria**: Publicação de eventos no Kafka para auditoria de login

## Tecnologias

- Spring Boot 3.5.6
- Spring Security com JWT
- Spring Data JPA
- PostgreSQL
- Apache Kafka
- JavaMailSender
- BCrypt para hash de senhas

## Rotas

### Públicas (sem autenticação)

- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Fazer login
- `GET /api/auth/verify-email?token={token}` - Verificar email
- `POST /api/auth/password-reset?email={email}` - Solicitar reset de senha
- `POST /api/auth/reset-password?token={token}&newPassword={password}` - Resetar senha

### Protegidas (requerem JWT)

- `GET /api/users` - Listar todos os usuários
- `GET /api/users/{id}` - Buscar usuário por ID
- `DELETE /api/users/{id}` - Deletar usuário

## Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` com:

```env
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/distrischool
SPRING_DATASOURCE_USERNAME=admin
SPRING_DATASOURCE_PASSWORD=admin
KAFKA_BOOTSTRAP_SERVERS=kafka:9092
JWT_SECRET=mySecretKeyForAuthService123456789
JWT_EXPIRATION=86400000
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-password
```

### Executar Localmente

```bash
# Com Maven
./mvnw spring-boot:run

# Com Docker
docker build -t auth-service .
docker run -p 8085:8080 --env-file .env auth-service
```

### Executar com Docker Compose

```bash
cd infra/docker
docker-compose up auth-service
```

## Fluxo de Autenticação

1. **Registro**: 
   - Usuário envia dados para `/api/auth/register`
   - Sistema cria usuário com `enabled=false`
   - Email de verificação é enviado

2. **Verificação**:
   - Usuário clica no link do email
   - Sistema verifica token e ativa usuário (`enabled=true`)

3. **Login**:
   - Usuário envia credenciais para `/api/auth/login`
   - Sistema valida e retorna JWT
   - Evento `user.logged` é publicado no Kafka

4. **Acesso Protegido**:
   - Cliente inclui JWT no header: `Authorization: Bearer {token}`
   - Filtro JWT valida token e autoriza acesso

## Roles e Permissões

- `ROLE_STUDENT`: Alunos
- `ROLE_TEACHER`: Professores
- `ROLE_ADMIN`: Administradores
- `ROLE_PARENT`: Pais/Responsáveis

## Eventos Kafka

### Publicados

- **user.logged**: Disparado após login bem-sucedido
  ```json
  {
    "email": "user@example.com",
    "timestamp": 1730000000000,
    "eventType": "user.logged"
  }
  ```

## Testes

Execute os testes com:

```bash
./mvnw test
```

## Health Check

- Endpoint: `http://localhost:8085/actuator/health`
- Gateway: `http://localhost:8080/services/auth/actuator/health`

## Postman Collection

Importe o arquivo `Auth-Service-API.postman_collection.json` no Postman para testar a API.

## Segurança

- Senhas armazenadas com BCrypt (strength 10)
- JWT com assinatura HS256
- Tokens de verificação/reset expiram em 24h/1h
- CORS configurado no Gateway
- Session Management: STATELESS

## Troubleshooting

### Email não está sendo enviado

Verifique as configurações SMTP no `.env` e habilite "acesso de apps menos seguros" no Gmail.

### Token JWT inválido

- Verifique se o `JWT_SECRET` é o mesmo em todas as instâncias
- Confirme que o token não expirou (24h padrão)

### Usuário não consegue logar

- Verifique se o email foi verificado (`enabled=true`)
- Confirme que a senha está correta