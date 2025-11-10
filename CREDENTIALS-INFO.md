# 🔐 Arquivo credentials.txt

## O que é?

O arquivo `credentials.txt` é **gerado automaticamente** pelo `auth-service` sempre que uma senha é criada ou gerada no sistema.

## 📍 Localização

```
distrischool/
└── credentials.txt  ← Raiz do projeto
```

## 📝 Formato do Arquivo

```
=================================================================================
DISTRISCHOOL - CREDENCIAIS GERADAS AUTOMATICAMENTE
=================================================================================
ATENÇÃO: Este arquivo contém senhas em texto plano.
         Mantenha-o seguro e NÃO commite no Git!
         Adicione 'credentials.txt' ao .gitignore
=================================================================================

TIMESTAMP           | TYPE        | EMAIL                          | PASSWORD                  | ROLE
---------------------------------------------------------------------------------
2025-11-10 14:30:45 | [PROVIDED]  | admin@distrischool.com         | admin123                  | ROLE_ADMIN
2025-11-10 14:31:12 | [GENERATED] | joao.silva.2025001@unifor.br   | 8a7f3b2c                  | ROLE_STUDENT
2025-11-10 14:31:15 | [GENERATED] | ana.pereira.PROF001@unifor.br  | 9d2e4f1a                  | ROLE_TEACHER
```

## 🔍 Quando as Credenciais São Salvas?

### 1. **Admin Padrão** (Startup)
Quando o `auth-service` inicia pela primeira vez:
```
Email: admin@distrischool.com
Password: admin123
Type: [PROVIDED]
```

### 2. **Usuários via Kafka** (Criação de Students/Teachers/Admins)
Quando um Student, Teacher ou Admin é criado via evento Kafka:
- Se **senha fornecida**: salva como `[PROVIDED]`
- Se **senha gerada**: salva como `[GENERATED]` + senha aleatória (8 caracteres)

### 3. **Reset Admin** (Endpoint /reset-admin)
Quando você chama `POST /api/auth/reset-admin`:
```
Email: admin@distrischool.com
Password: admin123
Type: [PROVIDED]
```

## ⚙️ Como Funciona?

### 1. DataInitializer (Startup)
```java
// auth-service inicia
DataInitializer.run()
  → Cria admin@distrischool.com
  → Salva em credentials.txt
```

### 2. Kafka Events (Students/Teachers criados)
```java
// Student/Teacher criado em outro serviço
StudentService.create()
  → Publica evento Kafka
  → UserEventListener recebe
  → Gera senha aleatória (se não fornecida)
  → Salva em credentials.txt
```

### 3. Reset Admin (Manual)
```bash
curl -X POST http://localhost:8080/api/auth/reset-admin
  → AuthService.resetAdminUser()
  → Salva em credentials.txt
```

## 🔒 Segurança

### ⚠️ ATENÇÃO

1. **NÃO commite no Git!**
   - Já está no `.gitignore`
   - Contém senhas em texto plano

2. **Apenas para desenvolvimento!**
   - Não use em produção
   - Não compartilhe o arquivo

3. **Permissões de arquivo**
   ```bash
   # Linux/Mac: restrinja permissões
   chmod 600 credentials.txt
   ```

## 📖 Uso Prático

### Ver todas as credenciais geradas
```powershell
Get-Content credentials.txt
```

### Filtrar por tipo
```powershell
# Apenas senhas geradas automaticamente
Get-Content credentials.txt | Select-String "GENERATED"

# Apenas senhas fornecidas
Get-Content credentials.txt | Select-String "PROVIDED"
```

### Buscar credencial específica
```powershell
Get-Content credentials.txt | Select-String "joao.silva"
```

### Copiar última senha gerada
```powershell
(Get-Content credentials.txt | Select-String "GENERATED" | Select-Object -Last 1) -replace '.*\| ([a-z0-9]+) +\|.*', '$1'
```

## 🧪 Exemplo de Teste

Depois de criar um aluno:

```powershell
# 1. Criar aluno
$token = (Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST -Body '{"email":"admin@distrischool.com","password":"admin123"}' `
    -ContentType "application/json").token

Invoke-RestMethod -Uri "http://localhost:8080/api/alunos" `
    -Method POST `
    -Headers @{"Authorization"="Bearer $token"} `
    -Body '{"nome":"João Silva","dataNascimento":"2005-01-01","turma":"3A",...}' `
    -ContentType "application/json"

# 2. Ver senha gerada
Get-Content credentials.txt | Select-String "joao.silva"

# Saída:
# 2025-11-10 14:31:12 | [GENERATED] | joao.silva.2025001@unifor.br   | 8a7f3b2c                  | ROLE_STUDENT

# 3. Fazer login como estudante
Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body '{"email":"joao.silva.2025001@unifor.br","password":"8a7f3b2c"}' `
    -ContentType "application/json"
```

## 🗑️ Limpar Arquivo

Para limpar todas as credenciais salvas:

```powershell
Remove-Item credentials.txt
```

O arquivo será recriado na próxima inicialização do `auth-service`.

## 📊 Benefícios

✅ **Rastreabilidade**: Todas as senhas geradas são registradas  
✅ **Testes**: Facilita testes com usuários STUDENT/TEACHER  
✅ **Debug**: Identifica problemas de autenticação  
✅ **Auditoria**: Histórico de quando cada usuário foi criado  

## ⚙️ Configuração

Você pode mudar o caminho do arquivo em `application.properties`:

```properties
# auth-service/src/main/resources/application.properties
credentials.file.path=credentials.txt
```

---

**Última atualização:** 10/11/2025
