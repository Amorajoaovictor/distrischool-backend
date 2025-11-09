# Script para testar autenticacao em todas as rotas dos servicos
# Baseado no test-all-routes.ps1

# Carregar System.Web para UrlEncode
Add-Type -AssemblyName System.Web

$ErrorActionPreference = "Continue"

# Configuracao - TODAS AS ROTAS VIA GATEWAY
$GATEWAY_URL = "http://localhost:8080"

# Variavel para armazenar o token JWT
$JWT_TOKEN = $null

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE DE AUTENTICACAO - DISTRISCHOOL" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Funcao para fazer login e obter token
function Get-AuthToken {
    Write-Host "`n[AUTH] Obtendo token de autenticacao..." -ForegroundColor Cyan
    
    $loginBody = @{
        email = "teste.user.2025999@unifor.br"
        password = "ecfd4e61"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$GATEWAY_URL/api/auth/login" `
            -Method POST `
            -ContentType "application/json" `
            -Body $loginBody `
            -ErrorAction Stop
        
        if ($response.token) {
            Write-Host "✅ Token obtido com sucesso" -ForegroundColor Green
            return $response.token
        }
    } catch {
        Write-Host "⚠️  Nao foi possivel obter token. Alguns testes podem falhar." -ForegroundColor Yellow
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
    return $null
}

# Funcao para exibir resultado do teste
function Show-TestResult {
    param(
        [string]$Title,
        [int]$TestNumber,
        [string]$Method,
        [string]$Endpoint,
        $WithoutAuth,
        $WithAuth,
        [string]$RequiresAuth
    )

    Write-Host "`n[$TestNumber] $Title" -ForegroundColor Cyan
    Write-Host "  $Method $Endpoint" -ForegroundColor White
    
    $authColor = switch ($RequiresAuth) {
        "SIM" { "Red" }
        "NAO" { "Green" }
        default { "Yellow" }
    }
    
    Write-Host "  Sem Auth: $WithoutAuth | Com Auth: $WithAuth" -ForegroundColor Gray
    Write-Host "  REQUER AUTH: $RequiresAuth" -ForegroundColor $authColor
}

# Funcao para testar uma rota
function Test-Route {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Description,
        [int]$TestNumber,
        [object]$Body = $null
    )

    $url = "$GATEWAY_URL$Endpoint"
    $withoutAuth = $null
    $withAuth = $null
    $requiresAuth = "INDEFINIDO"

    # Teste SEM autenticacao
    try {
        $params = @{
            Uri = $url
            Method = $Method
            ErrorAction = 'Stop'
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }

        $response = Invoke-WebRequest @params
        $withoutAuth = $response.StatusCode
    } catch {
        if ($_.Exception.Response) {
            $withoutAuth = $_.Exception.Response.StatusCode.value__
        } else {
            $withoutAuth = "ERROR"
        }
    }

    # Teste COM autenticacao (se temos token)
    if ($JWT_TOKEN) {
        try {
            $params = @{
                Uri = $url
                Method = $Method
                Headers = @{
                    "Authorization" = "Bearer $JWT_TOKEN"
                }
                ErrorAction = 'Stop'
            }
            
            if ($Body) {
                $params.Body = ($Body | ConvertTo-Json)
                $params.ContentType = "application/json"
            }

            $response = Invoke-WebRequest @params
            $withAuth = $response.StatusCode
        } catch {
            if ($_.Exception.Response) {
                $withAuth = $_.Exception.Response.StatusCode.value__
            } else {
                $withAuth = "ERROR"
            }
        }
    }

    # Determinar se requer autenticacao
    if ($withoutAuth -eq 401 -or $withoutAuth -eq 403) {
        $requiresAuth = "SIM"
    } elseif ($withoutAuth -eq 200 -or $withoutAuth -eq 201) {
        $requiresAuth = "NAO"
    } else {
        $requiresAuth = "INDEFINIDO"
    }

    Show-TestResult -Title $Description -TestNumber $TestNumber -Method $Method -Endpoint $Endpoint `
        -WithoutAuth $withoutAuth -WithAuth $withAuth -RequiresAuth $requiresAuth

    Start-Sleep -Milliseconds 500

    return @{
        Method = $Method
        Endpoint = $Endpoint
        Description = $Description
        WithoutAuth = $withoutAuth
        WithAuth = $withAuth
        RequiresAuth = $requiresAuth
    }
}

# Obter token de autenticacao
$JWT_TOKEN = Get-AuthToken

# Array para armazenar todos os resultados
$allResults = @()
$testCounter = 1

# ========================================================================
# AUTH SERVICE (via Gateway - precisa adicionar rota no Gateway!)
# ========================================================================

Write-Host "`n========== AUTH SERVICE ==========" -ForegroundColor Yellow

$allResults += Test-Route -Method "POST" -Endpoint "/api/auth/login" `
    -Description "Login de usuario" -TestNumber $testCounter `
    -Body @{ username = "test"; password = "test" }
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/auth/register" `
    -Description "Registro de novo usuario" -TestNumber $testCounter `
    -Body @{ username = "test"; password = "test"; email = "test@test.com" }
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/auth/validate" `
    -Description "Validacao de token JWT" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/auth/refresh" `
    -Description "Refresh de token JWT" -TestNumber $testCounter
$testCounter++

# ========================================================================
# USER SERVICE (via Gateway)
# ========================================================================

Write-Host "`n========== USER SERVICE ==========" -ForegroundColor Yellow

$allResults += Test-Route -Method "GET" -Endpoint "/api/v1/users" `
    -Description "Listar todos os usuarios" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "GET" -Endpoint "/api/v1/users/1" `
    -Description "Buscar usuario por ID" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/v1/users" `
    -Description "Criar novo usuario" -TestNumber $testCounter `
    -Body @{ fullName = "Test User"; email = "test@test.com"; password = "senha123"; role = "STUDENT" }
$testCounter++

$allResults += Test-Route -Method "PUT" -Endpoint "/api/v1/users/1" `
    -Description "Atualizar usuario existente" -TestNumber $testCounter `
    -Body @{ fullName = "Updated User" }
$testCounter++

$allResults += Test-Route -Method "DELETE" -Endpoint "/api/v1/users/1" `
    -Description "Deletar usuario" -TestNumber $testCounter
$testCounter++

# ========================================================================
# STUDENT SERVICE (via Gateway - endpoint /api/alunos)
# ========================================================================

Write-Host "`n========== STUDENT SERVICE ==========" -ForegroundColor Yellow

$allResults += Test-Route -Method "GET" -Endpoint "/api/alunos" `
    -Description "Listar todos os alunos" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "GET" -Endpoint "/api/alunos/1" `
    -Description "Buscar aluno por ID" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/alunos" `
    -Description "Criar novo aluno" -TestNumber $testCounter `
    -Body @{ nome = "Test Student"; dataNascimento = "2005-01-01"; turma = "3A" }
$testCounter++

$allResults += Test-Route -Method "PUT" -Endpoint "/api/alunos/1" `
    -Description "Atualizar aluno existente" -TestNumber $testCounter `
    -Body @{ nome = "Updated Student" }
$testCounter++

$allResults += Test-Route -Method "DELETE" -Endpoint "/api/alunos/1" `
    -Description "Deletar aluno" -TestNumber $testCounter
$testCounter++

# ========================================================================
# TEACHER SERVICE (via Gateway - endpoint /api/teachers)
# ========================================================================

Write-Host "`n========== TEACHER SERVICE ==========" -ForegroundColor Yellow

$allResults += Test-Route -Method "GET" -Endpoint "/api/teachers" `
    -Description "Listar todos os professores" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "GET" -Endpoint "/api/teachers/1" `
    -Description "Buscar professor por ID" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/teachers" `
    -Description "Criar novo professor" -TestNumber $testCounter `
    -Body @{ nome = "Test Teacher"; qualificacao = "Mestrado"; contato = "85911112222" }
$testCounter++

$allResults += Test-Route -Method "PUT" -Endpoint "/api/teachers/1" `
    -Description "Atualizar professor existente" -TestNumber $testCounter `
    -Body @{ nome = "Updated Teacher" }
$testCounter++

$allResults += Test-Route -Method "DELETE" -Endpoint "/api/teachers/1" `
    -Description "Deletar professor" -TestNumber $testCounter
$testCounter++

# ========================================================================
# ADMIN SERVICE (via Gateway - endpoint /api/v1/admins)
# ========================================================================

Write-Host "`n========== ADMIN SERVICE ==========" -ForegroundColor Yellow

$allResults += Test-Route -Method "GET" -Endpoint "/api/v1/admins" `
    -Description "Listar todos os administradores" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "GET" -Endpoint "/api/v1/admins/1" `
    -Description "Buscar administrador por ID" -TestNumber $testCounter
$testCounter++

$allResults += Test-Route -Method "POST" -Endpoint "/api/v1/admins" `
    -Description "Criar novo administrador" -TestNumber $testCounter `
    -Body @{ name = "Test Admin"; department = "IT"; email = "admin@test.com"; password = "admin123"; role = "ADMIN" }
$testCounter++

$allResults += Test-Route -Method "PUT" -Endpoint "/api/v1/admins/1" `
    -Description "Atualizar administrador existente" -TestNumber $testCounter `
    -Body @{ name = "Updated Admin" }
$testCounter++

$allResults += Test-Route -Method "DELETE" -Endpoint "/api/v1/admins/1" `
    -Description "Deletar administrador" -TestNumber $testCounter
$testCounter++

# ========================================================================
# RESUMO
# ========================================================================

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO DOS TESTES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

$requiresAuth = ($allResults | Where-Object { $_.RequiresAuth -eq "SIM" }).Count
$publicRoutes = ($allResults | Where-Object { $_.RequiresAuth -eq "NAO" }).Count
$undefined = ($allResults | Where-Object { $_.RequiresAuth -eq "INDEFINIDO" }).Count

Write-Host "`nTotal de testes: $($allResults.Count)" -ForegroundColor White
Write-Host "  Rotas que REQUEREM autenticacao: $requiresAuth" -ForegroundColor Red
Write-Host "  Rotas PUBLICAS: $publicRoutes" -ForegroundColor Green
Write-Host "  Rotas INDEFINIDAS (erro/offline): $undefined" -ForegroundColor Yellow

# Exportar para arquivo
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$filename = "route-auth-report_$timestamp.txt"

$output = "========================================================================`n"
$output += "        RELATORIO DE TESTES DE AUTENTICACAO DE ROTAS (VIA GATEWAY)`n"
$output += "        Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$output += "========================================================================`n`n"

foreach ($result in $allResults) {
    $output += "[$($result.Method)] $($result.Endpoint)`n"
    $output += "  Descricao: $($result.Description)`n"
    $output += "  Requer Auth: $($result.RequiresAuth)`n"
    $output += "  Status sem Auth: $($result.WithoutAuth)`n"
    $output += "  Status com Auth: $($result.WithAuth)`n"
    $output += "`n"
}

$output += "`n========================================================================`n"
$output += "                           RESUMO`n"
$output += "========================================================================`n"
$output += "  Rotas que REQUEREM autenticacao: $requiresAuth`n"
$output += "  Rotas PUBLICAS: $publicRoutes`n"
$output += "  Rotas INDEFINIDAS: $undefined`n"
$output += "========================================================================`n`n"
$output += "RECOMENDACOES:`n"
$output += "- Rotas marcadas como PUBLICAS podem ser acessadas sem autenticacao`n"
$output += "- Rotas marcadas como REQUER AUTH precisam de token JWT valido`n"
$output += "- Rotas INDEFINIDAS podem estar com erro ou servico offline`n`n"
$output += "PROXIMOS PASSOS:`n"
$output += "1. Revisar cada rota e definir politica de acesso apropriada`n"
$output += "2. Implementar controle de permissoes por tipo de usuario (admin/teacher/student)`n"
$output += "3. Atualizar SecurityConfig em cada servico conforme necessario`n"
$output += "4. Adicionar rota para auth-service no Gateway`n"
$output += "========================================================================`n"

$output | Out-File -FilePath $filename -Encoding UTF8
Write-Host "`n✅ Relatorio exportado para: $filename" -ForegroundColor Green

Write-Host "`nTestes concluidos!`n" -ForegroundColor Green
