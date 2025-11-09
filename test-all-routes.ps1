# Script de Teste Completo - Distrischool API Gateway
# Testa todas as rotas de todos os serviços através do Gateway

# Carregar System.Web para UrlEncode
Add-Type -AssemblyName System.Web

$gatewayUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE COMPLETO - DISTRISCHOOL API GATEWAY" -ForegroundColor Magenta
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
Write-Host "`n[2] TEACHER SERVICE - Listar Todos" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers" -Method GET
    Show-Result "GET /api/teachers" $result
} catch {
    Show-Result "GET /api/teachers" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[3] TEACHER SERVICE - Buscar por ID" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers/4" -Method GET
    Show-Result "GET /api/teachers/4" $result
} catch {
    Show-Result "GET /api/teachers/4" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[4] TEACHER SERVICE - Criar Novo" -ForegroundColor Cyan
try {
    $body = @{
        nome = "Professor PowerShell Test"
        matricula = "PROF2025001"
        qualificacao = "Mestrado em Automacao"
        contato = "85933334444"
    } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers" -Method POST -Body $body -ContentType "application/json"
    $global:newTeacherId = $result.id
    Show-Result "POST /api/teachers" $result
} catch {
    Show-Result "POST /api/teachers" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[5] TEACHER SERVICE - Atualizar" -ForegroundColor Cyan
if ($global:newTeacherId) {
    try {
        $body = @{
            nome = "Professor PowerShell ATUALIZADO"
            matricula = "PROF2025001"
            qualificacao = "Doutorado em Automacao"
            contato = "85944445555"
        } | ConvertTo-Json
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers/$global:newTeacherId" -Method PUT -Body $body -ContentType "application/json"
        Show-Result "PUT /api/teachers/$global:newTeacherId" $result
    } catch {
        Show-Result "PUT /api/teachers/$global:newTeacherId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando UPDATE - nenhum professor foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== STUDENT SERVICE ====================
Write-Host "`n[6] STUDENT SERVICE - Listar Todos" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method GET
    Show-Result "GET /api/alunos" $result
} catch {
    Write-Host "⚠️  GET /api/alunos - Circuit Breaker aberto, tentando novamente em 10s..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    try {
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method GET
        Show-Result "GET /api/alunos (retry)" $result
    } catch {
        Show-Result "GET /api/alunos" $null "Circuit Breaker - Serviço sobrecarregado"
    }
}

Start-Sleep -Seconds 1

Write-Host "`n[7] STUDENT SERVICE - Buscar por ID" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/1" -Method GET
    Show-Result "GET /api/alunos/3" $result
} catch {
    Show-Result "GET /api/alunos/3" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[8] STUDENT SERVICE - Criar Novo" -ForegroundColor Cyan
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
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method POST -Body $body -ContentType "application/json"
    $global:newStudentId = $result.id
    $global:newStudentTurma = "Turma Test PS"
    Show-Result "POST /api/alunos (matricula auto: $($result.matricula))" $result
} catch {
    Show-Result "POST /api/alunos" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[9] STUDENT SERVICE - Buscar por Turma" -ForegroundColor Cyan
if ($global:newStudentTurma) {
    try {
        $turmaEncoded = [System.Web.HttpUtility]::UrlEncode($global:newStudentTurma)
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/turma/$turmaEncoded" -Method GET
        Show-Result "GET /api/alunos/turma/$global:newStudentTurma" $result
    } catch {
        Write-Host "⚠️  GET /api/alunos/turma/$global:newStudentTurma - FALHOU (testando 3A)" -ForegroundColor Yellow
        try {
            $result = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos/turma/3A" -Method GET
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
Write-Host "`n[10] USER SERVICE - Listar Todos" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/users" -Method GET
    Show-Result "GET /api/v1/users" $result
} catch {
    Show-Result "GET /api/v1/users" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[11] USER SERVICE - Criar Novo" -ForegroundColor Cyan
try {
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $body = @{
        fullName = "Test User PowerShell $random"
        email = "testuser$random@distrischool.com"
        password = "senha123"
        role = "STUDENT"
        enabled = $true
    } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/users" -Method POST -Body $body -ContentType "application/json"
    $global:newUserId = $result.id
    Show-Result "POST /api/v1/users" $result
} catch {
    Show-Result "POST /api/v1/users" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[12] USER SERVICE - Buscar por ID" -ForegroundColor Cyan
if ($global:newUserId) {
    try {
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/users/$global:newUserId" -Method GET
        Show-Result "GET /api/v1/users/$global:newUserId" $result
    } catch {
        Show-Result "GET /api/v1/users/$global:newUserId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando GET BY ID - nenhum usuário foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# ==================== ADMIN SERVICE ====================
Write-Host "`n[13] ADMIN SERVICE - Listar Todos" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins" -Method GET
    Show-Result "GET /api/v1/admins" $result
} catch {
    Show-Result "GET /api/v1/admins" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[14] ADMIN SERVICE - Criar Novo" -ForegroundColor Cyan
try {
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $body = @{
        name = "Admin PowerShell Test $random"
        email = "admin$random@distrischool.com"
        role = "COORDINATOR"
        password = "admin123"
    } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins" -Method POST -Body $body -ContentType "application/json"
    $global:newAdminId = $result.id
    Show-Result "POST /api/v1/admins" $result
} catch {
    Show-Result "POST /api/v1/admins" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[15] ADMIN SERVICE - Buscar por ID" -ForegroundColor Cyan
if ($global:newAdminId) {
    try {
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins/$global:newAdminId" -Method GET
        Show-Result "GET /api/v1/admins/$global:newAdminId" $result
    } catch {
        Show-Result "GET /api/v1/admins/$global:newAdminId" $null $_.Exception.Message
    }
} else {
    Write-Host "⚠️  Pulando GET BY ID - nenhum admin foi criado" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

Write-Host "`n[16] ADMIN SERVICE - Atualizar" -ForegroundColor Cyan
if ($global:newAdminId) {
    try {
        $random = Get-Random -Minimum 1000 -Maximum 9999
        $body = @{
            name = "Admin PowerShell UPDATED $random"
            email = "admin.updated$random@distrischool.com"
            role = "DIRECTOR"
            password = "admin456"
        } | ConvertTo-Json
        $result = Invoke-RestMethod -Uri "$gatewayUrl/api/v1/admins/$global:newAdminId" -Method PUT -Body $body -ContentType "application/json"
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

Write-Host "`n[19] USER SERVICE - Health Check" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/services/user/actuator/health" -Method GET
    Show-Result "GET /services/user/actuator/health" $result
} catch {
    Show-Result "GET /services/user/actuator/health" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[20] ADMIN SERVICE - Health Check" -ForegroundColor Cyan
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/services/admin/actuator/health" -Method GET
    Show-Result "GET /services/admin/actuator/health" $result
} catch {
    Show-Result "GET /services/admin/actuator/health" $null $_.Exception.Message
}

Start-Sleep -Seconds 1

Write-Host "`n[21] GATEWAY - Routes Info" -ForegroundColor Cyan
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
Write-Host "Total de testes: 21" -ForegroundColor White
Write-Host "`nIDs criados durante os testes:" -ForegroundColor Yellow
if ($global:newTeacherId) { Write-Host "  - Teacher ID: $global:newTeacherId" -ForegroundColor Gray }
if ($global:newStudentId) { Write-Host "  - Student ID: $global:newStudentId" -ForegroundColor Gray }
if ($global:newUserId) { Write-Host "  - User ID: $global:newUserId" -ForegroundColor Gray }
if ($global:newAdminId) { Write-Host "  - Admin ID: $global:newAdminId" -ForegroundColor Gray }
Write-Host "`nTestes concluídos!`n" -ForegroundColor Green
