# 📝 Student Profile Edit - Frontend Implementation Guide

## 🎯 Overview

This document provides complete specifications for implementing the **Student Profile Editing** feature in the frontend. A student logged in with `ROLE_STUDENT` should be able to view and edit their own profile information.

---

## 🔒 Authentication & Authorization

### Required Permissions
- **Role:** `ROLE_STUDENT`
- **Authentication:** JWT Bearer Token (obtained from login)
- **Scope:** Student can only edit their **own** profile

### Getting the Token

**Login Request:**
```http
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "email": "student@unifor.br",
  "password": "student_password"
}
```

**Login Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "student@unifor.br",
  "roles": ["ROLE_STUDENT"]
}
```

**Store the token:**
```javascript
localStorage.setItem('token', response.token);
localStorage.setItem('userEmail', response.email);
```

---

## 📖 API Endpoints

### 1. Get Current Student Profile

**Purpose:** Fetch the logged-in student's profile data

**Endpoint:**
```
GET /api/alunos/me
```

**Headers:**
```http
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 56,
  "nome": "Maria Silva",
  "dataNascimento": "2005-03-15",
  "turma": "3A",
  "endereco": "Rua das Flores, 123",
  "contato": "85999998888",
  "matricula": "2025056",
  "historicoAcademicoCriptografado": "encrypted_data_here"
}
```

**Response (404 Not Found):**
```json
{
  "error": "Aluno não encontrado para o email: student@unifor.br"
}
```

**JavaScript Example:**
```javascript
async function getMyProfile() {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:8080/api/alunos/me', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch profile');
  }
  
  return await response.json();
}
```

---

### 2. Update Student Profile

**Purpose:** Update the logged-in student's profile information

**Endpoint:**
```
PUT /api/alunos/{id}
```

**⚠️ CRITICAL:** The `{id}` must be the student's own ID (obtained from GET /api/alunos/me)

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json; charset=utf-8
```

**Request Body (ALL fields required):**
```json
{
  "nome": "Maria Silva Atualizada",
  "dataNascimento": "2005-03-15",
  "turma": "3B",
  "endereco": "Rua Nova, 999",
  "contato": "85988887777",
  "matricula": "2025056",
  "historicoAcademico": "Histórico acadêmico atualizado"
}
```

**Field Specifications:**

| Field | Type | Required | Editable | Format | Notes |
|-------|------|----------|----------|--------|-------|
| `nome` | string | ✅ Yes | ✅ Yes | Plain text | Full name |
| `dataNascimento` | string | ✅ Yes | ✅ Yes | `YYYY-MM-DD` | ISO date format |
| `turma` | string | ✅ Yes | ✅ Yes | Plain text | Class/Grade |
| `endereco` | string | ✅ Yes | ✅ Yes | Plain text | Address |
| `contato` | string | ✅ Yes | ✅ Yes | Phone number | Contact number |
| `matricula` | string | ✅ Yes | ❌ **READ-ONLY** | Auto-generated | Student ID (should not change) |
| `historicoAcademico` | string | ✅ Yes | ✅ Yes | Plain text | Academic history (encrypted on backend) |

**Response (200 OK):**
```json
{
  "id": 56,
  "nome": "Maria Silva Atualizada",
  "dataNascimento": "2005-03-15",
  "turma": "3B",
  "endereco": "Rua Nova, 999",
  "contato": "85988887777",
  "matricula": "2025056",
  "historicoAcademicoCriptografado": "new_encrypted_data_here"
}
```

**JavaScript Example:**
```javascript
async function updateMyProfile(studentData) {
  const token = localStorage.getItem('token');
  
  // IMPORTANT: Include ALL fields, even if unchanged
  const response = await fetch(`http://localhost:8080/api/alunos/${studentData.id}`, {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json; charset=utf-8'
    },
    body: JSON.stringify({
      nome: studentData.nome,
      dataNascimento: studentData.dataNascimento,
      turma: studentData.turma,
      endereco: studentData.endereco,
      contato: studentData.contato,
      matricula: studentData.matricula, // Include but don't allow user to change
      historicoAcademico: studentData.historicoAcademico
    })
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to update profile');
  }
  
  return await response.json();
}
```

---

## 🚨 Error Handling

### HTTP Status Codes

| Code | Meaning | What to do |
|------|---------|------------|
| `200 OK` | Success | Show success message, update UI |
| `400 Bad Request` | Invalid data format | Validate form fields, show error message |
| `401 Unauthorized` | Token invalid/expired | Redirect to login page |
| `403 Forbidden` | No permission | Show "Access denied" message |
| `404 Not Found` | Student not found | Show "Profile not found" error |
| `500 Internal Server Error` | Server error | Show generic error message |

### Error Response Format

```json
{
  "error": "Description of what went wrong"
}
```

### JavaScript Error Handling Example

```javascript
async function handleProfileUpdate(formData) {
  try {
    const updated = await updateMyProfile(formData);
    
    // Success
    showSuccessMessage('Perfil atualizado com sucesso!');
    return updated;
    
  } catch (error) {
    if (error.message.includes('401')) {
      // Token expired
      localStorage.clear();
      window.location.href = '/login';
      
    } else if (error.message.includes('403')) {
      // No permission
      showErrorMessage('Você não tem permissão para editar este perfil');
      
    } else if (error.message.includes('404')) {
      // Not found
      showErrorMessage('Perfil não encontrado');
      
    } else {
      // Generic error
      showErrorMessage('Erro ao atualizar perfil. Tente novamente.');
    }
  }
}
```

---

## 💡 Complete Implementation Example (React)

### 1. Profile Edit Component

```jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function StudentProfileEdit() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  // Load profile on component mount
  useEffect(() => {
    loadProfile();
  }, []);

  async function loadProfile() {
    try {
      const token = localStorage.getItem('token');
      
      const response = await fetch('http://localhost:8080/api/alunos/me', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        if (response.status === 401) {
          localStorage.clear();
          navigate('/login');
          return;
        }
        throw new Error('Failed to load profile');
      }

      const data = await response.json();
      setProfile(data);
      
    } catch (err) {
      setError('Erro ao carregar perfil');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setSaving(true);

    try {
      const token = localStorage.getItem('token');
      
      // IMPORTANT: Send ALL fields
      const response = await fetch(`http://localhost:8080/api/alunos/${profile.id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json; charset=utf-8'
        },
        body: JSON.stringify({
          nome: profile.nome,
          dataNascimento: profile.dataNascimento,
          turma: profile.turma,
          endereco: profile.endereco,
          contato: profile.contato,
          matricula: profile.matricula, // Include but disabled in form
          historicoAcademico: profile.historicoAcademico || ''
        })
      });

      if (!response.ok) {
        if (response.status === 401) {
          localStorage.clear();
          navigate('/login');
          return;
        }
        throw new Error('Failed to update profile');
      }

      const updated = await response.json();
      setProfile(updated);
      alert('Perfil atualizado com sucesso!');
      
    } catch (err) {
      setError('Erro ao atualizar perfil. Tente novamente.');
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  function handleChange(field, value) {
    setProfile({ ...profile, [field]: value });
  }

  if (loading) {
    return <div>Carregando perfil...</div>;
  }

  if (!profile) {
    return <div>Perfil não encontrado</div>;
  }

  return (
    <div className="profile-edit-container">
      <h1>Editar Meu Perfil</h1>
      
      {error && <div className="error-message">{error}</div>}
      
      <form onSubmit={handleSubmit}>
        
        <div className="form-group">
          <label>Nome Completo</label>
          <input
            type="text"
            value={profile.nome}
            onChange={(e) => handleChange('nome', e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label>Data de Nascimento</label>
          <input
            type="date"
            value={profile.dataNascimento}
            onChange={(e) => handleChange('dataNascimento', e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label>Turma</label>
          <input
            type="text"
            value={profile.turma}
            onChange={(e) => handleChange('turma', e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label>Endereço</label>
          <input
            type="text"
            value={profile.endereco}
            onChange={(e) => handleChange('endereco', e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label>Contato (Telefone)</label>
          <input
            type="tel"
            value={profile.contato}
            onChange={(e) => handleChange('contato', e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label>Matrícula (Somente Leitura)</label>
          <input
            type="text"
            value={profile.matricula}
            disabled
            readOnly
          />
          <small>A matrícula não pode ser alterada</small>
        </div>

        <div className="form-group">
          <label>Histórico Acadêmico</label>
          <textarea
            value={profile.historicoAcademico || ''}
            onChange={(e) => handleChange('historicoAcademico', e.target.value)}
            rows="5"
          />
        </div>

        <div className="form-actions">
          <button type="submit" disabled={saving}>
            {saving ? 'Salvando...' : 'Salvar Alterações'}
          </button>
          <button type="button" onClick={() => navigate('/dashboard')}>
            Cancelar
          </button>
        </div>
        
      </form>
    </div>
  );
}
```

### 2. CSS Styles (Optional)

```css
.profile-edit-container {
  max-width: 600px;
  margin: 2rem auto;
  padding: 2rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #333;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-group input:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
}

.form-group small {
  display: block;
  margin-top: 0.25rem;
  color: #666;
  font-size: 0.875rem;
}

.error-message {
  padding: 1rem;
  background-color: #fee;
  border: 1px solid #fcc;
  border-radius: 4px;
  color: #c00;
  margin-bottom: 1rem;
}

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
}

.form-actions button {
  flex: 1;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
}

.form-actions button[type="submit"] {
  background-color: #007bff;
  color: white;
}

.form-actions button[type="submit"]:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.form-actions button[type="button"] {
  background-color: #6c757d;
  color: white;
}
```

---

## ⚠️ Critical Implementation Notes

### 1. UTF-8 Encoding
**Always include `charset=utf-8` in Content-Type header:**
```javascript
'Content-Type': 'application/json; charset=utf-8'
```

### 2. Send ALL Fields
**The PUT endpoint requires ALL fields, even unchanged ones:**
```javascript
// ❌ WRONG - Will fail
body: JSON.stringify({
  nome: "New Name"
})

// ✅ CORRECT - Include all fields
body: JSON.stringify({
  nome: studentData.nome,
  dataNascimento: studentData.dataNascimento,
  turma: studentData.turma,
  endereco: studentData.endereco,
  contato: studentData.contato,
  matricula: studentData.matricula,
  historicoAcademico: studentData.historicoAcademico
})
```

### 3. Matricula is Read-Only
- Display `matricula` field as **disabled/readonly**
- Include it in PUT request but don't allow user to change it
- It's auto-generated by the backend

### 4. Date Format
- Backend expects: `YYYY-MM-DD` (ISO format)
- Use `<input type="date">` for automatic formatting
- Example: `"2005-03-15"`

### 5. Token Expiration
- JWT tokens expire after 24 hours
- Always handle 401 errors by redirecting to login
- Consider implementing token refresh logic

---

## 🔄 User Flow

```
1. Student logs in
   ↓
2. Receives JWT token + email
   ↓
3. Navigates to "Edit Profile" page
   ↓
4. Frontend calls GET /api/alunos/me
   ↓
5. Backend returns student data
   ↓
6. Form is populated with current values
   ↓
7. Student edits fields (except matricula)
   ↓
8. Student clicks "Save"
   ↓
9. Frontend calls PUT /api/alunos/{id} with ALL fields
   ↓
10. Backend validates and updates
    ↓
11. Success: Show confirmation + update UI
    OR
    Error: Show error message + keep form editable
```

---

## 🧪 Testing Checklist

- [ ] Login with ROLE_STUDENT account
- [ ] Profile loads correctly via GET /api/alunos/me
- [ ] All fields are populated in the form
- [ ] Matricula field is disabled/readonly
- [ ] Can edit: nome, dataNascimento, turma, endereco, contato, historicoAcademico
- [ ] Date picker works for dataNascimento
- [ ] Save button works and sends PUT request
- [ ] All fields are included in PUT request
- [ ] Success message shows on successful update
- [ ] Profile data refreshes after update
- [ ] Error handling works for 400/401/403/404/500
- [ ] Token expiration redirects to login
- [ ] Form validation prevents empty required fields
- [ ] UTF-8 characters (accents) work correctly

---

## 📞 Backend Details

**Base URL:** `http://localhost:8080`  
**Service:** `student-service` (via Gateway)  
**Authentication:** JWT (24h expiration)  
**Database:** PostgreSQL (Neon.tech)  
**Encryption:** Histórico acadêmico is encrypted at rest

---

## 🎉 Summary

This feature allows students to:
- ✅ View their own profile data
- ✅ Edit their personal information
- ✅ Update contact details
- ✅ Modify academic history
- ❌ Cannot change matricula (read-only)
- ❌ Cannot view/edit other students' profiles

**Key Points:**
1. Use GET `/api/alunos/me` to fetch current profile
2. Use PUT `/api/alunos/{id}` to update (include ALL fields)
3. Always include `Authorization: Bearer {token}` header
4. Always use `Content-Type: application/json; charset=utf-8`
5. Handle 401 errors by redirecting to login
6. Matricula field should be disabled in UI

---

**Last Updated:** November 12, 2025  
**API Version:** 1.0
