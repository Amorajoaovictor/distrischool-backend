# Scripts de Teste - Distrischool

## 📋 Resumo dos Scripts

Todos os scripts de teste foram configurados para usar as credenciais do **ADMIN** que sempre está disponível após o deploy:

```
Email: admin@distrischool.com
Senha: admin123
```

## 🧪 Scripts Disponíveis

### 1. ✅ `test-all-routes.ps1` (PRINCIPAL - RECOMENDADO)
**Status:** ✅ Funcionando perfeitamente

**Descrição:** Teste completo de todas as rotas via Gateway com autenticação ADMIN

**Uso:**
```powershell
.\test-all-routes.ps1
```

**O que testa:**
- ✅ Login ADMIN
- ✅ Health checks de todos os serviços
- ✅ CRUD de Teachers (criar, listar, buscar, atualizar)
- ✅ CRUD de Students (criar, listar, buscar por turma)
- ✅ CRUD de Users
- ✅ CRUD de Admins
- ✅ Routes do Gateway

---

### 2. `test-all-routes-rbac.ps1`
**Status:** ⚠️ Parcial (usa apenas ADMIN)

**Descrição:** Versão RBAC do teste completo (originalmente testaria ADMIN, STUDENT, TEACHER)

**Limitação Atual:** Usa apenas token ADMIN para todos os testes pois não temos usuários STUDENT/TEACHER com senhas conhecidas

**Uso:**
```powershell
.\test-all-routes-rbac.ps1
```

---

### 3. `test-routes-auth.ps1`
**Status:** ✅ Atualizado para ADMIN

**Descrição:** Testes de autenticação em todas as rotas

**Uso:**
```powershell
.\test-routes-auth.ps1
```

---

### 4. `test-rbac-complete.ps1`
**Status:** ⚠️ Parcial (usa apenas ADMIN)

**Descrição:** Teste completo de RBAC (originalmente ADMIN + STUDENT + TEACHER)

**Nota:** Inclui avisos sobre necessidade de criar usuários de teste com senhas conhecidas

**Uso:**
```powershell
.\test-rbac-complete.ps1
```

---

### 5. `test-quick-rbac.ps1`
**Status:** ⚠️ Parcial (usa apenas ADMIN)

**Descrição:** Teste rápido de validação de permissões RBAC

**Uso:**
```powershell
.\test-quick-rbac.ps1
```

---

### 6. `test-own-profile.ps1`
**Status:** ⚠️ Demonstração (usa ADMIN, retorna 404 esperado)

**Descrição:** Teste do endpoint `/me` para ver próprio perfil

**Comportamento:** Usa ADMIN para demonstrar, mas retornará 404 pois ADMIN não é STUDENT/TEACHER

**Uso:**
```powershell
.\test-own-profile.ps1
```

---

### 7. `test-me-endpoint.ps1`
**Status:** ⚠️ Demonstração (usa ADMIN, retorna 404 esperado)

**Descrição:** Teste específico do endpoint `/me`

**Comportamento:** Similar ao test-own-profile.ps1

**Uso:**
```powershell
.\test-me-endpoint.ps1
```

---

### 8. `test-admin-only-create.ps1`
**Status:** ✅ Funcional (testa ADMIN vs SEM TOKEN)

**Descrição:** Valida que apenas ADMIN pode criar recursos

**O que testa:**
- ✅ ADMIN pode criar (200/201)
- ✅ Sem token é bloqueado (401)
- ⚠️ STUDENT bloqueado (não testado - falta usuário STUDENT)

**Uso:**
```powershell
.\test-admin-only-create.ps1
```

---

## 🔧 Setup Inicial

### Resetar usuário ADMIN (se necessário):
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/auth/reset-admin" -Method POST
```

### Subir todos os serviços:
```powershell
cd infra/docker
docker-compose up -d
```

### Verificar status:
```powershell
docker-compose ps
```

---

## 📝 Notas Importantes

### ⚠️ Limitação Atual: Usuários STUDENT/TEACHER

Os scripts que testam permissões específicas de STUDENT e TEACHER **não funcionam completamente** porque:

1. **Problema:** Quando um Student ou Teacher é criado, o auth-service gera uma senha aleatória via Kafka
2. **Consequência:** Não sabemos a senha para fazer login como esses usuários nos testes
3. **Solução Temporária:** Scripts usam ADMIN para todos os testes

### 🔮 Melhorias Futuras

Para testes completos de RBAC, implementar uma das opções:

**Opção 1:** Endpoint para criar usuários de teste com senha conhecida
```java
@PostMapping("/api/auth/create-test-user")
public ResponseEntity<?> createTestUser(@RequestBody TestUserRequest request) {
    // Criar usuário com senha definida (apenas em DEV)
}
```

**Opção 2:** Modificar eventos Kafka para aceitar senha opcional
```java
// No UserCreatedEvent
private String password; // Opcional - se não fornecido, gera aleatório
```

**Opção 3:** Script de setup que cria usuários de teste via SQL
```powershell
# setup-test-users.ps1
# Cria STUDENT e TEACHER com senhas conhecidas diretamente no banco
```

---

## ✅ Script Recomendado para CI/CD

```powershell
# Executar este no pipeline:
.\test-all-routes.ps1
```

Este script é o mais completo e confiável, testando todas as funcionalidades principais com ADMIN.

---

## 🐛 Troubleshooting

### Erro: "401 Invalid credentials"
**Solução:** Resetar admin
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/auth/reset-admin" -Method POST
```

### Erro: "Connection refused"
**Solução:** Verificar se serviços estão rodando
```powershell
cd infra/docker
docker-compose ps
docker-compose logs auth-service
```

### Erro: "500 Internal Server Error"
**Solução:** Verificar logs do serviço específico
```powershell
docker logs docker-auth-service-1
docker logs docker-student-service-1
docker logs docker-teacher-service-1
```

---

## 📊 Status dos Testes

| Script | Status | ADMIN | STUDENT | TEACHER | Observações |
|--------|--------|-------|---------|---------|-------------|
| test-all-routes.ps1 | ✅ | ✅ | - | - | **RECOMENDADO** |
| test-all-routes-rbac.ps1 | ⚠️ | ✅ | ❌ | ❌ | Usa ADMIN para tudo |
| test-routes-auth.ps1 | ✅ | ✅ | - | - | OK |
| test-rbac-complete.ps1 | ⚠️ | ✅ | ❌ | ❌ | Precisa users de teste |
| test-quick-rbac.ps1 | ⚠️ | ✅ | ❌ | - | Parcial |
| test-own-profile.ps1 | ⚠️ | ✅ | ❌ | ❌ | Retorna 404 (esperado) |
| test-me-endpoint.ps1 | ⚠️ | ✅ | ❌ | - | Retorna 404 (esperado) |
| test-admin-only-create.ps1 | ✅ | ✅ | - | - | Testa ADMIN vs SEM TOKEN |

**Legenda:**
- ✅ Funcionando perfeitamente
- ⚠️ Funciona mas com limitações
- ❌ Não funciona (requer implementação)
- `-` Não aplicável

---

**Última atualização:** 09/11/2025
