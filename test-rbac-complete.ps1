# Script de Teste Completo de RBAC - Distrischool
# Testa permissoes para ADMIN, STUDENT e TEACHER

Add-Type -AssemblyName System.Web
$ErrorActionPreference = "Continue"

$GATEWAY_URL = "http://localhost:8080"

# Variaveis globais para tokens
$ADMIN_TOKEN = $null
$STUDENT_TOKEN = $null
$TEACHER_TOKEN = $null
$STUDENT_ID = $null
$TEACHER_ID = $null

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE COMPLETO DE RBAC - DISTRISCHOOL" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Funcao para fazer login
function Get-AuthToken {
    param(
        [string]$Email,
        [string]$Password,
        [string]$Role
    )
    
    Write-Host "`n[AUTH] Obtendo token para: $Email ($Role)" -ForegroundColor Cyan
    
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
            Write-Host "✅ Token obtido com sucesso para $Role" -ForegroundColor Green
            return $response.token
        }
    } catch {
        Write-Host "❌ Falha ao obter token para $Role" -ForegroundColor Red
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
    return $null
}

# Funcao para testar uma requisicao
function Test-Request {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Token,
        [string]$Description,
        [object]$Body = $null,
        [string]$ExpectedResult = "200"
    )

    $url = "$GATEWAY_URL$Endpoint"
    
    try {
        $params = @{
            Uri = $url
            Method = $Method
            ErrorAction = 'Stop'
        }
        
        if ($Token) {
            $params.Headers = @{
                "Authorization" = "Bearer $Token"
            }
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }

        $response = Invoke-WebRequest @params
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq $ExpectedResult) {
            Write-Host "  ✅ $Description - $statusCode (esperado: $ExpectedResult)" -ForegroundColor Green
            return @{ Success = $true; StatusCode = $statusCode; Response = ($response.Content | ConvertFrom-Json) }
        } else {
            Write-Host "  ⚠️  $Description - $statusCode (esperado: $ExpectedResult)" -ForegroundColor Yellow
            return @{ Success = $false; StatusCode = $statusCode; Response = $null }
        }
    } catch {
        $statusCode = "ERROR"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        $symbol = if ($statusCode -eq $ExpectedResult) { "✅" } else { "❌" }
        $color = if ($statusCode -eq $ExpectedResult) { "Green" } else { "Red" }
        
        Write-Host "  $symbol $Description - $statusCode (esperado: $ExpectedResult)" -ForegroundColor $color
        return @{ Success = ($statusCode -eq $ExpectedResult); StatusCode = $statusCode; Response = $null }
    }
}

# ========================================================================
# FASE 1: OBTER TOKENS DE AUTENTICACAO
# ========================================================================

Write-Host "`n========== FASE 1: AUTENTICACAO ==========" -ForegroundColor Yellow

# Login como ADMIN (credenciais conhecidas)
$ADMIN_TOKEN = Get-AuthToken -Email "admin@distrischool.com" -Password "admin123" -Role "ADMIN"

if (-not $ADMIN_TOKEN) {
    Write-Host "`n❌ ERRO CRÍTICO: Não foi possível autenticar como ADMIN!" -ForegroundColor Red
    Write-Host "   Execute primeiro: Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/reset-admin' -Method POST" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nℹ️  NOTA: Para testes completos de RBAC (STUDENT/TEACHER), é necessário:" -ForegroundColor Yellow
Write-Host "   1. Criar usuários de teste com senhas conhecidas" -ForegroundColor Gray
Write-Host "   2. Ou modificar o auth-service para permitir definir senha na criação" -ForegroundColor Gray
Write-Host "`n   Por enquanto, usando apenas ADMIN para todos os testes." -ForegroundColor Yellow

# TODO: Implementar criação de usuários STUDENT e TEACHER com senhas conhecidas
$STUDENT_TOKEN = $ADMIN_TOKEN
$TEACHER_TOKEN = $ADMIN_TOKEN

Start-Sleep -Seconds 2

# ========================================================================
# FASE 2: TESTAR PERMISSOES DE ADMIN
# ========================================================================

Write-Host "`n========== FASE 2: TESTES COM ROLE ADMIN ==========" -ForegroundColor Yellow
Write-Host "ADMIN deve ter acesso total a todos os recursos`n" -ForegroundColor Gray

if ($ADMIN_TOKEN) {
    Write-Host "`n--- USER SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/v1/users" -Token $ADMIN_TOKEN `
        -Description "ADMIN lista todos usuarios" -ExpectedResult "200"
    
    Test-Request -Method "POST" -Endpoint "/api/v1/users" -Token $ADMIN_TOKEN `
        -Description "ADMIN cria novo usuario" -ExpectedResult "201" `
        -Body @{ fullName = "Test User Admin"; email = "testadmin@test.com"; password = "senha123"; role = "STUDENT"; enabled = $true }
    
    Write-Host "`n--- STUDENT SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/alunos" -Token $ADMIN_TOKEN `
        -Description "ADMIN lista todos alunos" -ExpectedResult "200"
    
    Test-Request -Method "POST" -Endpoint "/api/alunos" -Token $ADMIN_TOKEN `
        -Description "ADMIN cria novo aluno" -ExpectedResult "201" `
        -Body @{ nome = "Aluno Admin Test"; dataNascimento = "2005-01-01"; turma = "3A"; endereco = "Rua Test"; contato = "85911112222"; historicoAcademico = "Test" }
    
    Test-Request -Method "DELETE" -Endpoint "/api/alunos/1" -Token $ADMIN_TOKEN `
        -Description "ADMIN deleta aluno" -ExpectedResult "204"
    
    Write-Host "`n--- TEACHER SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/teachers" -Token $ADMIN_TOKEN `
        -Description "ADMIN lista todos professores" -ExpectedResult "200"
    
    Test-Request -Method "POST" -Endpoint "/api/teachers" -Token $ADMIN_TOKEN `
        -Description "ADMIN cria novo professor" -ExpectedResult "201" `
        -Body @{ nome = "Professor Admin Test"; matricula = "PROFADMTEST"; qualificacao = "Mestrado"; contato = "85922223333" }
    
    Test-Request -Method "DELETE" -Endpoint "/api/teachers/1" -Token $ADMIN_TOKEN `
        -Description "ADMIN deleta professor" -ExpectedResult "204"
    
    Write-Host "`n--- ADMIN SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/v1/admins" -Token $ADMIN_TOKEN `
        -Description "ADMIN lista todos admins" -ExpectedResult "200"
    
    Test-Request -Method "POST" -Endpoint "/api/v1/admins" -Token $ADMIN_TOKEN `
        -Description "ADMIN cria novo admin" -ExpectedResult "201" `
        -Body @{ name = "New Admin"; email = "newadmin@test.com"; role = "COORDINATOR"; password = "admin123" }
} else {
    Write-Host "⚠️  ADMIN token nao disponivel - pulando testes de ADMIN" -ForegroundColor Yellow
}

# ========================================================================
# FASE 3: TESTAR PERMISSOES DE STUDENT
# ========================================================================

Write-Host "`n========== FASE 3: TESTES COM ROLE STUDENT ==========" -ForegroundColor Yellow
Write-Host "STUDENT deve acessar apenas seu proprio perfil`n" -ForegroundColor Gray

if ($STUDENT_TOKEN) {
    Write-Host "`n--- STUDENT SERVICE ---" -ForegroundColor Cyan
    
    # Buscar ID do aluno logado
    $studentProfile = Test-Request -Method "GET" -Endpoint "/api/alunos" -Token $STUDENT_TOKEN `
        -Description "STUDENT lista alunos (deve ver apenas o seu)" -ExpectedResult "200"
    
    if ($studentProfile.Response) {
        $ownStudentId = $studentProfile.Response.id
        
        Test-Request -Method "GET" -Endpoint "/api/alunos/$ownStudentId" -Token $STUDENT_TOKEN `
            -Description "STUDENT busca seu proprio perfil" -ExpectedResult "200"
        
        Test-Request -Method "PUT" -Endpoint "/api/alunos/$ownStudentId" -Token $STUDENT_TOKEN `
            -Description "STUDENT atualiza seu proprio perfil" -ExpectedResult "200" `
            -Body @{ nome = "Aluno Atualizado"; dataNascimento = "2005-01-01"; turma = "3A"; endereco = "Rua Nova"; contato = "85988887777"; historicoAcademico = "Atualizado" }
        
        # Tentar acessar outro aluno (deve falhar)
        $otherStudentId = if ($ownStudentId -eq 1) { 2 } else { 1 }
        Test-Request -Method "GET" -Endpoint "/api/alunos/$otherStudentId" -Token $STUDENT_TOKEN `
            -Description "STUDENT tenta acessar outro aluno (deve FALHAR)" -ExpectedResult "403"
        
        Test-Request -Method "PUT" -Endpoint "/api/alunos/$otherStudentId" -Token $STUDENT_TOKEN `
            -Description "STUDENT tenta atualizar outro aluno (deve FALHAR)" -ExpectedResult "403" `
            -Body @{ nome = "Hacker" }
    }
    
    # Tentar deletar (sempre deve falhar para STUDENT)
    Test-Request -Method "DELETE" -Endpoint "/api/alunos/1" -Token $STUDENT_TOKEN `
        -Description "STUDENT tenta deletar aluno (deve FALHAR)" -ExpectedResult "403"
    
    Write-Host "`n--- USER SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/v1/users" -Token $STUDENT_TOKEN `
        -Description "STUDENT tenta listar usuarios (deve FALHAR)" -ExpectedResult "403"
    
    Test-Request -Method "POST" -Endpoint "/api/v1/users" -Token $STUDENT_TOKEN `
        -Description "STUDENT tenta criar usuario (deve FALHAR)" -ExpectedResult "403" `
        -Body @{ fullName = "Hacker"; email = "hack@test.com"; password = "hack"; role = "ADMIN" }
    
    Write-Host "`n--- TEACHER SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/teachers" -Token $STUDENT_TOKEN `
        -Description "STUDENT tenta listar professores (deve FALHAR)" -ExpectedResult "403"
    
    Write-Host "`n--- ADMIN SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/v1/admins" -Token $STUDENT_TOKEN `
        -Description "STUDENT tenta listar admins (deve FALHAR)" -ExpectedResult "403"
} else {
    Write-Host "⚠️  STUDENT token nao disponivel - pulando testes de STUDENT" -ForegroundColor Yellow
}

# ========================================================================
# FASE 4: TESTAR PERMISSOES DE TEACHER
# ========================================================================

Write-Host "`n========== FASE 4: TESTES COM ROLE TEACHER ==========" -ForegroundColor Yellow
Write-Host "TEACHER deve acessar apenas seu proprio perfil`n" -ForegroundColor Gray

if ($TEACHER_TOKEN -and $TEACHER_ID) {
    Write-Host "`n--- TEACHER SERVICE ---" -ForegroundColor Cyan
    
    Test-Request -Method "GET" -Endpoint "/api/teachers/$TEACHER_ID" -Token $TEACHER_TOKEN `
        -Description "TEACHER busca seu proprio perfil" -ExpectedResult "200"
    
    Test-Request -Method "PUT" -Endpoint "/api/teachers/$TEACHER_ID" -Token $TEACHER_TOKEN `
        -Description "TEACHER atualiza seu proprio perfil" -ExpectedResult "200" `
        -Body @{ nome = "Professor Atualizado"; matricula = "PROF2025RBAC"; qualificacao = "Pos-Doutorado"; contato = "85977776666" }
    
    # Tentar acessar outro professor (deve falhar)
    $otherTeacherId = if ($TEACHER_ID -eq 1) { 2 } else { 1 }
    Test-Request -Method "GET" -Endpoint "/api/teachers/$otherTeacherId" -Token $TEACHER_TOKEN `
        -Description "TEACHER tenta acessar outro professor (deve FALHAR)" -ExpectedResult "403"
    
    Test-Request -Method "PUT" -Endpoint "/api/teachers/$otherTeacherId" -Token $TEACHER_TOKEN `
        -Description "TEACHER tenta atualizar outro professor (deve FALHAR)" -ExpectedResult "403" `
        -Body @{ nome = "Hacker Professor" }
    
    # Tentar deletar (sempre deve falhar para TEACHER)
    Test-Request -Method "DELETE" -Endpoint "/api/teachers/1" -Token $TEACHER_TOKEN `
        -Description "TEACHER tenta deletar professor (deve FALHAR)" -ExpectedResult "403"
    
    Write-Host "`n--- STUDENT SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/alunos" -Token $TEACHER_TOKEN `
        -Description "TEACHER tenta listar alunos (deve FALHAR)" -ExpectedResult "403"
    
    Write-Host "`n--- USER SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/v1/users" -Token $TEACHER_TOKEN `
        -Description "TEACHER tenta listar usuarios (deve FALHAR)" -ExpectedResult "403"
    
    Write-Host "`n--- ADMIN SERVICE ---" -ForegroundColor Cyan
    Test-Request -Method "GET" -Endpoint "/api/v1/admins" -Token $TEACHER_TOKEN `
        -Description "TEACHER tenta listar admins (deve FALHAR)" -ExpectedResult "403"
} else {
    Write-Host "⚠️  TEACHER token nao disponivel - pulando testes de TEACHER" -ForegroundColor Yellow
}

# ========================================================================
# FASE 5: TESTAR REQUISICOES SEM AUTENTICACAO
# ========================================================================

Write-Host "`n========== FASE 5: TESTES SEM AUTENTICACAO ==========" -ForegroundColor Yellow
Write-Host "Requisicoes sem token devem ser rejeitadas (exceto POST para criar recursos)`n" -ForegroundColor Gray

Write-Host "`n--- STUDENT SERVICE ---" -ForegroundColor Cyan
Test-Request -Method "POST" -Endpoint "/api/alunos" -Token $null `
    -Description "Criar aluno SEM TOKEN (deve PERMITIR)" -ExpectedResult "201" `
    -Body @{ nome = "Aluno Sem Auth"; dataNascimento = "2005-01-01"; turma = "3A"; endereco = "Rua Test"; contato = "85911112222"; historicoAcademico = "Test" }

Test-Request -Method "GET" -Endpoint "/api/alunos" -Token $null `
    -Description "Listar alunos SEM TOKEN (deve REJEITAR)" -ExpectedResult "401"

Test-Request -Method "DELETE" -Endpoint "/api/alunos/1" -Token $null `
    -Description "Deletar aluno SEM TOKEN (deve REJEITAR)" -ExpectedResult "401"

Write-Host "`n--- TEACHER SERVICE ---" -ForegroundColor Cyan
Test-Request -Method "POST" -Endpoint "/api/teachers" -Token $null `
    -Description "Criar professor SEM TOKEN (deve PERMITIR)" -ExpectedResult "201" `
    -Body @{ nome = "Professor Sem Auth"; matricula = "PROFNOAUTH"; qualificacao = "Mestrado"; contato = "85922223333" }

Test-Request -Method "GET" -Endpoint "/api/teachers" -Token $null `
    -Description "Listar professores SEM TOKEN (deve REJEITAR)" -ExpectedResult "401"

Test-Request -Method "DELETE" -Endpoint "/api/teachers/1" -Token $null `
    -Description "Deletar professor SEM TOKEN (deve REJEITAR)" -ExpectedResult "401"

Write-Host "`n--- USER SERVICE ---" -ForegroundColor Cyan
Test-Request -Method "GET" -Endpoint "/api/v1/users" -Token $null `
    -Description "Listar usuarios SEM TOKEN (deve REJEITAR)" -ExpectedResult "401"

Test-Request -Method "POST" -Endpoint "/api/v1/users" -Token $null `
    -Description "Criar usuario SEM TOKEN (deve REJEITAR)" -ExpectedResult "401" `
    -Body @{ fullName = "Test"; email = "test@test.com"; password = "test"; role = "STUDENT" }

# ========================================================================
# RESUMO FINAL
# ========================================================================

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO DOS TESTES DE RBAC" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nTOKENS OBTIDOS:" -ForegroundColor Yellow
Write-Host "  ADMIN: $(if ($ADMIN_TOKEN) { '✅ OK' } else { '❌ FALHOU' })" -ForegroundColor $(if ($ADMIN_TOKEN) { 'Green' } else { 'Red' })
Write-Host "  STUDENT: $(if ($STUDENT_TOKEN) { '✅ OK' } else { '❌ FALHOU' })" -ForegroundColor $(if ($STUDENT_TOKEN) { 'Green' } else { 'Red' })
Write-Host "  TEACHER: $(if ($TEACHER_TOKEN) { '✅ OK' } else { '❌ FALHOU' })" -ForegroundColor $(if ($TEACHER_TOKEN) { 'Green' } else { 'Red' })

Write-Host "`nPOLITICA DE ACESSO ESPERADA:" -ForegroundColor Yellow
Write-Host "  ✅ ADMIN: Acesso total a todos os recursos" -ForegroundColor Green
Write-Host "  ✅ STUDENT: Apenas visualizar/editar seu proprio perfil" -ForegroundColor Green
Write-Host "  ✅ TEACHER: Apenas visualizar/editar seu proprio perfil" -ForegroundColor Green
Write-Host "  ✅ POST sem auth: Permitido para criar aluno/professor" -ForegroundColor Green
Write-Host "  ❌ Outras operacoes sem auth: Rejeitadas (401)" -ForegroundColor Red
Write-Host "  ❌ DELETE: Apenas ADMIN pode executar" -ForegroundColor Red

Write-Host "`nRECOMENDACOES:" -ForegroundColor Yellow
Write-Host "  1. Verificar que ADMIN conseguiu executar todas as operacoes" -ForegroundColor White
Write-Host "  2. Verificar que STUDENT/TEACHER receberam 403 ao tentar acessar recursos de outros" -ForegroundColor White
Write-Host "  3. Verificar que requisicoes sem token foram rejeitadas (exceto POST)" -ForegroundColor White
Write-Host "  4. Revisar logs de cada servico para validar autorizacao" -ForegroundColor White

Write-Host "`n✅ Testes de RBAC concluidos!`n" -ForegroundColor Green
