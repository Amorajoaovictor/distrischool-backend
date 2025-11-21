# Especificação de Implementação Frontend - Sistema Distrischool

## 📋 Contexto

O backend foi completamente implementado com arquitetura de microserviços e comunicação via Kafka. Este documento especifica TODAS as funcionalidades que devem ser implementadas no frontend para consumir a API e eventos Kafka.

---

## 🏗️ Arquitetura Backend (Implementada)

### Microserviços Disponíveis:
- **Gateway**: http://localhost:8080 (porta única de entrada)
- **Auth Service**: Autenticação JWT
- **Student Service**: Gestão de alunos
- **Teacher Service**: Gestão de professores
- **Admin-Staff Service**: Gestão de administradores
- **Course Service**: Gestão de cursos, disciplinas, matrículas e avaliações
- **Kafka**: Sistema de mensageria para eventos em tempo real

### Endpoints Gateway:
```
Gateway Base URL: http://localhost:8080

Autenticação:
- POST /api/auth/login
- POST /api/auth/register

Alunos:
- GET    /api/alunos
- POST   /api/alunos
- GET    /api/alunos/{id}
- PUT    /api/alunos/{id}
- DELETE /api/alunos/{id}
- GET    /api/alunos/me (perfil do aluno logado)

Professores:
- GET    /api/teachers
- POST   /api/teachers
- GET    /api/teachers/{id}
- PUT    /api/teachers/{id}
- DELETE /api/teachers/{id}

Cursos:
- GET    /api/cursos
- POST   /api/cursos
- GET    /api/cursos/{id}
- PUT    /api/cursos/{id}
- DELETE /api/cursos/{id}

Disciplinas:
- GET    /api/disciplinas
- POST   /api/disciplinas
- GET    /api/disciplinas/{id}
- GET    /api/disciplinas/curso/{cursoId}
- PUT    /api/disciplinas/{id}
- DELETE /api/disciplinas/{id}

Matrículas:
- GET    /api/matriculas
- POST   /api/matriculas
- GET    /api/matriculas/{id}
- GET    /api/matriculas/aluno/{alunoId}
- GET    /api/matriculas/disciplina/{disciplinaId}/ativas
- PUT    /api/matriculas/{id}
- DELETE /api/matriculas/{id}

Avaliações:
- GET    /api/avaliacoes
- POST   /api/avaliacoes
- GET    /api/avaliacoes/{id}
- GET    /api/avaliacoes/aluno/{alunoId}
- GET    /api/avaliacoes/matricula/{matriculaId}
- PUT    /api/avaliacoes/{id}
- DELETE /api/avaliacoes/{id}
```

---

## 🔐 Sistema de Autenticação

### 1. Tela de Login

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "admin@distrischool.com",
  "password": "admin123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "admin@distrischool.com",
  "role": "ADMIN"
}
```

**Implementação Frontend:**
- Armazenar token JWT em localStorage/sessionStorage
- Adicionar token em todas as requisições: `Authorization: Bearer {token}`
- Redirecionar para dashboard baseado na role:
  - `ADMIN` → Dashboard Admin
  - `STUDENT` → Portal do Aluno
  - `TEACHER` → Portal do Professor

### 2. Credenciais de Teste

```
Admin:
- Email: admin@distrischool.com
- Password: admin123

Professor (criado automaticamente ao cadastrar):
- Email: {primeiro}.{ultimo}.{matricula}@unifor.br
- Password: definida no cadastro

Aluno (criado automaticamente ao cadastrar):
- Email: {primeiro}.{ultimo}.{matricula}@unifor.br
- Password: criada automaticamente pelo auth-service
```

---

## 📊 Dashboard Admin

### Funcionalidades Principais:

#### 1. Gestão de Cursos

**Listar Cursos:**
```http
GET /api/cursos
Authorization: Bearer {token}
```

**Criar Curso:**
```http
POST /api/cursos
Authorization: Bearer {token}
Content-Type: application/json

{
  "codigo": "CC2024",
  "nome": "Ciências da Computação",
  "descricao": "Bacharelado em Ciência da Computação",
  "duracaoSemestres": 8,
  "modalidade": "PRESENCIAL",
  "turno": "NOTURNO",
  "status": "ATIVO"
}
```

**Evento Kafka Publicado:**
```json
Topic: course-events
{
  "cursoId": 1,
  "codigo": "CC2024",
  "nome": "Ciências da Computação",
  "eventType": "CREATED",
  "timestamp": 1732176123456
}
```

**UI Necessária:**
- [ ] Tabela listando todos os cursos (código, nome, duração, modalidade, turno, status)
- [ ] Botão "Novo Curso" abrindo modal/formulário
- [ ] Filtros por status (ATIVO/INATIVO)
- [ ] Ações: Editar, Excluir
- [ ] Badge de status colorido

#### 2. Gestão de Disciplinas

**Criar Disciplina:**
```http
POST /api/disciplinas
Authorization: Bearer {token}
Content-Type: application/json

{
  "cursoId": 1,
  "codigo": "POO2024",
  "nome": "Programação Orientada a Objetos",
  "descricao": "Conceitos de POO em Java",
  "cargaHoraria": 80,
  "creditos": 4,
  "periodo": 3,
  "tipo": "OBRIGATORIA",
  "status": "ATIVA",
  "professorId": 1
}
```

**Evento Kafka Publicado:**
```json
Topic: disciplina-events
{
  "disciplinaId": 1,
  "cursoId": 1,
  "professorId": 1,
  "codigo": "POO2024",
  "nome": "Programação Orientada a Objetos",
  "eventType": "CREATED",
  "timestamp": 1732176123456
}
```

**UI Necessária:**
- [ ] Tabela de disciplinas por curso
- [ ] Select para escolher curso
- [ ] Select para atribuir professor
- [ ] Campos: código, nome, descrição, carga horária, créditos, período
- [ ] Radio buttons: tipo (OBRIGATORIA/OPTATIVA), status (ATIVA/INATIVA)

#### 3. Gestão de Alunos

**Criar Aluno:**
```http
POST /api/alunos
Authorization: Bearer {token}
Content-Type: application/json

{
  "nome": "João Pedro Santos",
  "dataNascimento": "2000-05-15",
  "endereco": "Rua das Flores, 123",
  "contato": "85988776655",
  "matricula": "ALU2024001",
  "turma": "CC2024.1",
  "cursoId": 1,
  "historicoAcademicoCriptografado": "Histórico inicial"
}
```

**Evento Kafka Publicado:**
```json
Topic: student-events
{
  "studentId": 1,
  "nome": "João Pedro Santos",
  "matricula": "ALU2024001",
  "email": "joao.santos.ALU2024001@unifor.br",
  "eventType": "CREATED",
  "timestamp": 1732176123456
}
```

**Observações Importantes:**
- Email institucional gerado automaticamente: `{primeiro}.{ultimo}.{matricula}@unifor.br`
- Auth-service cria credenciais automaticamente (consome evento student-events)
- Histórico acadêmico é criptografado no backend

**UI Necessária:**
- [ ] Formulário de cadastro com validação
- [ ] Select de cursos disponíveis
- [ ] Campo de matrícula (gerado automaticamente se vazio)
- [ ] Tabela de alunos com busca por nome/matrícula
- [ ] Filtro por curso/turma

#### 4. Gestão de Professores

**Criar Professor:**
```http
POST /api/teachers
Authorization: Bearer {token}
Content-Type: application/json

{
  "nome": "Prof. Maria Silva",
  "email": "maria.silva@distrischool.com",
  "password": "prof123",
  "matricula": "PROF001",
  "qualificacao": "Mestrado em Ciência da Computação",
  "contato": "85999887766"
}
```

**UI Necessária:**
- [ ] Formulário de cadastro
- [ ] Campo de qualificação (Graduação, Especialização, Mestrado, Doutorado)
- [ ] Tabela de professores
- [ ] Listar disciplinas atribuídas ao professor

#### 5. Gestão de Matrículas

**Matricular Aluno em Disciplina:**
```http
POST /api/matriculas
Authorization: Bearer {token}
Content-Type: application/json

{
  "alunoId": 1,
  "disciplinaId": 1,
  "status": "ATIVA"
}
```

**Evento Kafka Publicado:**
```json
Topic: matricula-events
{
  "matriculaId": 1,
  "alunoId": 1,
  "disciplinaId": 1,
  "status": "ATIVA",
  "eventType": "CREATED",
  "timestamp": 1732176123456
}
```

**UI Necessária:**
- [ ] Interface de matrícula: selecionar aluno + disciplinas disponíveis
- [ ] Checkbox múltiplo para matricular em várias disciplinas
- [ ] Visualização de matrículas ativas por aluno
- [ ] Status: ATIVA, TRANCADA, CONCLUIDA, CANCELADA

---

## 👨‍🏫 Portal do Professor

### Funcionalidades:

#### 1. Minhas Disciplinas

**Endpoint:**
```http
POST /api/teachers/{professorId}/disciplinas/request
Authorization: Bearer {token}
Content-Type: application/json

{
  "professorId": 1,
  "semestre": "2024.1"
}
```

**Kafka Response Topic:** `teacher-disciplinas-responses`

**Response (via Kafka):**
```json
{
  "requestId": "uuid-123",
  "professorId": 1,
  "disciplinas": [
    {
      "disciplinaId": 1,
      "codigo": "POO2024",
      "nome": "Programação Orientada a Objetos",
      "cargaHoraria": 80,
      "totalAlunos": 30
    }
  ]
}
```

**UI Necessária:**
- [ ] Cards das disciplinas atribuídas
- [ ] Total de alunos matriculados por disciplina
- [ ] Botão para acessar detalhes/turma

#### 2. Gerenciar Turmas

**Endpoint:**
```http
POST /api/teachers/{professorId}/turmas/request
Authorization: Bearer {token}
Content-Type: application/json

{
  "professorId": 1,
  "disciplinaId": 1
}
```

**Kafka Response Topic:** `teacher-turmas-responses`

**Response (via Kafka):**
```json
{
  "requestId": "uuid-456",
  "professorId": 1,
  "disciplinaId": 1,
  "turmas": [
    {
      "disciplina": {
        "id": 1,
        "codigo": "POO2024",
        "nome": "Programação Orientada a Objetos"
      },
      "totalAlunos": 30,
      "alunos": [
        {
          "alunoId": 1,
          "nome": "João Pedro Santos",
          "matricula": "ALU2024001",
          "statusMatricula": "ATIVA"
        }
      ]
    }
  ]
}
```

**UI Necessária:**
- [ ] Lista de alunos da turma
- [ ] Busca por nome/matrícula
- [ ] Status da matrícula (badge colorido)
- [ ] Botão para lançar avaliações

#### 3. Lançar Avaliações

**Criar Avaliação:**
```http
POST /api/avaliacoes
Authorization: Bearer {token}
Content-Type: application/json

{
  "matriculaId": 1,
  "tipoAvaliacao": "PROVA",
  "nota": 8.5,
  "peso": 0.4,
  "observacoes": "Boa prova, demonstrou conhecimento",
  "dataAvaliacao": "2024-11-21T10:30:00"
}
```

**Evento Kafka Publicado:**
```json
Topic: avaliacao-events
{
  "avaliacaoId": 1,
  "matriculaId": 1,
  "alunoId": 1,
  "disciplinaId": 1,
  "tipoAvaliacao": "PROVA",
  "nota": 8.5,
  "eventType": "GRADE_RELEASED",
  "timestamp": 1732176123456
}
```

**UI Necessária:**
- [ ] Formulário de avaliação por aluno
- [ ] Select tipo: PROVA, TRABALHO, SEMINARIO, PROJETO
- [ ] Campo nota (0-10) com validação
- [ ] Campo peso (0-1)
- [ ] Campo observações (opcional)
- [ ] Botão salvar que mostra notificação de sucesso

---

## 👨‍🎓 Portal do Aluno

### Funcionalidades:

#### 1. Meu Perfil

**Endpoint:**
```http
GET /api/alunos/me
Authorization: Bearer {token}
```

**Response:**
```json
{
  "id": 1,
  "nome": "João Pedro Santos",
  "dataNascimento": "2000-05-15",
  "matricula": "ALU2024001",
  "turma": "CC2024.1",
  "cursoId": 1,
  "email": "joao.santos.ALU2024001@unifor.br"
}
```

**UI Necessária:**
- [ ] Card com foto (placeholder)
- [ ] Dados pessoais (nome, matrícula, turma, email)
- [ ] Botão editar (alguns campos)

#### 2. Minhas Matrículas

**Endpoint:**
```http
POST /api/alunos/{alunoId}/matriculas/request
Authorization: Bearer {token}
Content-Type: application/json

{
  "alunoId": 1,
  "semestre": "2024.1"
}
```

**Kafka Response Topic:** `student-boletim-responses`

**UI Necessária:**
- [ ] Cards das disciplinas matriculadas
- [ ] Status da matrícula
- [ ] Informações da disciplina (código, nome, professor, carga horária)

#### 3. Boletim / Notas

**Endpoint:**
```http
POST /api/alunos/{alunoId}/boletim/request
Authorization: Bearer {token}
Content-Type: application/json

{
  "alunoId": 1,
  "semestre": "2024.1"
}
```

**Kafka Response Topic:** `student-boletim-responses`

**Response (via Kafka):**
```json
{
  "requestId": "uuid-789",
  "alunoId": 1,
  "boletim": [
    {
      "disciplina": {
        "id": 1,
        "codigo": "POO2024",
        "nome": "Programação Orientada a Objetos"
      },
      "avaliacoes": [
        {
          "id": 1,
          "tipoAvaliacao": "PROVA",
          "nota": 8.5,
          "peso": 0.4,
          "dataAvaliacao": "2024-11-21"
        },
        {
          "id": 2,
          "tipoAvaliacao": "TRABALHO",
          "nota": 9.0,
          "peso": 0.6,
          "dataAvaliacao": "2024-11-28"
        }
      ],
      "mediaFinal": 8.8,
      "status": "APROVADO"
    }
  ]
}
```

**Cálculo de Média:**
```
Média = (Nota1 × Peso1) + (Nota2 × Peso2) + ...
Exemplo: (8.5 × 0.4) + (9.0 × 0.6) = 8.8
```

**UI Necessária:**
- [ ] Tabela de boletim por disciplina
- [ ] Listar avaliações (tipo, nota, peso, data)
- [ ] Mostrar média final calculada
- [ ] Badge de status (APROVADO/REPROVADO)
- [ ] Filtro por semestre

---

## 🔔 Sistema de Notificações em Tempo Real (Kafka)

### Topics Kafka para Frontend Consumir:

#### 1. Notificações para Professor

**Topic:** `disciplina-events`

**Consumir quando:**
- Nova disciplina atribuída ao professor

**Exemplo de Evento:**
```json
{
  "disciplinaId": 1,
  "professorId": 1,
  "nome": "Programação Orientada a Objetos",
  "eventType": "PROFESSOR_ASSIGNED",
  "timestamp": 1732176123456
}
```

**UI:**
- [ ] Toast/Snackbar: "Nova disciplina atribuída: Programação Orientada a Objetos"
- [ ] Badge de notificações não lidas no header
- [ ] Lista de notificações recentes

**Topic:** `matricula-events`

**Consumir quando:**
- Novo aluno se matricula na disciplina do professor

**Exemplo:**
```json
{
  "matriculaId": 1,
  "alunoId": 1,
  "disciplinaId": 1,
  "eventType": "CREATED",
  "timestamp": 1732176123456
}
```

**UI:**
- [ ] Toast: "Novo aluno matriculado em POO2024"

#### 2. Notificações para Aluno

**Topic:** `avaliacao-events`

**Consumir quando:**
- Professor lança uma nota

**Exemplo:**
```json
{
  "avaliacaoId": 1,
  "alunoId": 1,
  "disciplinaId": 1,
  "tipoAvaliacao": "PROVA",
  "nota": 8.5,
  "eventType": "GRADE_RELEASED",
  "timestamp": 1732176123456
}
```

**UI:**
- [ ] Toast: "Nova nota lançada em POO2024: 8.5 (PROVA)"
- [ ] Badge de "nova nota" no menu boletim
- [ ] Push notification (se implementado)

#### 3. Notificações para Admin

**Topic:** `student-events`

**Consumir quando:**
- Novo aluno criado

**UI:**
- [ ] Toast: "Novo aluno cadastrado: João Pedro Santos"

**Topic:** `course-events`

**Consumir quando:**
- Novo curso criado

**UI:**
- [ ] Atualizar lista de cursos automaticamente

### Implementação Kafka no Frontend:

**Biblioteca Recomendada:** `kafkajs` (Node.js) ou WebSocket bridge

**Exemplo de Consumer (via WebSocket Bridge):**
```javascript
const socket = new WebSocket('ws://localhost:8080/kafka-stream');

socket.addEventListener('message', (event) => {
  const kafkaMessage = JSON.parse(event.data);
  
  if (kafkaMessage.topic === 'avaliacao-events') {
    const { alunoId, nota, tipoAvaliacao } = kafkaMessage.payload;
    
    // Mostrar notificação
    showToast(`Nova nota: ${nota} (${tipoAvaliacao})`);
    
    // Atualizar boletim se estiver aberto
    updateBoletim(alunoId);
  }
});
```

---

## 📱 Layouts Sugeridos

### 1. Dashboard Admin

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Distrischool Admin    [Notificações] [Perfil]  │
├─────────────────────────────────────────────────────────┤
│  Sidebar:                   │  Content:                 │
│  • Dashboard                │  ┌──────────────────────┐ │
│  • Cursos                   │  │  Total Cursos: 10    │ │
│  • Disciplinas              │  │  Total Alunos: 250   │ │
│  • Alunos                   │  │  Total Profs: 45     │ │
│  • Professores              │  └──────────────────────┘ │
│  • Matrículas               │                           │
│                             │  [Gráfico de matrículas] │
└─────────────────────────────┴───────────────────────────┘
```

### 2. Portal do Professor

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Portal Professor      [🔔 3] [Prof. Maria]     │
├─────────────────────────────────────────────────────────┤
│  Tabs: [Disciplinas] [Turmas] [Avaliações]             │
│                                                          │
│  Minhas Disciplinas:                                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │ POO2024 - Programação OO    [30 alunos] [Turma] │  │
│  │ ED2024  - Estruturas Dados  [28 alunos] [Turma] │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 3. Portal do Aluno

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Portal do Aluno       [🔔 1] [João Pedro]      │
├─────────────────────────────────────────────────────────┤
│  Tabs: [Perfil] [Matrículas] [Boletim]                 │
│                                                          │
│  Boletim 2024.1:                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ POO2024 - Média: 8.8 ✅ APROVADO                 │  │
│  │   • Prova P1: 8.5 (peso 0.4)                     │  │
│  │   • Trabalho: 9.0 (peso 0.6)                     │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

---

## 🎨 Design System Sugerido

### Cores:
```css
Primary: #1976d2 (Azul)
Secondary: #dc004e (Rosa)
Success: #4caf50 (Verde)
Warning: #ff9800 (Laranja)
Error: #f44336 (Vermelho)
Background: #f5f5f5
```

### Status Colors:
```css
ATIVO/APROVADO: #4caf50
INATIVO/REPROVADO: #f44336
TRANCADA: #ff9800
PENDENTE: #2196f3
```

---

## ✅ Checklist de Implementação

### Autenticação & Rotas Protegidas
- [ ] Tela de login
- [ ] Armazenar JWT em localStorage
- [ ] Interceptor HTTP para adicionar token
- [ ] Redirect baseado em role
- [ ] Logout (limpar token)

### Dashboard Admin
- [ ] Listar/Criar/Editar/Deletar Cursos
- [ ] Listar/Criar/Editar/Deletar Disciplinas
- [ ] Listar/Criar/Editar/Deletar Alunos
- [ ] Listar/Criar/Editar/Deletar Professores
- [ ] Gerenciar Matrículas (matricular aluno em disciplina)
- [ ] Estatísticas (total cursos, alunos, professores)

### Portal Professor
- [ ] Listar minhas disciplinas
- [ ] Ver alunos da turma por disciplina
- [ ] Lançar avaliações (PROVA, TRABALHO, etc.)
- [ ] Receber notificações de novas matrículas

### Portal Aluno
- [ ] Ver meu perfil
- [ ] Listar minhas matrículas
- [ ] Ver boletim com média calculada
- [ ] Receber notificações de novas notas

### Sistema de Notificações Kafka
- [ ] Configurar consumer Kafka (WebSocket bridge)
- [ ] Toast notifications
- [ ] Badge de notificações não lidas
- [ ] Lista de notificações recentes
- [ ] Atualização automática de listas

---

## 🚀 Como Testar o Backend

### 1. Iniciar Serviços:
```bash
cd infra/docker
docker-compose up -d
```

### 2. Executar Teste Completo:
```powershell
cd C:\Users\amora\distrischool
.\test-complete-flow.ps1
```

Este script testa TODO o fluxo:
- ✅ Cria curso
- ✅ Cria aluno inscrito no curso
- ✅ Cria disciplinas com professor
- ✅ Matricula aluno
- ✅ Lança 2 avaliações
- ✅ Calcula média final
- ✅ Publica eventos Kafka

### 3. Endpoints Disponíveis:
- Gateway: http://localhost:8080
- Kafka: localhost:9092

---

## 📚 Referências Técnicas

### Estrutura de DTOs:

**AlunoDTO:**
```typescript
interface AlunoDTO {
  id?: number;
  nome: string;
  dataNascimento: string; // YYYY-MM-DD
  endereco: string;
  contato: string;
  matricula: string;
  turma: string;
  cursoId: number;
  historicoAcademico?: string;
}
```

**CursoDTO:**
```typescript
interface CursoDTO {
  id?: number;
  codigo: string;
  nome: string;
  descricao: string;
  duracaoSemestres: number;
  modalidade: 'PRESENCIAL' | 'EAD' | 'HIBRIDO';
  turno: 'MATUTINO' | 'VESPERTINO' | 'NOTURNO' | 'INTEGRAL';
  status: 'ATIVO' | 'INATIVO';
}
```

**DisciplinaDTO:**
```typescript
interface DisciplinaDTO {
  id?: number;
  cursoId: number;
  codigo: string;
  nome: string;
  descricao: string;
  cargaHoraria: number;
  creditos: number;
  periodo: number;
  tipo: 'OBRIGATORIA' | 'OPTATIVA';
  status: 'ATIVA' | 'INATIVA';
  professorId?: number;
}
```

**MatriculaDTO:**
```typescript
interface MatriculaDTO {
  id?: number;
  alunoId: number;
  disciplinaId: number;
  status: 'ATIVA' | 'TRANCADA' | 'CONCLUIDA' | 'CANCELADA';
}
```

**AvaliacaoDTO:**
```typescript
interface AvaliacaoDTO {
  id?: number;
  matriculaId: number;
  tipoAvaliacao: 'PROVA' | 'TRABALHO' | 'SEMINARIO' | 'PROJETO';
  nota: number; // 0-10
  peso: number; // 0-1
  observacoes?: string;
  dataAvaliacao: string; // ISO 8601
}
```

**TeacherDTO:**
```typescript
interface TeacherDTO {
  id?: number;
  nome: string;
  email: string;
  password?: string; // apenas no cadastro
  matricula: string;
  qualificacao: string;
  contato: string;
}
```

### Eventos Kafka:

**StudentEvent:**
```typescript
interface StudentEvent {
  studentId: number;
  nome: string;
  matricula: string;
  email: string;
  eventType: 'CREATED' | 'UPDATED' | 'DELETED';
  timestamp: number;
}
```

**CourseEvent:**
```typescript
interface CourseEvent {
  cursoId: number;
  codigo: string;
  nome: string;
  eventType: 'CREATED' | 'UPDATED' | 'DELETED';
  timestamp: number;
}
```

**AvaliacaoEvent:**
```typescript
interface AvaliacaoEvent {
  avaliacaoId: number;
  matriculaId: number;
  alunoId: number;
  disciplinaId: number;
  tipoAvaliacao: string;
  nota: number;
  eventType: 'CREATED' | 'GRADE_RELEASED';
  timestamp: number;
}
```

---

## 🎯 Priorização de Desenvolvimento

### Sprint 1 (Essencial):
1. ✅ Autenticação e rotas protegidas
2. ✅ Dashboard Admin - CRUD Cursos
3. ✅ Dashboard Admin - CRUD Alunos
4. ✅ Dashboard Admin - CRUD Professores
5. ✅ Dashboard Admin - CRUD Disciplinas

### Sprint 2 (Core Features):
6. ✅ Dashboard Admin - Gestão de Matrículas
7. ✅ Portal Professor - Minhas Disciplinas
8. ✅ Portal Professor - Lançar Avaliações
9. ✅ Portal Aluno - Meu Perfil
10. ✅ Portal Aluno - Boletim

### Sprint 3 (Kafka & Real-time):
11. ✅ Sistema de Notificações Kafka
12. ✅ Toast notifications
13. ✅ Atualização automática de listas
14. ✅ Badge de notificações

---

## 🔥 Dicas de Implementação

1. **Use React Query / SWR** para cache e revalidação automática
2. **Material-UI ou Chakra UI** para componentes prontos
3. **React Hook Form + Zod** para validação de formulários
4. **Axios com interceptors** para adicionar token automaticamente
5. **WebSocket ou Server-Sent Events** para Kafka (criar bridge no backend)
6. **React Context** para gerenciar autenticação global
7. **React Router** para rotas protegidas por role

---

## 📞 Suporte

Todos os endpoints estão documentados e testados. Use o arquivo `test-complete-flow.ps1` como referência de como chamar a API corretamente.

**Gateway URL:** http://localhost:8080
**Kafka Broker:** localhost:9092

Boa implementação! 🚀
