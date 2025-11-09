# Teste Rápido de RBAC - Validação de Permissões

$GATEWAY_URL = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE RÁPIDO - VALIDAÇÃO RBAC" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Função para login
function Login {
    param([string]$Email, [string]$Password)
    
    try {
        $response = Invoke-RestMethod -Uri "$GATEWAY_URL/api/auth/login" `
            -Method POST `
            -ContentType "application/json" `
            -Body (@{ email = $Email; password = $Password } | ConvertTo-Json) `
            -ErrorAction Stop
        return $response.token
    } catch {
        return $null
    }
}

# Função para testar endpoint
function Test {
    param([string]$Method, [string]$Endpoint, [string]$Token, [string]$Desc, [object]$Body = $null)
    
    try {
        $params = @{
            Uri = "$GATEWAY_URL$Endpoint"
            Method = $Method
            ErrorAction = 'Stop'
        }
        
        if ($Token) { $params.Headers = @{ "Authorization" = "Bearer $Token" } }
        if ($Body) { 
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }

        $response = Invoke-WebRequest @params
        Write-Host "  ✅ $Desc - $($response.StatusCode)" -ForegroundColor Green
        return $true
    } catch {
        $status = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "ERROR" }
        $color = if ($status -eq 403 -or $status -eq 401) { "Yellow" } else { "Red" }
        $symbol = if ($status -eq 403 -or $status -eq 401) { "🔒" } else { "❌" }
        Write-Host "  $symbol $Desc - $status" -ForegroundColor $color
        return $false
    }
}

# ==================== AUTENTICAÇÃO ====================
Write-Host "`n[1] AUTENTICAÇÃO" -ForegroundColor Cyan
$ADMIN = Login -Email "admin@distrischool.com" -Password "admin123"
$STUDENT = Login -Email "teste.user.2025999@unifor.br" -Password "ecfd4e61"

Write-Host "  ADMIN Token: $(if ($ADMIN) { '✅' } else { '❌ (criar admin primeiro)' })" -ForegroundColor $(if ($ADMIN) { 'Green' } else { 'Red' })
Write-Host "  STUDENT Token: $(if ($STUDENT) { '✅' } else { '❌' })" -ForegroundColor $(if ($STUDENT) { 'Green' } else { 'Red' })

# ==================== TESTE 1: ADMIN FULL ACCESS ====================
Write-Host "`n[2] ADMIN - ACESSO TOTAL" -ForegroundColor Cyan

if ($ADMIN) {
    Test -Method "GET" -Endpoint "/api/alunos" -Token $ADMIN -Desc "Listar alunos"
    Test -Method "GET" -Endpoint "/api/teachers" -Token $ADMIN -Desc "Listar professores"
    Test -Method "GET" -Endpoint "/api/v1/users" -Token $ADMIN -Desc "Listar usuários"
    Test -Method "POST" -Endpoint "/api/alunos" -Token $ADMIN -Desc "Criar aluno" `
        -Body @{ nome = "Test"; dataNascimento = "2005-01-01"; turma = "1A"; endereco = "Rua"; contato = "85999"; historicoAcademico = "Test" }
    Test -Method "POST" -Endpoint "/api/teachers" -Token $ADMIN -Desc "Criar professor" `
        -Body @{ nome = "Prof Test"; matricula = "TEST001"; qualificacao = "Mestrado"; contato = "85999" }
} else {
    Write-Host "  ⚠️  Pulando - Token ADMIN não disponível" -ForegroundColor Yellow
}

# ==================== TESTE 2: STUDENT PRÓPRIO PERFIL ====================
Write-Host "`n[3] STUDENT - PRÓPRIO PERFIL" -ForegroundColor Cyan

if ($STUDENT) {
    $profile = Test -Method "GET" -Endpoint "/api/alunos/me" -Token $STUDENT -Desc "Ver próprio perfil (/me)"
    
    # Tentar acessar outro aluno
    Test -Method "GET" -Endpoint "/api/alunos/1" -Token $STUDENT -Desc "Acessar outro aluno [DEVE FALHAR]"
    
    # Tentar listar todos
    Test -Method "GET" -Endpoint "/api/alunos" -Token $STUDENT -Desc "Listar todos alunos [DEVE FALHAR]"
    
    # Tentar criar
    Test -Method "POST" -Endpoint "/api/alunos" -Token $STUDENT -Desc "Criar aluno [DEVE FALHAR]" `
        -Body @{ nome = "Hack"; dataNascimento = "2005-01-01" }
    
    # Tentar deletar
    Test -Method "DELETE" -Endpoint "/api/alunos/1" -Token $STUDENT -Desc "Deletar aluno [DEVE FALHAR]"
} else {
    Write-Host "  ⚠️  Pulando - Token STUDENT não disponível" -ForegroundColor Yellow
}

# ==================== TESTE 3: SEM AUTENTICAÇÃO ====================
Write-Host "`n[4] SEM AUTENTICAÇÃO" -ForegroundColor Cyan

Test -Method "GET" -Endpoint "/api/alunos" -Desc "Listar alunos SEM TOKEN [DEVE FALHAR]"
Test -Method "GET" -Endpoint "/api/teachers" -Desc "Listar professores SEM TOKEN [DEVE FALHAR]"
Test -Method "POST" -Endpoint "/api/alunos" -Desc "Criar aluno SEM TOKEN [DEVE FALHAR]" `
    -Body @{ nome = "Hack" }

# ==================== RESUMO ====================
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nCOMPORTAMENTO ESPERADO:" -ForegroundColor Yellow
Write-Host "  ✅ ADMIN: Tudo permitido (200)" -ForegroundColor Green
Write-Host "  ✅ STUDENT /me: Próprio perfil OK (200)" -ForegroundColor Green
Write-Host "  🔒 STUDENT outros: Bloqueado (403)" -ForegroundColor Yellow
Write-Host "  🔒 Sem token: Bloqueado (401/403)" -ForegroundColor Yellow

Write-Host "`nENDPOINTS CHAVE:" -ForegroundColor Yellow
Write-Host "  • GET /api/alunos/me - Ver próprio perfil (STUDENT)" -ForegroundColor Cyan
Write-Host "  • GET /api/teachers/me - Ver próprio perfil (TEACHER)" -ForegroundColor Cyan
Write-Host "  • POST/DELETE - Apenas ADMIN" -ForegroundColor Cyan

Write-Host "`n✅ Teste concluído!`n" -ForegroundColor Green
