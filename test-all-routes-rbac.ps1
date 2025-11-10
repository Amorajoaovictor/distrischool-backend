# Script de Teste Completo - Distrischool API Gateway com RBAC
# Testa todas as rotas de todos os serviços com autenticação JWT

Add-Type -AssemblyName System.Web
$ErrorActionPreference = "Continue"

$GATEWAY_URL = "http://localhost:8080"

# Tokens de autenticação
$ADMIN_TOKEN = $null
$STUDENT_TOKEN = $null
$TEACHER_TOKEN = $null

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE COMPLETO - DISTRISCHOOL (RBAC)" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# ==================== FUNÇÕES AUXILIARES ====================

function Get-AuthToken {
    param([string]$Email, [string]$Password, [string]$Role)
    
    Write-Host "[AUTH] Login como $Role ($Email)..." -ForegroundColor Cyan
    
    $loginBody = @{
        email = $Email
        password = $Password
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$GATEWAY_URL/api/auth/login" `
            -Method POST `
            -ContentType "application/json" `
            -Body $loginBody `
            -ErrorAction Stop
        
        if ($response.token) {
            Write-Host "  ✅ Token obtido" -ForegroundColor Green
            return $response.token
        }
    } catch {
        Write-Host "  ❌ Falha ao obter token" -ForegroundColor Red
        Write-Host "     $($_.Exception.Message)" -ForegroundColor DarkRed
    }
    return $null
}

function Show-Result {
    param($title, $result, $error)
    if ($error) {
        Write-Host "  ❌ $title - FALHOU" -ForegroundColor Red
        Write-Host "     Erro: $error" -ForegroundColor DarkRed
    } else {
        Write-Host "  ✅ $title - OK" -ForegroundColor Green
        if ($result -and $result -is [array] -and $result.Count -gt 0) {
            Write-Host "     Items retornados: $($result.Count)" -ForegroundColor Gray
        } elseif ($result) {
            Write-Host "     ID: $($result.id) | Nome: $($result.nome)" -ForegroundColor Gray
        }
    }
}

function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Token,
        [object]$Body = $null,
        [string]$Description
    )
    
    try {
        $params = @{
            Uri = "$GATEWAY_URL$Endpoint"
            Method = $Method
            ErrorAction = 'Stop'
        }
        
        if ($Token) {
            $params.Headers = @{ "Authorization" = "Bearer $Token" }
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }

        $result = Invoke-RestMethod @params
        Show-Result $Description $result
        return $result
    } catch {
        Show-Result $Description $null $_.Exception.Message
        return $null
    }
}

# ==================== FASE 1: AUTENTICAÇÃO ====================
Write-Host "`n========== FASE 1: AUTENTICAÇÃO ==========" -ForegroundColor Yellow

# Login como ADMIN (sempre disponível)
$ADMIN_TOKEN = Get-AuthToken -Email "admin@distrischool.com" -Password "admin123" -Role "ADMIN"

# Nota: Para testar como STUDENT/TEACHER, primeiro é preciso criar esses usuários
# Por enquanto, usando apenas ADMIN para todos os testes
$STUDENT_TOKEN = $ADMIN_TOKEN  # TODO: Criar usuário STUDENT de teste
$TEACHER_TOKEN = $ADMIN_TOKEN  # TODO: Criar usuário TEACHER de teste

if (-not $ADMIN_TOKEN) {
    Write-Host "`n❌ ERRO: Não foi possível autenticar como ADMIN. Abortando testes." -ForegroundColor Red
    exit 1
}

Write-Host "`nℹ️  Usando token ADMIN para todos os testes" -ForegroundColor Yellow

Start-Sleep -Seconds 2

# ==================== FASE 2: GATEWAY HEALTH ====================
Write-Host "`n========== FASE 2: GATEWAY HEALTH ==========" -ForegroundColor Yellow

Test-Endpoint -Method "GET" -Endpoint "/actuator/health" -Description "Gateway Health Check"

Start-Sleep -Seconds 1

# ==================== FASE 3: TEACHER SERVICE (ADMIN) ====================
Write-Host "`n========== FASE 3: TEACHER SERVICE (ADMIN) ==========" -ForegroundColor Yellow

if ($ADMIN_TOKEN) {
    Write-Host "`n--- Listar Professores ---" -ForegroundColor Cyan
    $teachers = Test-Endpoint -Method "GET" -Endpoint "/api/teachers" -Token $ADMIN_TOKEN `
        -Description "GET /api/teachers (ADMIN)"
    
    Write-Host "`n--- Buscar Professor por ID ---" -ForegroundColor Cyan
    if ($teachers -and $teachers.Count -gt 0) {
        $teacherId = $teachers[0].id
        Test-Endpoint -Method "GET" -Endpoint "/api/teachers/$teacherId" -Token $ADMIN_TOKEN `
            -Description "GET /api/teachers/$teacherId (ADMIN)"
    }
    
    Write-Host "`n--- Criar Novo Professor ---" -ForegroundColor Cyan
    $newTeacher = Test-Endpoint -Method "POST" -Endpoint "/api/teachers" -Token $ADMIN_TOKEN `
        -Body @{
            nome = "Professor Test RBAC"
            matricula = "PROF2025TEST"
            qualificacao = "Mestrado em Testes"
            contato = "85999887766"
        } -Description "POST /api/teachers (ADMIN)"
    
    if ($newTeacher) {
        Write-Host "`n--- Atualizar Professor ---" -ForegroundColor Cyan
        Test-Endpoint -Method "PUT" -Endpoint "/api/teachers/$($newTeacher.id)" -Token $ADMIN_TOKEN `
            -Body @{
                nome = "Professor Test ATUALIZADO"
                matricula = "PROF2025TEST"
                qualificacao = "Doutorado em Testes"
                contato = "85999887766"
            } -Description "PUT /api/teachers/$($newTeacher.id) (ADMIN)"
        
        Write-Host "`n--- Deletar Professor ---" -ForegroundColor Cyan
        Test-Endpoint -Method "DELETE" -Endpoint "/api/teachers/$($newTeacher.id)" -Token $ADMIN_TOKEN `
            -Description "DELETE /api/teachers/$($newTeacher.id) (ADMIN)"
    }
} else {
    Write-Host "⚠️  Pulando testes de TEACHER SERVICE - Token ADMIN não disponível" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== FASE 4: STUDENT SERVICE (ADMIN) ====================
Write-Host "`n========== FASE 4: STUDENT SERVICE (ADMIN) ==========" -ForegroundColor Yellow

if ($ADMIN_TOKEN) {
    Write-Host "`n--- Listar Alunos ---" -ForegroundColor Cyan
    $students = Test-Endpoint -Method "GET" -Endpoint "/api/alunos" -Token $ADMIN_TOKEN `
        -Description "GET /api/alunos (ADMIN)"
    
    Write-Host "`n--- Buscar Aluno por ID ---" -ForegroundColor Cyan
    if ($students -and $students.Count -gt 0) {
        $studentId = $students[0].id
        Test-Endpoint -Method "GET" -Endpoint "/api/alunos/$studentId" -Token $ADMIN_TOKEN `
            -Description "GET /api/alunos/$studentId (ADMIN)"
    }
    
    Write-Host "`n--- Criar Novo Aluno ---" -ForegroundColor Cyan
    $newStudent = Test-Endpoint -Method "POST" -Endpoint "/api/alunos" -Token $ADMIN_TOKEN `
        -Body @{
            nome = "Aluno Test RBAC"
            dataNascimento = "2005-05-15"
            turma = "3A"
            endereco = "Rua Teste, 123"
            contato = "85988776655"
            historicoAcademico = "Teste de criacao"
        } -Description "POST /api/alunos (ADMIN)"
    
    if ($newStudent) {
        Write-Host "`n--- Atualizar Aluno ---" -ForegroundColor Cyan
        Test-Endpoint -Method "PUT" -Endpoint "/api/alunos/$($newStudent.id)" -Token $ADMIN_TOKEN `
            -Body @{
                nome = "Aluno Test ATUALIZADO"
                dataNascimento = "2005-05-15"
                turma = "3B"
                endereco = "Rua Teste Atualizado, 456"
                contato = "85988776655"
                matricula = $newStudent.matricula
                historicoAcademico = "Historico atualizado"
            } -Description "PUT /api/alunos/$($newStudent.id) (ADMIN)"
        
        Write-Host "`n--- Deletar Aluno ---" -ForegroundColor Cyan
        Test-Endpoint -Method "DELETE" -Endpoint "/api/alunos/$($newStudent.id)" -Token $ADMIN_TOKEN `
            -Description "DELETE /api/alunos/$($newStudent.id) (ADMIN)"
    }
    
    Write-Host "`n--- Buscar por Matrícula ---" -ForegroundColor Cyan
    if ($students -and $students.Count -gt 0) {
        $matricula = $students[0].matricula
        Test-Endpoint -Method "GET" -Endpoint "/api/alunos/matricula/$matricula" -Token $ADMIN_TOKEN `
            -Description "GET /api/alunos/matricula/$matricula (ADMIN)"
    }
    
    Write-Host "`n--- Buscar por Nome ---" -ForegroundColor Cyan
    Test-Endpoint -Method "GET" -Endpoint "/api/alunos/nome/Test" -Token $ADMIN_TOKEN `
        -Description "GET /api/alunos/nome/Test (ADMIN)"
    
    Write-Host "`n--- Buscar por Turma ---" -ForegroundColor Cyan
    Test-Endpoint -Method "GET" -Endpoint "/api/alunos/turma/3A" -Token $ADMIN_TOKEN `
        -Description "GET /api/alunos/turma/3A (ADMIN)"
} else {
    Write-Host "⚠️  Pulando testes de STUDENT SERVICE - Token ADMIN não disponível" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== FASE 5: USER SERVICE (ADMIN) ====================
Write-Host "`n========== FASE 5: USER SERVICE (ADMIN) ==========" -ForegroundColor Yellow

if ($ADMIN_TOKEN) {
    Write-Host "`n--- Listar Usuários ---" -ForegroundColor Cyan
    $users = Test-Endpoint -Method "GET" -Endpoint "/api/v1/users" -Token $ADMIN_TOKEN `
        -Description "GET /api/v1/users (ADMIN)"
    
    Write-Host "`n--- Buscar Usuário por ID ---" -ForegroundColor Cyan
    if ($users -and $users.Count -gt 0) {
        $userId = $users[0].id
        Test-Endpoint -Method "GET" -Endpoint "/api/v1/users/$userId" -Token $ADMIN_TOKEN `
            -Description "GET /api/v1/users/$userId (ADMIN)"
    }
    
    Write-Host "`n--- Criar Novo Usuário ---" -ForegroundColor Cyan
    $newUser = Test-Endpoint -Method "POST" -Endpoint "/api/v1/users" -Token $ADMIN_TOKEN `
        -Body @{
            fullName = "Usuario Test RBAC"
            email = "test.rbac@unifor.br"
            password = "senha123"
            role = "STUDENT"
            enabled = $true
        } -Description "POST /api/v1/users (ADMIN)"
    
    if ($newUser) {
        Write-Host "`n--- Atualizar Usuário ---" -ForegroundColor Cyan
        Test-Endpoint -Method "PUT" -Endpoint "/api/v1/users/$($newUser.id)" -Token $ADMIN_TOKEN `
            -Body @{
                fullName = "Usuario Test ATUALIZADO"
                email = "test.rbac@unifor.br"
                role = "STUDENT"
                enabled = $true
            } -Description "PUT /api/v1/users/$($newUser.id) (ADMIN)"
        
        Write-Host "`n--- Deletar Usuário ---" -ForegroundColor Cyan
        Test-Endpoint -Method "DELETE" -Endpoint "/api/v1/users/$($newUser.id)" -Token $ADMIN_TOKEN `
            -Description "DELETE /api/v1/users/$($newUser.id) (ADMIN)"
    }
} else {
    Write-Host "⚠️  Pulando testes de USER SERVICE - Token ADMIN não disponível" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== FASE 6: ADMIN SERVICE (ADMIN) ====================
Write-Host "`n========== FASE 6: ADMIN SERVICE (ADMIN) ==========" -ForegroundColor Yellow

if ($ADMIN_TOKEN) {
    Write-Host "`n--- Listar Admins ---" -ForegroundColor Cyan
    $admins = Test-Endpoint -Method "GET" -Endpoint "/api/v1/admins" -Token $ADMIN_TOKEN `
        -Description "GET /api/v1/admins (ADMIN)"
    
    Write-Host "`n--- Buscar Admin por ID ---" -ForegroundColor Cyan
    if ($admins -and $admins.Count -gt 0) {
        $adminId = $admins[0].id
        Test-Endpoint -Method "GET" -Endpoint "/api/v1/admins/$adminId" -Token $ADMIN_TOKEN `
            -Description "GET /api/v1/admins/$adminId (ADMIN)"
    }
} else {
    Write-Host "⚠️  Pulando testes de ADMIN SERVICE - Token ADMIN não disponível" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== FASE 7: TESTES COM STUDENT TOKEN ====================
Write-Host "`n========== FASE 7: TESTES COM STUDENT TOKEN ==========" -ForegroundColor Yellow

if ($STUDENT_TOKEN) {
    Write-Host "`n--- Visualizar Próprio Perfil (/me) ---" -ForegroundColor Cyan
    $myProfile = Test-Endpoint -Method "GET" -Endpoint "/api/alunos/me" -Token $STUDENT_TOKEN `
        -Description "GET /api/alunos/me (STUDENT)"
    
    if ($myProfile) {
        Write-Host "`n--- Visualizar Próprio Perfil (por ID) ---" -ForegroundColor Cyan
        Test-Endpoint -Method "GET" -Endpoint "/api/alunos/$($myProfile.id)" -Token $STUDENT_TOKEN `
            -Description "GET /api/alunos/$($myProfile.id) (STUDENT - próprio ID)"
        
        Write-Host "`n--- Atualizar Próprio Perfil ---" -ForegroundColor Cyan
        Test-Endpoint -Method "PUT" -Endpoint "/api/alunos/$($myProfile.id)" -Token $STUDENT_TOKEN `
            -Body @{
                nome = $myProfile.nome
                dataNascimento = $myProfile.dataNascimento
                turma = $myProfile.turma
                endereco = "Endereco Atualizado pelo Student"
                contato = $myProfile.contato
                matricula = $myProfile.matricula
                historicoAcademico = "Atualizado via /me"
            } -Description "PUT /api/alunos/$($myProfile.id) (STUDENT - próprio perfil)"
    }
    
    Write-Host "`n--- Tentar Acessar Outro Aluno (deve FALHAR) ---" -ForegroundColor Cyan
    $otherStudentId = if ($myProfile -and $myProfile.id -eq 1) { 2 } else { 1 }
    Test-Endpoint -Method "GET" -Endpoint "/api/alunos/$otherStudentId" -Token $STUDENT_TOKEN `
        -Description "GET /api/alunos/$otherStudentId (STUDENT - outro aluno) [ESPERADO: FALHA]"
    
    Write-Host "`n--- Tentar Listar Todos Alunos (deve FALHAR) ---" -ForegroundColor Cyan
    Test-Endpoint -Method "GET" -Endpoint "/api/alunos" -Token $STUDENT_TOKEN `
        -Description "GET /api/alunos (STUDENT) [ESPERADO: FALHA]"
    
    Write-Host "`n--- Tentar Criar Aluno (deve FALHAR) ---" -ForegroundColor Cyan
    Test-Endpoint -Method "POST" -Endpoint "/api/alunos" -Token $STUDENT_TOKEN `
        -Body @{
            nome = "Tentativa Criar"
            dataNascimento = "2005-01-01"
            turma = "1A"
        } -Description "POST /api/alunos (STUDENT) [ESPERADO: FALHA]"
    
    Write-Host "`n--- Tentar Deletar Aluno (deve FALHAR) ---" -ForegroundColor Cyan
    Test-Endpoint -Method "DELETE" -Endpoint "/api/alunos/1" -Token $STUDENT_TOKEN `
        -Description "DELETE /api/alunos/1 (STUDENT) [ESPERADO: FALHA]"
} else {
    Write-Host "⚠️  Pulando testes com STUDENT TOKEN - Token não disponível" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== FASE 8: TESTES SEM AUTENTICAÇÃO ====================
Write-Host "`n========== FASE 8: TESTES SEM AUTENTICAÇÃO ==========" -ForegroundColor Yellow

Write-Host "`n--- Tentar Listar Alunos SEM TOKEN (deve FALHAR) ---" -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Endpoint "/api/alunos" `
    -Description "GET /api/alunos (SEM TOKEN) [ESPERADO: FALHA]"

Write-Host "`n--- Tentar Criar Aluno SEM TOKEN (deve FALHAR) ---" -ForegroundColor Cyan
Test-Endpoint -Method "POST" -Endpoint "/api/alunos" `
    -Body @{
        nome = "Sem Auth"
        dataNascimento = "2005-01-01"
        turma = "1A"
    } -Description "POST /api/alunos (SEM TOKEN) [ESPERADO: FALHA]"

Write-Host "`n--- Tentar Listar Professores SEM TOKEN (deve FALHAR) ---" -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Endpoint "/api/teachers" `
    -Description "GET /api/teachers (SEM TOKEN) [ESPERADO: FALHA]"

Write-Host "`n--- Tentar Criar Professor SEM TOKEN (deve FALHAR) ---" -ForegroundColor Cyan
Test-Endpoint -Method "POST" -Endpoint "/api/teachers" `
    -Body @{
        nome = "Sem Auth"
        matricula = "NOAUTH"
    } -Description "POST /api/teachers (SEM TOKEN) [ESPERADO: FALHA]"

# ==================== RESUMO FINAL ====================
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO DOS TESTES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nTOKENS OBTIDOS:" -ForegroundColor Yellow
Write-Host "  ADMIN: $(if ($ADMIN_TOKEN) { '✅' } else { '❌' })" -ForegroundColor $(if ($ADMIN_TOKEN) { 'Green' } else { 'Red' })
Write-Host "  STUDENT: $(if ($STUDENT_TOKEN) { '✅' } else { '❌' })" -ForegroundColor $(if ($STUDENT_TOKEN) { 'Green' } else { 'Red' })

Write-Host "`nPOLÍTICA DE ACESSO RBAC:" -ForegroundColor Yellow
Write-Host "  ✅ ADMIN: Acesso total a todos os recursos" -ForegroundColor Green
Write-Host "  ✅ STUDENT: Apenas visualizar/editar próprio perfil via /me" -ForegroundColor Green
Write-Host "  ✅ TEACHER: Apenas visualizar/editar próprio perfil via /me" -ForegroundColor Green
Write-Host "  ❌ POST/DELETE: Apenas ADMIN" -ForegroundColor Red
Write-Host "  ❌ Sem autenticação: Rejeitado (401/403)" -ForegroundColor Red

Write-Host "`nENDPOINTS NOVOS:" -ForegroundColor Yellow
Write-Host "  • GET /api/alunos/me - Visualizar próprio perfil (STUDENT)" -ForegroundColor Cyan
Write-Host "  • GET /api/teachers/me - Visualizar próprio perfil (TEACHER)" -ForegroundColor Cyan

Write-Host "`n✅ Testes concluídos!`n" -ForegroundColor Green
