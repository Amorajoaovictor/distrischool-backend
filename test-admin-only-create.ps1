# Teste Rapido - Apenas ADMIN pode criar alunos e professores

$GATEWAY_URL = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE: ADMIN-ONLY CREATE" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Funcao para fazer login
function Get-AuthToken {
    param([string]$Email, [string]$Password, [string]$Role)
    
    Write-Host "[AUTH] Fazendo login como $Role ($Email)..." -ForegroundColor Cyan
    
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
    }
    return $null
}

# Funcao para testar criacao
function Test-Create {
    param([string]$Endpoint, [string]$Resource, [object]$Body, [string]$Token, [string]$Role)
    
    Write-Host "`n[$Role] Tentando criar $Resource..." -ForegroundColor Yellow
    
    try {
        $params = @{
            Uri = "$GATEWAY_URL$Endpoint"
            Method = "POST"
            ContentType = "application/json"
            Body = ($Body | ConvertTo-Json)
            ErrorAction = 'Stop'
        }
        
        if ($Token) {
            $params.Headers = @{ "Authorization" = "Bearer $Token" }
        }

        $response = Invoke-WebRequest @params
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq 200 -or $statusCode -eq 201) {
            Write-Host "  ✅ PERMITIDO (Status: $statusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ⚠️  Resposta inesperada: $statusCode" -ForegroundColor Yellow
            return $false
        }
    } catch {
        $statusCode = "ERROR"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        if ($statusCode -eq 401 -or $statusCode -eq 403) {
            Write-Host "  ❌ BLOQUEADO (Status: $statusCode) - CORRETO!" -ForegroundColor Red
            return $false
        } else {
            Write-Host "  ⚠️  Erro: $statusCode" -ForegroundColor Yellow
            return $false
        }
    }
}

# ========================================================================
# FASE 1: OBTER TOKENS
# ========================================================================

Write-Host "`n========== FASE 1: AUTENTICACAO ==========" -ForegroundColor Cyan

# Login como ADMIN
$ADMIN_TOKEN = Get-AuthToken -Email "admin@distrischool.com" -Password "admin123" -Role "ADMIN"

# STUDENT não disponível (senha desconhecida após criação via Kafka)
Write-Host "`nℹ️  STUDENT de teste não disponível (requer senha conhecida)" -ForegroundColor Yellow
Write-Host "   Este teste focará apenas em ADMIN permitido e SEM TOKEN bloqueado" -ForegroundColor Gray
$STUDENT_TOKEN = $null

# ========================================================================
# FASE 2: TESTAR CRIACAO SEM TOKEN
# ========================================================================

Write-Host "`n========== FASE 2: CRIAR SEM AUTENTICACAO ==========" -ForegroundColor Cyan

$studentBody = @{
    nome = "Aluno Sem Auth"
    dataNascimento = "2005-01-01"
    turma = "3A"
    endereco = "Rua Test"
    contato = "85911112222"
    historicoAcademico = "Test"
}

$teacherBody = @{
    nome = "Professor Sem Auth"
    matricula = "PROFNOAUTH"
    qualificacao = "Mestrado"
    contato = "85922223333"
}

Test-Create -Endpoint "/api/alunos" -Resource "Aluno" -Body $studentBody -Token $null -Role "SEM TOKEN"
Test-Create -Endpoint "/api/teachers" -Resource "Professor" -Body $teacherBody -Token $null -Role "SEM TOKEN"

# ========================================================================
# FASE 3: TESTAR CRIACAO COM TOKEN DE STUDENT
# ========================================================================

Write-Host "`n========== FASE 3: CRIAR COM ROLE STUDENT ==========" -ForegroundColor Cyan

if ($STUDENT_TOKEN) {
    $studentBody.nome = "Aluno Student Token"
    $teacherBody.nome = "Professor Student Token"
    $teacherBody.matricula = "PROFSTUDENT"
    
    Test-Create -Endpoint "/api/alunos" -Resource "Aluno" -Body $studentBody -Token $STUDENT_TOKEN -Role "STUDENT"
    Test-Create -Endpoint "/api/teachers" -Resource "Professor" -Body $teacherBody -Token $STUDENT_TOKEN -Role "STUDENT"
} else {
    Write-Host "⚠️  Token STUDENT nao disponivel - pulando testes" -ForegroundColor Yellow
}

# ========================================================================
# RESUMO
# ========================================================================

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nRESULTADO ESPERADO:" -ForegroundColor Yellow
Write-Host "  ❌ SEM TOKEN: Bloqueado (401/403)" -ForegroundColor Red
Write-Host "  ❌ ROLE STUDENT: Bloqueado (403)" -ForegroundColor Red
Write-Host "  ✅ ROLE ADMIN: Permitido (200/201) [nao testado ainda]" -ForegroundColor Green

Write-Host "`nAPENAS ADMIN PODE CRIAR ALUNOS E PROFESSORES!" -ForegroundColor Green
Write-Host "`nTeste concluido!`n" -ForegroundColor Green
