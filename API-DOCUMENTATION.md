# 📚 Distrischool - API Documentation

**Versão:** 1.0  
**Base URL:** `http://localhost:8080`  
**Autenticação:** JWT Bearer Token  
**Última atualização:** 09/11/2025

---

## 📑 Índice

1. [Autenticação](#autenticação)
2. [Students (Alunos)](#students-alunos)
3. [Teachers (Professores)](#teachers-professores)
4. [Users (Usuários)](#users-usuários)
5. [Admins (Administradores)](#admins-administradores)
6. [Permissões RBAC](#permissões-rbac)
7. [Códigos de Status HTTP](#códigos-de-status-http)
8. [Exemplos de Integração](#exemplos-de-integração)

---

## 🔐 Autenticação

Todas as rotas (exceto login) requerem autenticação via JWT Bearer Token.

### 1.1 Login

**Endpoint:** `POST /api/auth/login`  
**Autenticação:** Não requerida  
**Permissões:** Público

**Request Body:**
```json
{
  "email": "admin@distrischool.com",
  "password": "admin123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbkBkaXN0cmlzY2hvb2wuY29tIiwicm9sZXMiOlsiUk9MRV9BRE1JTiJdLCJpYXQiOjE3MzEyMDAwMDAsImV4cCI6MTczMTIwMzYwMH0...",
  "email": "admin@distrischool.com",
  "roles": ["ROLE_ADMIN"]
}
```

**Response (401 Unauthorized):**
```json
{
  "error": "Invalid credentials"
}
```

**Exemplo JavaScript:**
```javascript
async function login(email, password) {
  const response = await fetch('http://localhost:8080/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email, password })
  });
  
  if (!response.ok) {
    throw new Error('Login falhou');
  }
  
  const data = await response.json();
  localStorage.setItem('token', data.token);
  localStorage.setItem('userEmail', data.email);
  localStorage.setItem('userRoles', JSON.stringify(data.roles));
  
  return data;
}
```

### 1.2 Validar Token

**Endpoint:** `POST /api/auth/validate`  
**Autenticação:** Bearer Token  
**Permissões:** Qualquer usuário autenticado

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "valid": true,
  "email": "admin@distrischool.com",
  "roles": ["ROLE_ADMIN"]
}
```

**Response (401 Unauthorized):**
```json
{
  "valid": false,
  "error": "Invalid token"
}
```

### 1.3 Health Check Auth Service

**Endpoint:** `GET /api/auth/health`  
**Autenticação:** Não requerida  
**Permissões:** Público

**Response (200 OK):**
```json
{
  "status": "UP",
  "service": "auth-service"
}
```

---

## 🎓 Students (Alunos)

### 2.1 Listar Todos os Alunos

**Endpoint:** `GET /api/alunos`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nome": "João Silva",
    "dataNascimento": "2005-03-15",
    "turma": "3A",
    "endereco": "Rua das Flores, 123",
    "contato": "85999887766",
    "matricula": "2025001",
    "historicoAcademicoCriptografado": "encrypted_data_here"
  },
  {
    "id": 2,
    "nome": "Maria Santos",
    "dataNascimento": "2006-08-20",
    "turma": "2B",
    "endereco": "Av. Principal, 456",
    "contato": "85988776655",
    "matricula": "2025002",
    "historicoAcademicoCriptografado": "encrypted_data_here"
  }
]
```

**Exemplo JavaScript:**
```javascript
async function getAllStudents() {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:8080/api/alunos', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  if (!response.ok) {
    throw new Error('Erro ao buscar alunos');
  }
  
  return await response.json();
}
```

### 2.2 Ver Próprio Perfil (Student)

**Endpoint:** `GET /api/alunos/me`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_STUDENT`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 56,
  "nome": "Teste Authentication User",
  "dataNascimento": "2000-05-15",
  "turma": "TEST",
  "endereco": "Endereco Atualizado via /me Test",
  "contato": "85999998888",
  "matricula": "2025999",
  "historicoAcademicoCriptografado": "encrypted_data_here"
}
```

**Response (404 Not Found):**
```json
{
  "error": "Aluno não encontrado para o email: admin@distrischool.com"
}
```

### 2.3 Buscar Aluno por ID

**Endpoint:** `GET /api/alunos/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN` ou próprio aluno

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "João Silva",
  "dataNascimento": "2005-03-15",
  "turma": "3A",
  "endereco": "Rua das Flores, 123",
  "contato": "85999887766",
  "matricula": "2025001",
  "historicoAcademicoCriptografado": "encrypted_data_here"
}
```

**Response (404 Not Found):**
```json
{
  "error": "Aluno não encontrado"
}
```

### 2.4 Buscar Alunos por Turma

**Endpoint:** `GET /api/alunos/turma/{turma}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Exemplo:** `GET /api/alunos/turma/3A`

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nome": "João Silva",
    "dataNascimento": "2005-03-15",
    "turma": "3A",
    "endereco": "Rua das Flores, 123",
    "contato": "85999887766",
    "matricula": "2025001",
    "historicoAcademicoCriptografado": "encrypted_data_here"
  }
]
```

### 2.5 Criar Aluno

**Endpoint:** `POST /api/alunos`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "nome": "Novo Aluno",
  "dataNascimento": "2005-03-15",
  "turma": "1A",
  "endereco": "Rua Teste, 123",
  "contato": "85999887766",
  "historicoAcademico": "Histórico do aluno"
}
```

**Campos:**
- `nome` (string, obrigatório): Nome completo do aluno
- `dataNascimento` (string ISO date, obrigatório): Data de nascimento (formato: YYYY-MM-DD)
- `turma` (string, obrigatório): Turma do aluno
- `endereco` (string, obrigatório): Endereço residencial
- `contato` (string, obrigatório): Telefone de contato
- `historicoAcademico` (string, opcional): Histórico acadêmico (será criptografado)

**Response (200/201 OK):**
```json
{
  "id": 59,
  "nome": "Novo Aluno",
  "dataNascimento": "2005-03-15",
  "turma": "1A",
  "endereco": "Rua Teste, 123",
  "contato": "85999887766",
  "matricula": "2025051",
  "historicoAcademicoCriptografado": "GScfxkE0wObYi..."
}
```

**Nota:** A matrícula é gerada automaticamente no formato: `YEAR + AUTO_INCREMENT`

**Exemplo JavaScript:**
```javascript
async function createStudent(studentData) {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:8080/api/alunos', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(studentData)
  });
  
  if (!response.ok) {
    throw new Error('Erro ao criar aluno');
  }
  
  return await response.json();
}
```

### 2.6 Atualizar Aluno

**Endpoint:** `PUT /api/alunos/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN` ou próprio aluno (via /me)

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "nome": "João Silva Atualizado",
  "dataNascimento": "2005-03-15",
  "turma": "3B",
  "endereco": "Novo Endereço, 999",
  "contato": "85988887777",
  "historicoAcademico": "Histórico atualizado"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "João Silva Atualizado",
  "dataNascimento": "2005-03-15",
  "turma": "3B",
  "endereco": "Novo Endereço, 999",
  "contato": "85988887777",
  "matricula": "2025001",
  "historicoAcademicoCriptografado": "new_encrypted_data"
}
```

### 2.7 Deletar Aluno

**Endpoint:** `DELETE /api/alunos/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200/204 OK):**
```json
{
  "message": "Aluno deletado com sucesso"
}
```

---

## 👨‍🏫 Teachers (Professores)

### 3.1 Listar Todos os Professores

**Endpoint:** `GET /api/teachers`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nome": "Ana Pereira",
    "matricula": "PROF2025001",
    "qualificacao": "Mestrado em Matemática",
    "contato": "85991234567"
  },
  {
    "id": 2,
    "nome": "Carlos Santos",
    "matricula": "PROF2025002",
    "qualificacao": "Doutorado em Física",
    "contato": "85987654321"
  }
]
```

**Exemplo JavaScript:**
```javascript
async function getAllTeachers() {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:8080/api/teachers', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  if (!response.ok) {
    throw new Error('Erro ao buscar professores');
  }
  
  return await response.json();
}
```

### 3.2 Ver Próprio Perfil (Teacher)

**Endpoint:** `GET /api/teachers/me`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_TEACHER`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "Ana Pereira",
  "matricula": "PROF2025001",
  "qualificacao": "Mestrado em Matemática",
  "contato": "85991234567"
}
```

### 3.3 Buscar Professor por ID

**Endpoint:** `GET /api/teachers/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN` ou próprio professor

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "Ana Pereira",
  "matricula": "PROF2025001",
  "qualificacao": "Mestrado em Matemática",
  "contato": "85991234567"
}
```

### 3.4 Criar Professor

**Endpoint:** `POST /api/teachers`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "nome": "Novo Professor",
  "matricula": "PROF2025999",
  "qualificacao": "Doutorado em Computação",
  "contato": "85999887766"
}
```

**Campos:**
- `nome` (string, obrigatório): Nome completo do professor
- `matricula` (string, obrigatório): Matrícula única do professor
- `qualificacao` (string, obrigatório): Qualificação acadêmica
- `contato` (string, obrigatório): Telefone de contato

**Response (200/201 OK):**
```json
{
  "id": 44,
  "nome": "Novo Professor",
  "matricula": "PROF2025999",
  "qualificacao": "Doutorado em Computação",
  "contato": "85999887766"
}
```

**Exemplo JavaScript:**
```javascript
async function createTeacher(teacherData) {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:8080/api/teachers', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(teacherData)
  });
  
  if (!response.ok) {
    throw new Error('Erro ao criar professor');
  }
  
  return await response.json();
}
```

### 3.5 Atualizar Professor

**Endpoint:** `PUT /api/teachers/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN` ou próprio professor (via /me)

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "nome": "Professor Atualizado",
  "matricula": "PROF2025999",
  "qualificacao": "Pós-Doutorado em Computação",
  "contato": "85988887777"
}
```

**Response (200 OK):**
```json
{
  "id": 44,
  "nome": "Professor Atualizado",
  "matricula": "PROF2025999",
  "qualificacao": "Pós-Doutorado em Computação",
  "contato": "85988887777"
}
```

### 3.6 Deletar Professor

**Endpoint:** `DELETE /api/teachers/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200/204 OK):**
```json
{
  "message": "Professor deletado com sucesso"
}
```

---

## 👤 Users (Usuários)

### 4.1 Listar Todos os Usuários

**Endpoint:** `GET /api/v1/users`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "fullName": "Admin Principal",
    "email": "admin@distrischool.com",
    "role": "ADMIN",
    "enabled": true
  },
  {
    "id": 2,
    "fullName": "João Silva",
    "email": "joao.silva.2025001@unifor.br",
    "role": "STUDENT",
    "enabled": true
  }
]
```

### 4.2 Buscar Usuário por ID

**Endpoint:** `GET /api/v1/users/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "fullName": "Admin Principal",
  "email": "admin@distrischool.com",
  "role": "ADMIN",
  "enabled": true
}
```

### 4.3 Criar Usuário

**Endpoint:** `POST /api/v1/users`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "fullName": "Novo Usuário",
  "email": "novo.usuario@distrischool.com",
  "role": "STUDENT",
  "enabled": true
}
```

**Campos:**
- `fullName` (string, obrigatório): Nome completo
- `email` (string, obrigatório): Email único
- `role` (string, obrigatório): Role do usuário (`ADMIN`, `STUDENT`, `TEACHER`, `PARENT`)
- `enabled` (boolean, opcional): Se o usuário está ativo (padrão: true)

**Response (200/201 OK):**
```json
{
  "id": 28,
  "fullName": "Novo Usuário",
  "email": "novo.usuario@distrischool.com",
  "role": "STUDENT",
  "enabled": true
}
```

**Nota:** A senha é gerada automaticamente e enviada por email (ou retornada na resposta em ambiente de desenvolvimento).

---

## 👔 Admins (Administradores)

### 5.1 Listar Todos os Admins

**Endpoint:** `GET /api/v1/admins`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Admin Principal",
    "email": "admin@distrischool.com",
    "role": "ADMIN"
  },
  {
    "id": 2,
    "name": "Coordenador João",
    "email": "coordenador@distrischool.com",
    "role": "COORDINATOR"
  }
]
```

### 5.2 Buscar Admin por ID

**Endpoint:** `GET /api/v1/admins/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Admin Principal",
  "email": "admin@distrischool.com",
  "role": "ADMIN"
}
```

### 5.3 Criar Admin

**Endpoint:** `POST /api/v1/admins`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Novo Admin",
  "email": "novo.admin@distrischool.com",
  "role": "COORDINATOR"
}
```

**Campos:**
- `name` (string, obrigatório): Nome completo
- `email` (string, obrigatório): Email único
- `role` (string, obrigatório): Tipo de admin (`ADMIN`, `COORDINATOR`, `DIRECTOR`)

**Response (200/201 OK):**
```json
{
  "id": 20,
  "name": "Novo Admin",
  "email": "novo.admin@distrischool.com",
  "role": "COORDINATOR"
}
```

### 5.4 Atualizar Admin

**Endpoint:** `PUT /api/v1/admins/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Admin Atualizado",
  "email": "admin.updated@distrischool.com",
  "role": "DIRECTOR"
}
```

**Response (200 OK):**
```json
{
  "id": 20,
  "name": "Admin Atualizado",
  "email": "admin.updated@distrischool.com",
  "role": "DIRECTOR"
}
```

### 5.5 Deletar Admin

**Endpoint:** `DELETE /api/v1/admins/{id}`  
**Autenticação:** Bearer Token  
**Permissões:** `ROLE_ADMIN`

**Request Headers:**
```
Authorization: Bearer {token}
```

**Response (200/204 OK):**
```json
{
  "message": "Admin deletado com sucesso"
}
```

---

## 🔒 Permissões RBAC

### Roles Disponíveis

| Role | Descrição | Permissões |
|------|-----------|------------|
| `ROLE_ADMIN` | Administrador | Acesso total a todos os recursos |
| `ROLE_STUDENT` | Aluno | Ver próprio perfil, listar colegas (limitado) |
| `ROLE_TEACHER` | Professor | Ver próprio perfil, listar alunos (limitado) |
| `ROLE_PARENT` | Responsável | Ver perfil dos filhos (futuro) |

### Matriz de Permissões

| Endpoint | ADMIN | STUDENT | TEACHER | Público |
|----------|-------|---------|---------|---------|
| `POST /api/auth/login` | ✅ | ✅ | ✅ | ✅ |
| `POST /api/auth/validate` | ✅ | ✅ | ✅ | ❌ |
| `GET /api/alunos` | ✅ | ❌ | ❌ | ❌ |
| `GET /api/alunos/me` | ❌ | ✅ | ❌ | ❌ |
| `GET /api/alunos/{id}` | ✅ | ✅* | ❌ | ❌ |
| `POST /api/alunos` | ✅ | ❌ | ❌ | ❌ |
| `PUT /api/alunos/{id}` | ✅ | ✅* | ❌ | ❌ |
| `DELETE /api/alunos/{id}` | ✅ | ❌ | ❌ | ❌ |
| `GET /api/teachers` | ✅ | ❌ | ❌ | ❌ |
| `GET /api/teachers/me` | ❌ | ❌ | ✅ | ❌ |
| `GET /api/teachers/{id}` | ✅ | ❌ | ✅* | ❌ |
| `POST /api/teachers` | ✅ | ❌ | ❌ | ❌ |
| `PUT /api/teachers/{id}` | ✅ | ❌ | ✅* | ❌ |
| `DELETE /api/teachers/{id}` | ✅ | ❌ | ❌ | ❌ |
| `GET /api/v1/users` | ✅ | ❌ | ❌ | ❌ |
| `POST /api/v1/users` | ✅ | ❌ | ❌ | ❌ |
| `GET /api/v1/admins` | ✅ | ❌ | ❌ | ❌ |
| `POST /api/v1/admins` | ✅ | ❌ | ❌ | ❌ |

**Legenda:** ✅ = Permitido | ❌ = Negado | ✅* = Permitido apenas para próprio recurso

---

## 📊 Códigos de Status HTTP

### Sucesso

| Código | Significado | Quando ocorre |
|--------|-------------|---------------|
| `200 OK` | Sucesso | Operação GET/PUT/DELETE bem-sucedida |
| `201 Created` | Criado | Recurso POST criado com sucesso |
| `204 No Content` | Sem conteúdo | DELETE bem-sucedido sem corpo de resposta |

### Erros de Cliente

| Código | Significado | Quando ocorre |
|--------|-------------|---------------|
| `400 Bad Request` | Requisição inválida | Dados mal formatados ou campos obrigatórios ausentes |
| `401 Unauthorized` | Não autenticado | Token ausente, inválido ou expirado |
| `403 Forbidden` | Sem permissão | Usuário autenticado mas sem permissão para o recurso |
| `404 Not Found` | Não encontrado | Recurso solicitado não existe |
| `409 Conflict` | Conflito | Tentativa de criar recurso duplicado (ex: email já existe) |

### Erros de Servidor

| Código | Significado | Quando ocorre |
|--------|-------------|---------------|
| `500 Internal Server Error` | Erro interno | Erro inesperado no servidor |
| `503 Service Unavailable` | Serviço indisponível | Servidor temporariamente fora do ar |

---

## 💻 Exemplos de Integração

### React/Next.js

#### 1. Serviço de API (api.service.js)

```javascript
const API_BASE_URL = 'http://localhost:8080';

class ApiService {
  constructor() {
    this.baseURL = API_BASE_URL;
  }

  getToken() {
    return localStorage.getItem('token');
  }

  getHeaders(includeAuth = true) {
    const headers = {
      'Content-Type': 'application/json'
    };

    if (includeAuth) {
      const token = this.getToken();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }

    return headers;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      ...options,
      headers: this.getHeaders(options.auth !== false)
    };

    try {
      const response = await fetch(url, config);

      if (!response.ok) {
        const error = await response.json().catch(() => ({}));
        throw new Error(error.error || `HTTP ${response.status}`);
      }

      // Para respostas 204 No Content
      if (response.status === 204) {
        return null;
      }

      return await response.json();
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }

  // Auth
  async login(email, password) {
    const data = await this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
      auth: false
    });

    if (data.token) {
      localStorage.setItem('token', data.token);
      localStorage.setItem('userEmail', data.email);
      localStorage.setItem('userRoles', JSON.stringify(data.roles));
    }

    return data;
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRoles');
  }

  async validateToken() {
    return await this.request('/api/auth/validate', {
      method: 'POST'
    });
  }

  // Students
  async getStudents() {
    return await this.request('/api/alunos', {
      method: 'GET'
    });
  }

  async getStudentById(id) {
    return await this.request(`/api/alunos/${id}`, {
      method: 'GET'
    });
  }

  async getMyProfile() {
    return await this.request('/api/alunos/me', {
      method: 'GET'
    });
  }

  async createStudent(studentData) {
    return await this.request('/api/alunos', {
      method: 'POST',
      body: JSON.stringify(studentData)
    });
  }

  async updateStudent(id, studentData) {
    return await this.request(`/api/alunos/${id}`, {
      method: 'PUT',
      body: JSON.stringify(studentData)
    });
  }

  async deleteStudent(id) {
    return await this.request(`/api/alunos/${id}`, {
      method: 'DELETE'
    });
  }

  // Teachers
  async getTeachers() {
    return await this.request('/api/teachers', {
      method: 'GET'
    });
  }

  async getTeacherById(id) {
    return await this.request(`/api/teachers/${id}`, {
      method: 'GET'
    });
  }

  async createTeacher(teacherData) {
    return await this.request('/api/teachers', {
      method: 'POST',
      body: JSON.stringify(teacherData)
    });
  }

  async updateTeacher(id, teacherData) {
    return await this.request(`/api/teachers/${id}`, {
      method: 'PUT',
      body: JSON.stringify(teacherData)
    });
  }

  async deleteTeacher(id) {
    return await this.request(`/api/teachers/${id}`, {
      method: 'DELETE'
    });
  }

  // Users
  async getUsers() {
    return await this.request('/api/v1/users', {
      method: 'GET'
    });
  }

  async getUserById(id) {
    return await this.request(`/api/v1/users/${id}`, {
      method: 'GET'
    });
  }

  async createUser(userData) {
    return await this.request('/api/v1/users', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  }

  // Admins
  async getAdmins() {
    return await this.request('/api/v1/admins', {
      method: 'GET'
    });
  }

  async getAdminById(id) {
    return await this.request(`/api/v1/admins/${id}`, {
      method: 'GET'
    });
  }

  async createAdmin(adminData) {
    return await this.request('/api/v1/admins', {
      method: 'POST',
      body: JSON.stringify(adminData)
    });
  }

  async updateAdmin(id, adminData) {
    return await this.request(`/api/v1/admins/${id}`, {
      method: 'PUT',
      body: JSON.stringify(adminData)
    });
  }

  async deleteAdmin(id) {
    return await this.request(`/api/v1/admins/${id}`, {
      method: 'DELETE'
    });
  }
}

export const apiService = new ApiService();
```

#### 2. Hook de Autenticação (useAuth.js)

```javascript
import { useState, useEffect, createContext, useContext } from 'react';
import { apiService } from './api.service';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  async function checkAuth() {
    const token = localStorage.getItem('token');
    
    if (!token) {
      setLoading(false);
      return;
    }

    try {
      const data = await apiService.validateToken();
      if (data.valid) {
        setUser({
          email: data.email,
          roles: data.roles
        });
      } else {
        apiService.logout();
      }
    } catch (error) {
      apiService.logout();
    } finally {
      setLoading(false);
    }
  }

  async function login(email, password) {
    const data = await apiService.login(email, password);
    setUser({
      email: data.email,
      roles: data.roles
    });
    return data;
  }

  function logout() {
    apiService.logout();
    setUser(null);
  }

  function hasRole(role) {
    return user?.roles?.includes(role) || false;
  }

  function isAdmin() {
    return hasRole('ROLE_ADMIN');
  }

  function isStudent() {
    return hasRole('ROLE_STUDENT');
  }

  function isTeacher() {
    return hasRole('ROLE_TEACHER');
  }

  return (
    <AuthContext.Provider value={{
      user,
      loading,
      login,
      logout,
      hasRole,
      isAdmin,
      isStudent,
      isTeacher
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
```

#### 3. Componente de Login (LoginPage.jsx)

```javascript
import { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useRouter } from 'next/router';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const router = useRouter();

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(email, password);
      router.push('/dashboard');
    } catch (err) {
      setError('Email ou senha inválidos');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-container">
      <form onSubmit={handleSubmit}>
        <h1>Login - Distrischool</h1>
        
        {error && <div className="error">{error}</div>}
        
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
        
        <input
          type="password"
          placeholder="Senha"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        
        <button type="submit" disabled={loading}>
          {loading ? 'Entrando...' : 'Entrar'}
        </button>
      </form>
    </div>
  );
}
```

#### 4. Lista de Alunos (StudentsPage.jsx)

```javascript
import { useState, useEffect } from 'react';
import { apiService } from '../services/api.service';
import { useAuth } from '../hooks/useAuth';

export default function StudentsPage() {
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const { isAdmin } = useAuth();

  useEffect(() => {
    loadStudents();
  }, []);

  async function loadStudents() {
    try {
      const data = await apiService.getStudents();
      setStudents(data);
    } catch (err) {
      setError('Erro ao carregar alunos');
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id) {
    if (!confirm('Tem certeza que deseja deletar este aluno?')) return;

    try {
      await apiService.deleteStudent(id);
      setStudents(students.filter(s => s.id !== id));
    } catch (err) {
      alert('Erro ao deletar aluno');
    }
  }

  if (loading) return <div>Carregando...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div>
      <h1>Alunos</h1>
      
      {isAdmin() && (
        <button onClick={() => router.push('/students/new')}>
          Novo Aluno
        </button>
      )}

      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Matrícula</th>
            <th>Turma</th>
            <th>Contato</th>
            {isAdmin() && <th>Ações</th>}
          </tr>
        </thead>
        <tbody>
          {students.map(student => (
            <tr key={student.id}>
              <td>{student.id}</td>
              <td>{student.nome}</td>
              <td>{student.matricula}</td>
              <td>{student.turma}</td>
              <td>{student.contato}</td>
              {isAdmin() && (
                <td>
                  <button onClick={() => router.push(`/students/${student.id}/edit`)}>
                    Editar
                  </button>
                  <button onClick={() => handleDelete(student.id)}>
                    Deletar
                  </button>
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

### Vue.js

#### API Service (api.service.js)

```javascript
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080';

const axiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Interceptor para adicionar token automaticamente
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para tratar erros
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default {
  // Auth
  async login(email, password) {
    const response = await axios.post(`${API_BASE_URL}/api/auth/login`, {
      email,
      password
    });
    
    if (response.data.token) {
      localStorage.setItem('token', response.data.token);
    }
    
    return response.data;
  },

  // Students
  async getStudents() {
    const response = await axiosInstance.get('/api/alunos');
    return response.data;
  },

  async getStudentById(id) {
    const response = await axiosInstance.get(`/api/alunos/${id}`);
    return response.data;
  },

  async createStudent(studentData) {
    const response = await axiosInstance.post('/api/alunos', studentData);
    return response.data;
  },

  async updateStudent(id, studentData) {
    const response = await axiosInstance.put(`/api/alunos/${id}`, studentData);
    return response.data;
  },

  async deleteStudent(id) {
    const response = await axiosInstance.delete(`/api/alunos/${id}`);
    return response.data;
  },

  // Teachers
  async getTeachers() {
    const response = await axiosInstance.get('/api/teachers');
    return response.data;
  },

  async createTeacher(teacherData) {
    const response = await axiosInstance.post('/api/teachers', teacherData);
    return response.data;
  }
};
```

### Angular

#### API Service (api.service.ts)

```typescript
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

const API_BASE_URL = 'http://localhost:8080';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': token ? `Bearer ${token}` : ''
    });
  }

  // Auth
  login(email: string, password: string): Observable<any> {
    return this.http.post(`${API_BASE_URL}/api/auth/login`, {
      email,
      password
    });
  }

  // Students
  getStudents(): Observable<any[]> {
    return this.http.get<any[]>(`${API_BASE_URL}/api/alunos`, {
      headers: this.getHeaders()
    });
  }

  getStudentById(id: number): Observable<any> {
    return this.http.get<any>(`${API_BASE_URL}/api/alunos/${id}`, {
      headers: this.getHeaders()
    });
  }

  createStudent(studentData: any): Observable<any> {
    return this.http.post<any>(`${API_BASE_URL}/api/alunos`, studentData, {
      headers: this.getHeaders()
    });
  }

  updateStudent(id: number, studentData: any): Observable<any> {
    return this.http.put<any>(`${API_BASE_URL}/api/alunos/${id}`, studentData, {
      headers: this.getHeaders()
    });
  }

  deleteStudent(id: number): Observable<any> {
    return this.http.delete<any>(`${API_BASE_URL}/api/alunos/${id}`, {
      headers: this.getHeaders()
    });
  }

  // Teachers
  getTeachers(): Observable<any[]> {
    return this.http.get<any[]>(`${API_BASE_URL}/api/teachers`, {
      headers: this.getHeaders()
    });
  }

  createTeacher(teacherData: any): Observable<any> {
    return this.http.post<any>(`${API_BASE_URL}/api/teachers`, teacherData, {
      headers: this.getHeaders()
    });
  }
}
```

---

## 🔧 Configuração e Troubleshooting

### CORS

O backend já está configurado para aceitar requisições do frontend. Se houver problemas de CORS:

1. Verifique se o Gateway está rodando na porta 8080
2. Certifique-se de que o frontend está usando `http://localhost:8080` como base URL
3. Verifique os logs do Gateway para erros de CORS

### Ambiente de Desenvolvimento

**Credenciais de Teste:**
```
Email: admin@distrischool.com
Senha: admin123
```

**Para resetar o usuário admin (se necessário):**
```bash
curl -X POST http://localhost:8080/api/auth/reset-admin
```

### Erros Comuns

#### 1. Token Expirado (401)
**Solução:** Fazer logout e login novamente

```javascript
if (error.response?.status === 401) {
  localStorage.removeItem('token');
  window.location.href = '/login';
}
```

#### 2. Permissão Negada (403)
**Solução:** Verificar se o usuário tem a role necessária

```javascript
const roles = JSON.parse(localStorage.getItem('userRoles') || '[]');
if (!roles.includes('ROLE_ADMIN')) {
  alert('Você não tem permissão para esta operação');
}
```

#### 3. Recurso Não Encontrado (404)
**Solução:** Verificar se o ID existe ou se o endpoint está correto

---

## 📞 Suporte

**Desenvolvedor Backend:** [Joao victor amora]  
**Email:** [amorajoaovictor2@gmail.com]  
**Repositório:** https://github.com/Amorajoaovictor/distrischool-backend

---

**Última atualização:** 09/11/2025  
**Versão da API:** 1.0
