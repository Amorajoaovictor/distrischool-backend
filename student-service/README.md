# Student Service - Início Rápido 🚀

Sistema de gestão de alunos com criptografia de dados e conformidade LGPD.

## ⚡ Quick Start

### 1. Compilar e Rodar

```bash
# Configurar Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Compilar
./mvnw clean package -DskipTests

# Rodar
java -jar target/student-service-0.0.1-SNAPSHOT.jar
```

### 2. Verificar se está rodando

```bash
curl http://localhost:8080/actuator/health
# Resposta: {"status":"UP"}
```

### 3. Criar um aluno

```bash
curl -X POST http://localhost:8080/api/alunos \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Victor",
    "dataNascimento": "2000-01-15",
    "endereco": "Rua das Flores, 123",
    "contato": "85999999999",
    "matricula": "2024001",
    "turma": "3A",
    "historicoAcademico": "Cursou Matemática e Português"
  }'
```

### 4. Rodar testes automatizados

```bash
./test_api.sh
```

## 📚 Documentação Completa

Veja [TESTING.md](TESTING.md) para documentação completa de todos os endpoints e exemplos.

## 🔧 Configuração

### Banco de Dados

Edite `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://seu-host:5432/seu-banco
    username: seu-usuario
    password: sua-senha
```

Ou crie um arquivo `.env`:

```env
DATABASE_URL=jdbc:postgresql://seu-host:5432/seu-banco
DATABASE_USER=seu-usuario
DATABASE_PASSWORD=sua-senha
```

## 📡 Endpoints Principais

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/alunos` | Criar aluno |
| `GET` | `/api/alunos/{id}` | Buscar por ID |
| `GET` | `/api/alunos/matricula/{matricula}` | Buscar por matrícula |
| `PUT` | `/api/alunos/{id}` | Editar aluno |
| `DELETE` | `/api/alunos/{id}` | Excluir aluno |

## 🔐 Segurança

- **Criptografia AES**: Histórico acadêmico é criptografado automaticamente
- **LGPD**: Dados sensíveis protegidos
- **Validação**: Todos os campos obrigatórios são validados

## 🐛 Troubleshooting

### Porta 8080 ocupada?

```bash
# Matar processo na porta 8080
lsof -ti:8080 | xargs kill -9
```

### Ver logs

```bash
# Se rodou em background
tail -f app.log

# Ver erros
grep -i error app.log
```

### Parar aplicação

```bash
pkill -f "student-service-0.0.1-SNAPSHOT.jar"
```

## 📝 Exemplos de Uso

### Buscar aluno por matrícula

```bash
curl http://localhost:8080/api/alunos/matricula/2024001
```

### Buscar alunos por nome

```bash
curl http://localhost:8080/api/alunos/nome/João
```

### Buscar alunos por turma

```bash
curl http://localhost:8080/api/alunos/turma/3A
```

### Editar aluno

```bash
curl -X PUT http://localhost:8080/api/alunos/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Victor Atualizado",
    "dataNascimento": "2000-01-15",
    "endereco": "Rua Nova, 456",
    "contato": "85988888888",
    "matricula": "2024001",
    "turma": "3B",
    "historicoAcademico": "Histórico atualizado"
  }'
```

### Excluir aluno

```bash
curl -X DELETE http://localhost:8080/api/alunos/1
```

## 📦 Tecnologias

- **Java 17**
- **Spring Boot 3.5.6**
- **Spring Data JPA**
- **PostgreSQL**
- **Hibernate**
- **Maven**

## 🧪 Testes

```bash
# Rodar testes unitários
./mvnw test

# Rodar testes de integração
./test_api.sh
```

## 📞 Suporte

Para documentação completa, veja [TESTING.md](TESTING.md).

---

**Desenvolvido para DistriSchool** | Última atualização: 13/10/2025
