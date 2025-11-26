# Script de Teste Completo - Distrischool API Gateway
# Testa todas as rotas de todos os serviços através do Gateway com ADMIN

# Carregar System.Web para UrlEncode
Add-Type -AssemblyName System.Web

$gatewayUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

# Token ADMIN
$ADMIN_TOKEN = $null

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE COMPLETO - DISTRISCHOOL (ADMIN)" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Função para exibir resultado
function Show-Result {
    param($title, $result, $error)
    if ($error) {
        Write-Host "❌ $title - FALHOU" -ForegroundColor Red
        Write-Host "   Erro: $error" -ForegroundColor DarkRed
    } else {
        Write-Host "✅ $title - OK" -ForegroundColor Green
        if ($result) {
            $result | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
        }
    }
}

# ==================== AUTENTICAÇÃO ====================
Write-Host "`n[0] AUTENTICAÇÃO ADMIN" -ForegroundColor Cyan
try {
    $loginBody = @{
        email = "admin@distrischool.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$gatewayUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody
    
    $ADMIN_TOKEN = $response.token
    Write-Host "✅ Login ADMIN realizado com sucesso!" -ForegroundColor Green
    Write-Host "   Token: $($ADMIN_TOKEN.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ ERRO: Não foi possível fazer login como ADMIN" -ForegroundColor Red
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
    Write-Host "`n⚠️  Para criar um admin, use:" -ForegroundColor Yellow
    Write-Host "   POST /api/v1/admins" -ForegroundColor Gray
    exit 1
}

Start-Sleep -Seconds 1

# ==================== GATEWAY HEALTH ====================
Write-Host "`n[1] GATEWAY HEALTH CHECK" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/actuator/health" -Method GET
    Show-Result "Gateway Health" $result
} catch {
    Show-Result "Gateway Health" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

# ==================== TEACHER SERVICE ====================
Write-Host "`n[2] TEACHER SERVICE - Listar Todos (ADMIN)" -ForegroundColor Cyan
try {
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers" -Method GET -Headers $headers
    Show-Result "GET /api/teachers" $result
} catch {
    Show-Result "GET /api/teachers" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[3] TEACHER SERVICE - Buscar por ID (ADMIN)" -ForegroundColor Cyan
try {
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers/6" -Method GET -Headers $headers
    Show-Result "GET /api/teachers/6" $result
} catch {
    Show-Result "GET /api/teachers/6" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[4] TEACHER SERVICE - Criar Novo (ADMIN)" -ForegroundColor Cyan
try {
    $body = @{
        nome = "Professor PowerShell Test"
        matricula = "PROF2025001"
        qualificacao = "Mestrado em Automacao"
        contato = "85933334444"
    } | ConvertTo-Json
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers" -Method POST -Body $body -ContentType "application/json" -Headers $headers
    $global:newTeacherId = $result.id
    Show-Result "POST /api/teachers" $result
} catch {
    Show-Result "POST /api/teachers" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[4.1] TEACHER SERVICE - Test GET /api/alunos as TEACHER" -ForegroundColor Cyan
try {
    $loginBody = @{
        email = "professor.teste.prof.60@unifor.br"
        password = "77037428"
    } | ConvertTo-Json
    $teacherLogin = Invoke-RestMethod -Uri "$gatewayUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $TEACHER_TOKEN = $teacherLogin.token
    $headers = @{ "Authorization" = "Bearer $TEACHER_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method GET -Headers $headers
    Show-Result "GET /api/alunos (TEACHER)" $result

    # Test GET by ID (13 is an id present in test DB - adjust if needed)
    $result2 = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/13" -Method GET -Headers $headers
    Show-Result "GET /api/alunos/13 (TEACHER)" $result2
} catch {
    Show-Result "GET /api/alunos (TEACHER)" $null $_.Exception.Message
}

Write-Host "`n[5] TEACHER SERVICE - Atualizar (ADMIN)" -ForegroundColor Cyan
if ($global:newTeacherId) {
    try {
        $body = @{
            nome = "Professor PowerShell ATUALIZADO"
            matricula = "PROF2025001"
            qualificacao = "Doutorado em Automacao"
            contato = "85944445555"
        } | ConvertTo-Json
        $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers/$global:newTeacherId" -Method PUT -Body $body -ContentType "application/json" -Headers $headers
        Show-Result "PUT /api/teachers/$global:newTeacherId" $result
    } catch {
        Show-Result "PUT /api/teachers/$global:newTeacherId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando UPDATE - nenhum professor foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== STUDENT SERVICE ====================
Write-Host "`n[6] STUDENT SERVICE - Listar Todos (ADMIN)" -ForegroundColor Cyan
try {
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method GET -Headers $headers
    Show-Result "GET /api/alunos" $result
} catch {
    Show-Result "GET /api/alunos" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[7] STUDENT SERVICE - Buscar por ID (ADMIN)" -ForegroundColor Cyan
try {
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/13" -Method GET -Headers $headers
    Show-Result "GET /api/alunos/13" $result
} catch {
    Show-Result "GET /api/alunos/13" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[8] STUDENT SERVICE - Criar Novo (ADMIN)" -ForegroundColor Cyan
try {
    # Matrícula será gerada automaticamente pelo backend
    $body = @{
        nome = "Teste PowerShell Student"
        dataNascimento = "2005-03-15"
        endereco = "Rua Script, 123"
        contato = "85955556666"
        turma = "Turma Test PS"
        historicoAcademico = "Aluno de teste automatizado"
    } | ConvertTo-Json
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method POST -Body $body -ContentType "application/json" -Headers $headers
    $global:newStudentId = $result.id
    $global:newStudentTurma = "Turma Test PS"
    Show-Result "POST /api/alunos (matricula auto: $($result.matricula))" $result
} catch {
    Show-Result "POST /api/alunos" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[9] STUDENT SERVICE - Buscar por Turma (ADMIN)" -ForegroundColor Cyan
if ($global:newStudentTurma) {
    try {
        $turmaEncoded = [System.Web.HttpUtility]::UrlEncode($global:newStudentTurma)
        $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/turma/$turmaEncoded" -Method GET -Headers $headers
        Show-Result "GET /api/alunos/turma/$global:newStudentTurma" $result
    } catch {
        Write-Host "⚠️  GET /api/alunos/turma/$global:newStudentTurma - FALHOU (testando 3A)" -ForegroundColor Yellow
        try {
            $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
            $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/turma/3A" -Method GET -Headers $headers
            Show-Result "GET /api/alunos/turma/3A" $result
        } catch {
            Show-Result "GET /api/alunos/turma/3A" $null $_.Exception.Message
        }
    }
} else {
    Write-Host "⚠️  Pulando - nenhum aluno criado com turma" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== USER SERVICE ====================
Write-Host "`n[10] USER SERVICE - Listar Todos (ADMIN)" -ForegroundColor Cyan
try {
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/users" -Method GET -Headers $headers
    Show-Result "GET /api/v1/users" $result
} catch {
    Show-Result "GET /api/v1/users" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[11] USER SERVICE - Criar Novo (ADMIN)" -ForegroundColor Cyan
try {
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $body = @{
        fullName = "Test User PowerShell $random"
        email = "testuser$random@distrischool.com"
        password = "senha123"
        role = "STUDENT"
        enabled = $true
    } | ConvertTo-Json
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/users" -Method POST -Body $body -ContentType "application/json" -Headers $headers
    $global:newUserId = $result.id
    Show-Result "POST /api/v1/users" $result
} catch {
    Show-Result "POST /api/v1/users" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[12] USER SERVICE - Buscar por ID (ADMIN)" -ForegroundColor Cyan
if ($global:newUserId) {
    try {
        $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/users/$global:newUserId" -Method GET -Headers $headers
        Show-Result "GET /api/v1/users/$global:newUserId" $result
    } catch {
        Show-Result "GET /api/v1/users/$global:newUserId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando GET BY ID - nenhum usuário foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== ADMIN SERVICE ====================
Write-Host "`n[13] ADMIN SERVICE - Listar Todos (ADMIN)" -ForegroundColor Cyan
try {
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins" -Method GET -Headers $headers
    Show-Result "GET /api/v1/admins" $result
} catch {
    Show-Result "GET /api/v1/admins" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[14] ADMIN SERVICE - Criar Novo (ADMIN)" -ForegroundColor Cyan
try {
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $body = @{
        name = "Admin PowerShell Test $random"
        email = "admin$random@distrischool.com"
        role = "COORDINATOR"
        password = "admin123"
    } | ConvertTo-Json
    $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins" -Method POST -Body $body -ContentType "application/json" -Headers $headers
    $global:newAdminId = $result.id
    Show-Result "POST /api/v1/admins" $result
} catch {
    Show-Result "POST /api/v1/admins" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[15] ADMIN SERVICE - Buscar por ID (ADMIN)" -ForegroundColor Cyan
if ($global:newAdminId) {
    try {
        $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins/$global:newAdminId" -Method GET -Headers $headers
        Show-Result "GET /api/v1/admins/$global:newAdminId" $result
    } catch {
        Show-Result "GET /api/v1/admins/$global:newAdminId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando GET BY ID - nenhum admin foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

Write-Host "`n[16] ADMIN SERVICE - Atualizar (ADMIN)" -ForegroundColor Cyan
if ($global:newAdminId) {
    try {
        $random = Get-Random -Minimum 1000 -Maximum 9999
        $body = @{
            name = "Admin PowerShell UPDATED $random"
            email = "admin.updated$random@distrischool.com"
            role = "DIRECTOR"
            password = "admin456"
        } | ConvertTo-Json
        $headers = @{ "Authorization" = "Bearer $ADMIN_TOKEN" }
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins/$global:newAdminId" -Method PUT -Body $body -ContentType "application/json" -Headers $headers
        Show-Result "PUT /api/v1/admins/$global:newAdminId" $result
    } catch {
        Show-Result "PUT /api/v1/admins/$global:newAdminId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando UPDATE - nenhum admin foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== ACTUATOR ENDPOINTS ====================
Write-Host "`n[17] TEACHER SERVICE - Health Check" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/services/teacher/actuator/health" -Method GET
    Show-Result "GET /services/teacher/actuator/health" $result
} catch {
    Show-Result "GET /services/teacher/actuator/health" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[18] STUDENT SERVICE - Health Check" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/services/student/actuator/health" -Method GET
    Show-Result "GET /services/student/actuator/health" $result
} catch {
    Show-Result "GET /services/student/actuator/health" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[19] GATEWAY - Routes Info" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/actuator/gateway/routes" -Method GET
    Show-Result "GET /actuator/gateway/routes" $result
} catch {
    Show-Result "GET /actuator/gateway/routes" $null $_.Exception.Message
}

# ==================== RESUMO ====================
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO DOS TESTES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Total de testes: 19" -ForegroundColor White
Write-Host "`nIDs criados durante os testes:" -ForegroundColor Yellow
if ($global:newTeacherId) { Write-Host "  - Teacher ID: $global:newTeacherId" -ForegroundColor Gray }
if ($global:newStudentId) { Write-Host "  - Student ID: $global:newStudentId" -ForegroundColor Gray }
if ($global:newUserId) { Write-Host "  - User ID: $global:newUserId" -ForegroundColor Gray }
if ($global:newAdminId) { Write-Host "  - Admin ID: $global:newAdminId" -ForegroundColor Gray }
Write-Host "`nTestes concluídos!`n" -ForegroundColor Green
