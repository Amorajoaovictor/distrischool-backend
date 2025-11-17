$gatewayUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

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

Write-Host "`n[1] CRIAR ALUNO DE TESTE" -ForegroundColor Cyan

$alunoBody = @{
    nome = "João Silva Credentials Test"
    dataNascimento = "2005-01-01"
    turma = "3A"
    endereco = "Rua Teste Credentials, 123"
    contato = "85999887766"
    historicoAcademico = "Aluno de teste para validar salvamento de credenciais"
} | ConvertTo-Json

try {
    $aluno = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" `
        -Method POST `
        -Headers @{"Authorization"="Bearer $ADMIN_TOKEN"} `
        -Body $alunoBody `
        -ContentType "application/json"
    
    Write-Host "✅ SUCESSO! Aluno criado com sucesso." -ForegroundColor Green
    Write-Host "   ID: $($aluno.id)" -ForegroundColor Gray
    Write-Host "   Nome: $($aluno.nome)" -ForegroundColor Gray
    Write-Host "   Matrícula: $($aluno.matricula)" -ForegroundColor Gray
    Write-Host "   Turma: $($aluno.turma)" -ForegroundColor Gray
    
    # Aguarda processamento do evento Kafka
    Write-Host "`n⏳ Aguardando processamento do evento Kafka (5 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Verifica o arquivo credentials.txt
    Write-Host "`n[2] VERIFICANDO ARQUIVO CREDENTIALS.TXT" -ForegroundColor Cyan
    if (Test-Path "credentials.txt") {
        Write-Host "✅ Arquivo credentials.txt encontrado!" -ForegroundColor Green
        Write-Host "`nÚltimas 10 linhas:" -ForegroundColor Yellow
        Get-Content "credentials.txt" | Select-Object -Last 10
    } else {
        Write-Host "⚠️  Arquivo credentials.txt ainda não foi criado" -ForegroundColor Yellow
        Write-Host "   O arquivo será criado no container auth-service" -ForegroundColor Gray
    }
    
    # Mostra como buscar a senha nos logs
    Write-Host "`n[3] COMO ENCONTRAR A SENHA GERADA" -ForegroundColor Cyan
    Write-Host "Execute no terminal:" -ForegroundColor Yellow
    Write-Host "docker exec docker-auth-service-1 cat /credentials.txt" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ ERRO ao criar aluno!" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor DarkRed
    exit 1
}