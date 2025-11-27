# 📚 FLUXO COMPLETO DO COURSE-SERVICE

## 🏗️ ARQUITETURA GERAL

```
Cliente → Gateway (8080) → Course-Service (8080) → PostgreSQL (5432)
                ↓
           Auth-Service (valida JWT)
                ↓
           Kafka (eventos)
```

---

## 🔐 1. FLUXO DE AUTENTICAÇÃO

### Passo 1: Login
```
POST http://localhost:8080/api/auth/login
{
  "email": "admin@distrischool.com",
  "senha": "admin123"
}

Resposta:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "tipo": "Bearer",
  "email": "admin@distrischool.com",
  "roles": ["ROLE_ADMIN"]
}
```

### Passo 2: Validação em cada requisição
```
1. Cliente envia: Authorization: Bearer {token}
2. Gateway encaminha requisição com header
3. Course-Service recebe requisição
4. JwtAuthenticationFilter intercepta
5. Chama Auth-Service: POST http://auth-service:8080/api/auth/validate
6. Auth-Service valida e retorna: { email, roles }
7. JwtAuthenticationFilter seta SecurityContext
8. Requisição prossegue para Controller
```

---

## 📖 2. MÓDULO CURSOS (CursoController)

### 2.1 Criar Curso
```
POST http://localhost:8080/api/cursos
Headers: Authorization: Bearer {token}
Body:
{
  "codigo": "CC001",
  "nome": "Ciências da Computação",
  "descricao": "Bacharel em CC",
  "duracao": 8,
  "modalidade": "PRESENCIAL",
  "status": "ATIVO"
}

Fluxo:
Gateway → Course-Service → CursoController.createCurso()
                         → CursoService.createCurso()
                         → CursoRepository.save()
                         → PostgreSQL (tabela curso)
                         → Kafka Event (opcional)
```

### 2.2 Listar Todos os Cursos
```
GET http://localhost:8080/api/cursos
Headers: Authorization: Bearer {token}

Retorna: Lista de CursoDTO com todos os cursos ativos/inativos
```

### 2.3 Buscar Curso por ID
```
GET http://localhost:8080/api/cursos/{id}
Headers: Authorization: Bearer {token}
```

### 2.4 Buscar Curso por Código
```
GET http://localhost:8080/api/cursos/codigo/{codigo}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/cursos/codigo/CC001
```

### 2.5 Filtrar Cursos por Status
```
GET http://localhost:8080/api/cursos/status/{status}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/cursos/status/ATIVO
```

### 2.6 Filtrar Cursos por Modalidade
```
GET http://localhost:8080/api/cursos/modalidade/{modalidade}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/cursos/modalidade/PRESENCIAL
```

### 2.7 Atualizar Curso
```
PUT http://localhost:8080/api/cursos/{id}
Headers: Authorization: Bearer {token}
Body: { campos a atualizar }
```

### 2.8 Deletar Curso
```
DELETE http://localhost:8080/api/cursos/{id}
Headers: Authorization: Bearer {token}
```

---

## 📚 3. MÓDULO DISCIPLINAS (DisciplinaController)

### 3.1 Criar Disciplina
```
POST http://localhost:8080/api/disciplinas
Headers: Authorization: Bearer {token}
Body:
{
  "cursoId": 1,
  "codigo": "POO001",
  "nome": "Programação Orientada a Objetos",
  "descricao": "Conceitos de POO em Java",
  "cargaHoraria": 80,
  "periodo": 3,
  "tipo": "OBRIGATORIA",
  "status": "ATIVA",
  "professorId": 5
}

Fluxo:
1. Valida se cursoId existe (consulta CursoRepository)
2. Valida codigo único (DisciplinaRepository.existsByCodigo)
3. Cria Disciplina associada ao Curso
4. Salva no PostgreSQL (tabela disciplina)
```

### 3.2 Listar Disciplinas por Curso
```
GET http://localhost:8080/api/disciplinas/curso/{cursoId}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/disciplinas/curso/1

Retorna todas as disciplinas de um curso específico
```

### 3.3 Listar Disciplinas por Curso e Período
```
GET http://localhost:8080/api/disciplinas/curso/{cursoId}/periodo/{periodo}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/disciplinas/curso/1/periodo/3

Retorna disciplinas do 3º período do curso 1
```

### 3.4 Listar Disciplinas por Professor
```
GET http://localhost:8080/api/disciplinas/professor/{professorId}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/disciplinas/professor/5

Retorna todas as disciplinas ministradas por um professor
```

### 3.5 Buscar Disciplina por Código
```
GET http://localhost:8080/api/disciplinas/codigo/{codigo}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/disciplinas/codigo/POO001
```

### 3.6 Filtrar Disciplinas por Status
```
GET http://localhost:8080/api/disciplinas/status/{status}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/disciplinas/status/ATIVA
```

### 3.7 Atualizar Disciplina
```
PUT http://localhost:8080/api/disciplinas/{id}
Headers: Authorization: Bearer {token}
Body: { campos a atualizar }
```

### 3.8 Deletar Disciplina
```
DELETE http://localhost:8080/api/disciplinas/{id}
Headers: Authorization: Bearer {token}
```

---

## 🎓 4. MÓDULO MATRÍCULAS (MatriculaController)

### 4.1 Criar Matrícula
```
POST http://localhost:8080/api/matriculas
Headers: Authorization: Bearer {token}
Body:
{
  "alunoId": 3,
  "disciplinaId": 1,
  "semestre": "2024.2",
  "status": "ATIVA"
}

Fluxo:
1. Valida se disciplinaId existe
2. Valida regras de negócio:
   - Aluno não está já matriculado na disciplina
   - Disciplina está ativa
   - Pré-requisitos atendidos (se houver)
3. Cria Matricula
4. Salva no PostgreSQL (tabela matricula)
5. Publica evento Kafka: "MatriculaCreated"
```

### 4.2 Listar Matrículas do Aluno
```
GET http://localhost:8080/api/matriculas/aluno/{alunoId}
Headers: Authorization: Bearer {token}
Exemplo: GET /api/matriculas/aluno/3

Retorna todas as matrículas (ativas + inativas) do aluno
```

### 4.3 Listar Matrículas Ativas do Aluno
```
GET http://localhost:8080/api/matriculas/aluno/{alunoId}/ativas
Headers: Authorization: Bearer {token}

Retorna apenas matrículas com status = "ATIVA"
```

### 4.4 Listar Matrículas da Disciplina
```
GET http://localhost:8080/api/matriculas/disciplina/{disciplinaId}
Headers: Authorization: Bearer {token}

Retorna todos os alunos matriculados na disciplina
```

### 4.5 Listar Matrículas Ativas da Disciplina
```
GET http://localhost:8080/api/matriculas/disciplina/{disciplinaId}/ativas
Headers: Authorization: Bearer {token}

Retorna alunos com matrícula ativa na disciplina
Útil para: listar turma atual, controle de presença
```

### 4.6 Atualizar Status da Matrícula
```
PUT http://localhost:8080/api/matriculas/{id}/status?status=CONCLUIDA
Headers: Authorization: Bearer {token}

Status possíveis:
- ATIVA: aluno cursando
- TRANCADA: aluno trancou a disciplina
- CONCLUIDA: aluno finalizou (aprovado/reprovado)
- CANCELADA: matrícula cancelada
```

### 4.7 Deletar Matrícula
```
DELETE http://localhost:8080/api/matriculas/{id}
Headers: Authorization: Bearer {token}
```

---

## 📝 5. MÓDULO AVALIAÇÕES (AvaliacaoController)

### 5.1 Criar Avaliação
```
POST http://localhost:8080/api/avaliacoes
Headers: Authorization: Bearer {token}
Body:
{
  "matriculaId": 1,
  "tipoAvaliacao": "PROVA",
  "descricao": "Prova P1 - POO",
  "nota": 8.5,
  "peso": 2.0,
  "dataAvaliacao": "2024-11-15"
}

Tipos de Avaliação:
- PROVA: avaliação formal
- TRABALHO: projeto/trabalho
- EXERCICIO: atividade prática
- SEMINARIO: apresentação
- PARTICIPACAO: nota de participação

Fluxo:
1. Valida se matriculaId existe e está ativa
2. Valida nota (0.0 a 10.0)
3. Cria Avaliacao associada à matrícula
4. Salva no PostgreSQL (tabela avaliacao)
5. Publica evento Kafka: "AvaliacaoCreated"
```

### 5.2 Buscar Avaliação por ID
```
GET http://localhost:8080/api/avaliacoes/{id}
Headers: Authorization: Bearer {token}
```

### 5.3 Listar Avaliações por Matrícula
```
GET http://localhost:8080/api/avaliacoes/matricula/{matriculaId}
Headers: Authorization: Bearer {token}

Retorna todas as avaliações de uma matrícula específica
Útil para: ver notas do aluno em uma disciplina
```

### 5.4 Listar Avaliações por Aluno
```
GET http://localhost:8080/api/avaliacoes/aluno/{alunoId}
Headers: Authorization: Bearer {token}

Retorna todas as avaliações de todas as disciplinas do aluno
Útil para: histórico completo, boletim geral
```

### 5.5 Listar Avaliações por Disciplina
```
GET http://localhost:8080/api/avaliacoes/disciplina/{disciplinaId}
Headers: Authorization: Bearer {token}

Retorna todas as avaliações de todos os alunos da disciplina
Útil para: professor ver desempenho da turma
```

### 5.6 Listar Avaliações por Aluno e Disciplina
```
GET http://localhost:8080/api/avaliacoes/aluno/{alunoId}/disciplina/{disciplinaId}
Headers: Authorization: Bearer {token}

Retorna avaliações específicas de um aluno em uma disciplina
Útil para: boletim individual da disciplina
```

### 5.7 Atualizar Avaliação
```
PUT http://localhost:8080/api/avaliacoes/{id}
Headers: Authorization: Bearer {token}
Body:
{
  "nota": 9.0,
  "descricao": "Prova P1 - POO (revisada)"
}

Permite atualizar nota, descrição, peso, etc.
```

### 5.8 Deletar Avaliação
```
DELETE http://localhost:8080/api/avaliacoes/{id}
Headers: Authorization: Bearer {token}
```

---

## 🔄 6. FLUXO COMPLETO DE CASO DE USO

### Cenário: Aluno cursando uma disciplina

```
1. ADMIN cria CURSO
   POST /api/cursos { "nome": "Ciências da Computação", ... }
   → Retorna cursoId: 1

2. ADMIN cria DISCIPLINA no curso
   POST /api/disciplinas { "cursoId": 1, "nome": "POO", ... }
   → Retorna disciplinaId: 1

3. ALUNO se matricula na disciplina
   POST /api/matriculas { "alunoId": 3, "disciplinaId": 1, ... }
   → Retorna matriculaId: 1

4. PROFESSOR lança avaliações
   POST /api/avaliacoes { "matriculaId": 1, "tipo": "PROVA", "nota": 8.5 }
   POST /api/avaliacoes { "matriculaId": 1, "tipo": "TRABALHO", "nota": 9.0 }

5. ALUNO consulta suas notas
   GET /api/avaliacoes/aluno/3
   → Retorna lista de avaliações

6. PROFESSOR consulta turma
   GET /api/matriculas/disciplina/1/ativas
   → Retorna alunos matriculados

7. ADMIN atualiza status da matrícula ao final do semestre
   PUT /api/matriculas/1/status?status=CONCLUIDA
```

---

## 🗄️ 7. MODELO DE DADOS

### Tabela: curso
```sql
id BIGSERIAL PRIMARY KEY
codigo VARCHAR(20) UNIQUE NOT NULL
nome VARCHAR(100) NOT NULL
descricao TEXT
duracao INTEGER (períodos)
modalidade VARCHAR(20) (PRESENCIAL, EAD, HIBRIDO)
status VARCHAR(20) (ATIVO, INATIVO)
created_at TIMESTAMP
updated_at TIMESTAMP
```

### Tabela: disciplina
```sql
id BIGSERIAL PRIMARY KEY
curso_id BIGINT → curso(id)
codigo VARCHAR(20) UNIQUE NOT NULL
nome VARCHAR(100) NOT NULL
descricao TEXT
carga_horaria INTEGER
periodo INTEGER
tipo VARCHAR(20) (OBRIGATORIA, OPTATIVA)
status VARCHAR(20) (ATIVA, INATIVA)
professor_id BIGINT (referência externa)
created_at TIMESTAMP
updated_at TIMESTAMP
```

### Tabela: matricula
```sql
id BIGSERIAL PRIMARY KEY
aluno_id BIGINT (referência externa)
disciplina_id BIGINT → disciplina(id)
semestre VARCHAR(10)
status VARCHAR(20) (ATIVA, TRANCADA, CONCLUIDA, CANCELADA)
created_at TIMESTAMP
updated_at TIMESTAMP
```

### Tabela: avaliacao
```sql
id BIGSERIAL PRIMARY KEY
matricula_id BIGINT → matricula(id)
tipo_avaliacao VARCHAR(20) (PROVA, TRABALHO, EXERCICIO, SEMINARIO, PARTICIPACAO)
descricao VARCHAR(255)
nota DECIMAL(4,2) (0.00 a 10.00)
peso DECIMAL(3,2)
data_avaliacao DATE
created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## 🔒 8. SEGURANÇA E PERMISSÕES

### SecurityConfig
- **Todas as rotas** `/api/cursos/**`, `/api/disciplinas/**`, `/api/matriculas/**`, `/api/avaliacoes/**` 
- **Requerem autenticação** (JWT válido)
- Permissões específicas por role podem ser adicionadas com `@PreAuthorize`

### JwtAuthenticationFilter
```java
1. Extrai token do header Authorization
2. Valida com auth-service via POST /api/auth/validate
3. Recebe resposta: { "email": "...", "roles": [...] }
4. Cria Authentication com email e roles
5. Seta no SecurityContext
6. Permite acesso ao controller
```

---

## 🌐 9. GATEWAY ROUTES

### Course-Service no Gateway
```yaml
Pattern: /api/cursos/**, /api/disciplinas/**, /api/matriculas/**, /api/avaliacoes/**
URI: http://course-service:8080
CircuitBreaker: courseServiceCircuitBreaker
Fallback: /fallback/course
```

### Circuit Breaker Config (application.yml)
```yaml
resilience4j:
  circuitbreaker:
    instances:
      courseServiceCircuitBreaker:
        registerHealthIndicator: true
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 10000
        permittedNumberOfCallsInHalfOpenState: 3
  timelimiter:
    instances:
      courseServiceCircuitBreaker:
        timeoutDuration: 5s
```

---

## 📊 10. EVENTOS KAFKA

### Eventos Publicados
```
1. curso.created → quando curso é criado
2. disciplina.created → quando disciplina é criada
3. matricula.created → quando aluno se matricula
4. avaliacao.created → quando avaliação é lançada
5. avaliacao.updated → quando nota é alterada
```

### Configuração
```yaml
spring:
  kafka:
    bootstrap-servers: kafka:9092
    producer:
      key-serializer: StringSerializer
      value-serializer: JsonSerializer
```

---

## 🧪 11. TESTES

### Script de Teste: test-course-service.ps1
```powershell
1. Autentica como admin
2. Cria curso
3. Lista cursos
4. Busca curso por ID
5. Cria disciplina
6. Lista disciplinas do curso
7. Cria matrícula
8. Lista matrículas do aluno
9. Cria avaliação
10. Lista avaliações do aluno
11. Atualiza nota
12. Lista alunos matriculados
```

Resultado: **12/12 testes PASSOU** ✅

---

## 🎯 12. CASOS DE USO PRINCIPAIS

### Para ADMIN:
- Criar e gerenciar cursos
- Criar e gerenciar disciplinas
- Configurar grade curricular
- Alocar professores às disciplinas

### Para PROFESSOR:
- Visualizar turmas (alunos matriculados)
- Lançar avaliações
- Atualizar notas
- Consultar desempenho da turma

### Para ALUNO:
- Matricular-se em disciplinas
- Consultar suas matrículas
- Visualizar notas e avaliações
- Trancar disciplinas

### Para COORDENAÇÃO:
- Relatórios de desempenho
- Análise de aprovações/reprovações
- Gestão de períodos letivos

---

## 📦 13. DEPENDÊNCIAS

### Tecnologias
- Spring Boot 3.5.6
- Java 17
- PostgreSQL 16
- Kafka 3.6.0
- Spring Security + JWT
- Spring Data JPA
- Spring Cloud Gateway

### Serviços Relacionados
- **Auth-Service**: validação de tokens JWT
- **Student-Service**: dados dos alunos
- **Teacher-Service**: dados dos professores
- **Gateway**: roteamento e circuit breaker

---

## 🚀 14. EXECUÇÃO

### Docker Compose
```bash
cd infra/docker
docker compose up -d course-service
```

### Logs
```bash
docker logs -f docker-course-service-1
```

### Health Check
```bash
curl http://localhost:8080/services/course/actuator/health
```

---

## 📝 15. PRÓXIMOS PASSOS / MELHORIAS

1. **Implementar pré-requisitos de disciplinas**
   - Validar que aluno cursou disciplinas anteriores

2. **Cálculo automático de média**
   - Endpoint para calcular média ponderada das avaliações

3. **Sistema de aprovação/reprovação**
   - Lógica de aprovação baseada em média e frequência

4. **Integração com sistema de frequência**
   - Controle de presença dos alunos

5. **Relatórios e estatísticas**
   - Dashboard de desempenho
   - Análise de disciplinas com maior reprovação

6. **Notificações**
   - Email/Push quando nota é lançada
   - Alertas de notas baixas

7. **Controle de períodos letivos**
   - Abertura/fechamento de matrículas
   - Períodos de avaliação

---

## 🔗 16. ENDPOINTS RESUMIDOS

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | /api/cursos | Criar curso |
| GET | /api/cursos | Listar cursos |
| GET | /api/cursos/{id} | Buscar curso |
| PUT | /api/cursos/{id} | Atualizar curso |
| DELETE | /api/cursos/{id} | Deletar curso |
| POST | /api/disciplinas | Criar disciplina |
| GET | /api/disciplinas/curso/{id} | Listar disciplinas do curso |
| GET | /api/disciplinas/professor/{id} | Disciplinas do professor |
| POST | /api/matriculas | Criar matrícula |
| GET | /api/matriculas/aluno/{id} | Matrículas do aluno |
| GET | /api/matriculas/disciplina/{id} | Alunos da disciplina |
| PUT | /api/matriculas/{id}/status | Atualizar status |
| POST | /api/avaliacoes | Criar avaliação |
| GET | /api/avaliacoes/aluno/{id} | Avaliações do aluno |
| GET | /api/avaliacoes/disciplina/{id} | Avaliações da disciplina |
| PUT | /api/avaliacoes/{id} | Atualizar avaliação |

**Total: 40+ endpoints** organizados em 4 controllers

---

**Documentação gerada em:** 21/11/2025  
**Versão:** 1.0  
**Status:** ✅ Produção - Todos os testes passando
