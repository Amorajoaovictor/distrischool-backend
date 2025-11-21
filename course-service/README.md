# Course Service

Serviço responsável pelo gerenciamento de cursos e disciplinas do sistema Distrischool.

## Entidades

### Curso
Representa cursos acadêmicos como:
- Ciências da Computação
- Direito
- Medicina
- Engenharia

**Campos:**
- `id`: Identificador único
- `nome`: Nome do curso
- `codigo`: Código único do curso
- `descricao`: Descrição detalhada
- `duracaoSemestres`: Duração do curso em semestres
- `modalidade`: Presencial, EAD, Híbrido
- `turno`: Matutino, Vespertino, Noturno, Integral
- `status`: ATIVO, INATIVO

### Disciplina
Representa disciplinas como:
- Matemática Discreta
- Programação Orientada a Objetos (POO)
- Cálculo Numérico e Análise (CANA)

**Campos:**
- `id`: Identificador único
- `nome`: Nome da disciplina
- `codigo`: Código único da disciplina
- `descricao`: Descrição detalhada
- `cargaHoraria`: Carga horária em horas
- `creditos`: Número de créditos
- `cursoId`: ID do curso ao qual pertence
- `professorId`: ID do professor responsável (opcional)
- `periodo`: Semestre/período em que é oferecida
- `tipo`: OBRIGATORIA, OPTATIVA, ELETIVA
- `status`: ATIVA, INATIVA

## Endpoints

### Cursos

- `POST /api/cursos` - Criar novo curso
- `GET /api/cursos` - Listar todos os cursos
- `GET /api/cursos/{id}` - Buscar curso por ID
- `GET /api/cursos/codigo/{codigo}` - Buscar curso por código
- `GET /api/cursos/status/{status}` - Listar cursos por status
- `GET /api/cursos/modalidade/{modalidade}` - Listar cursos por modalidade
- `PUT /api/cursos/{id}` - Atualizar curso
- `DELETE /api/cursos/{id}` - Deletar curso

### Disciplinas

- `POST /api/disciplinas` - Criar nova disciplina
- `GET /api/disciplinas` - Listar todas as disciplinas
- `GET /api/disciplinas/{id}` - Buscar disciplina por ID
- `GET /api/disciplinas/codigo/{codigo}` - Buscar disciplina por código
- `GET /api/disciplinas/curso/{cursoId}` - Listar disciplinas de um curso
- `GET /api/disciplinas/status/{status}` - Listar disciplinas por status
- `GET /api/disciplinas/curso/{cursoId}/periodo/{periodo}` - Listar disciplinas por curso e período
- `GET /api/disciplinas/professor/{professorId}` - Listar disciplinas de um professor
- `PUT /api/disciplinas/{id}` - Atualizar disciplina
- `DELETE /api/disciplinas/{id}` - Deletar disciplina

## Configuração

O serviço roda na porta `8085` por padrão.

### Requisitos
- Java 17
- PostgreSQL
- Kafka

### Executar

```bash
mvn spring-boot:run
```

### Docker

```bash
docker build -t course-service .
docker run -p 8085:8085 course-service
```
