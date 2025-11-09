# Teste do endpoint /me para Student e Teacher

$GATEWAY_URL = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE: ENDPOINT /me" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Login como STUDENT
Write-Host "[AUTH] Fazendo login como STUDENT..." -ForegroundColor Cyan

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
    
    $STUDENT_TOKEN = $response.token
    Write-Host "  ✅ Token obtido" -ForegroundColor Green
    
    # Testar endpoint /me
    Write-Host "`n[STUDENT] Testando GET /api/alunos/me..." -ForegroundColor Cyan
    
    try {
        $headers = @{ "Authorization" = "Bearer $STUDENT_TOKEN" }
        $meuPerfil = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/me" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  ✅ SUCESSO! Conseguiu buscar proprio perfil via /me" -ForegroundColor Green
        Write-Host "`n  Dados do perfil:" -ForegroundColor Cyan
        Write-Host "    ID: $($meuPerfil.id)" -ForegroundColor Gray
        Write-Host "    Nome: $($meuPerfil.nome)" -ForegroundColor Gray
        Write-Host "    Matricula: $($meuPerfil.matricula)" -ForegroundColor Gray
        Write-Host "    Turma: $($meuPerfil.turma)" -ForegroundColor Gray
        
        $ownId = $meuPerfil.id
        
        # Testar GET /api/alunos/{id} com proprio ID
        Write-Host "`n[STUDENT] Testando GET /api/alunos/$ownId (proprio ID)..." -ForegroundColor Cyan
        
        try {
            $perfilPorId = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/$ownId" `
                -Method GET `
                -Headers $headers `
                -ErrorAction Stop
            
            Write-Host "  ✅ SUCESSO! Conseguiu buscar proprio perfil por ID" -ForegroundColor Green
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Host "  ❌ FALHOU: Status $statusCode" -ForegroundColor Red
        }
        
        # Testar PUT /api/alunos/{id} com proprio ID
        Write-Host "`n[STUDENT] Testando PUT /api/alunos/$ownId (editar proprio perfil)..." -ForegroundColor Cyan
        
        try {
            $updateBody = @{
                nome = $meuPerfil.nome
                dataNascimento = $meuPerfil.dataNascimento
                turma = $meuPerfil.turma
                endereco = "Endereco Atualizado via /me Test"
                contato = $meuPerfil.contato
                matricula = $meuPerfil.matricula
                historicoAcademico = "Historico test"
            } | ConvertTo-Json
            
            $atualizado = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/$ownId" `
                -Method PUT `
                -Headers $headers `
                -ContentType "application/json" `
                -Body $updateBody `
                -ErrorAction Stop
            
            Write-Host "  ✅ SUCESSO! Conseguiu editar proprio perfil" -ForegroundColor Green
            Write-Host "    Endereco: $($atualizado.endereco)" -ForegroundColor Gray
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Host "  ❌ FALHOU: Status $statusCode" -ForegroundColor Red
            Write-Host "    Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
        }
        
        # Testar acesso a outro aluno (deve falhar)
        $otherStudentId = if ($ownId -eq 1) { 2 } else { 1 }
        Write-Host "`n[STUDENT] Testando GET /api/alunos/$otherStudentId (outro aluno)..." -ForegroundColor Cyan
        
        try {
            $outroAluno = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/$otherStudentId" `
                -Method GET `
                -Headers $headers `
                -ErrorAction Stop
            
            Write-Host "  ⚠️  PROBLEMA: Conseguiu acessar outro aluno!" -ForegroundColor Yellow
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            if ($statusCode -eq 403) {
                Write-Host "  ✅ CORRETO: Bloqueado com 403 Forbidden" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  Status inesperado: $statusCode" -ForegroundColor Yellow
            }
        }
        
    } catch {
        $statusCode = "ERROR"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        Write-Host "  ❌ FALHOU ao buscar /me: Status $statusCode" -ForegroundColor Red
        Write-Host "    Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
    
} catch {
    Write-Host "  ❌ Falha ao fazer login" -ForegroundColor Red
}

# ========================================================================
# RESUMO
# ========================================================================

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nNOVO ENDPOINT:" -ForegroundColor Yellow
Write-Host "  GET /api/alunos/me - Retorna perfil do aluno logado" -ForegroundColor White
Write-Host "  GET /api/teachers/me - Retorna perfil do professor logado" -ForegroundColor White

Write-Host "`nCOMPORTAMENTO:" -ForegroundColor Yellow
Write-Host "  ✅ STUDENT usa /api/alunos/me para ver proprio perfil" -ForegroundColor Green
Write-Host "  ✅ STUDENT usa /api/alunos/{id} para editar (validado por StudentPermission)" -ForegroundColor Green
Write-Host "  ❌ STUDENT NAO pode acessar /api/alunos/{otherId}" -ForegroundColor Red
Write-Host "  ❌ STUDENT NAO pode acessar /api/alunos (lista - apenas ADMIN)" -ForegroundColor Red

Write-Host "`n✅ Teste concluido!`n" -ForegroundColor Green
