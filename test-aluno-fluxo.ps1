# Teste do Fluxo do Aluno
# PowerShell Script

$baseUrl = "http://localhost:8086"
$authHeader = @{
    "Authorization" = "Bearer seu-token-aqui"
    "Content-Type" = "application/json"
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTE - FLUXO DO ALUNO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$alunoId = Read-Host "Digite o ID do aluno"

# 1. Ver disciplinas disponíveis do curso
Write-Host "`n1. CONSULTANDO DISCIPLINAS DISPONÍVEIS..." -ForegroundColor Yellow
$cursoId = Read-Host "Digite o ID do curso do aluno"

try {
    $disciplinas = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas/curso/$cursoId" -Method Get -Headers $authHeader
    Write-Host "✓ Disciplinas disponíveis no curso:" -ForegroundColor Green
    $disciplinas | ForEach-Object {
        Write-Host "  [$($_.id)] $($_.nome) - $($_.codigo) | Período: $($_.periodo) | Status: $($_.status)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
    exit
}

# 2. Matricular em disciplinas
Write-Host "`n2. MATRICULANDO EM DISCIPLINAS..." -ForegroundColor Yellow
$continuar = "s"

while ($continuar -eq "s") {
    $disciplinaId = Read-Host "Digite o ID da disciplina para matrícula"
    
    $matricula = @{
        alunoId = [int]$alunoId
        disciplinaId = [int]$disciplinaId
        status = "ATIVA"
    } | ConvertTo-Json
    
    try {
        $resp = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula -Headers $authHeader
        Write-Host "✓ Matrícula realizada com sucesso! ID: $($resp.id)" -ForegroundColor Green
        Write-Host "  Disciplina: $($resp.disciplinaNome) [$($resp.disciplinaCodigo)]" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Erro ao matricular: $_" -ForegroundColor Red
    }
    
    $continuar = Read-Host "`nMatricular em outra disciplina? (s/n)"
}

# 3. Ver suas matrículas ativas
Write-Host "`n3. CONSULTANDO MATRÍCULAS ATIVAS..." -ForegroundColor Yellow

try {
    $matriculasAtivas = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/aluno/$alunoId/ativas" -Method Get -Headers $authHeader
    Write-Host "✓ Você tem $($matriculasAtivas.Count) matrícula(s) ativa(s):" -ForegroundColor Green
    $matriculasAtivas | ForEach-Object {
        Write-Host "  [$($_.id)] $($_.disciplinaNome) - $($_.disciplinaCodigo) | Data: $($_.dataMatricula)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

# 4. Ver todas as notas
Write-Host "`n4. CONSULTANDO TODAS AS NOTAS..." -ForegroundColor Yellow

try {
    $todasNotas = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/aluno/$alunoId" -Method Get -Headers $authHeader
    Write-Host "✓ Você tem $($todasNotas.Count) avaliação(ões):" -ForegroundColor Green
    
    $todasNotas | Group-Object disciplinaNome | ForEach-Object {
        Write-Host "`n  Disciplina: $($_.Name)" -ForegroundColor Yellow
        $_.Group | ForEach-Object {
            Write-Host "    - $($_.tipoAvaliacao): $($_.nota) (Peso: $($_.peso))" -ForegroundColor Cyan
            if ($_.observacoes) {
                Write-Host "      Obs: $($_.observacoes)" -ForegroundColor Gray
            }
        }
        
        # Calcular média ponderada
        $somaNotasPeso = ($_.Group | ForEach-Object { $_.nota * $_.peso } | Measure-Object -Sum).Sum
        $somaPesos = ($_.Group | ForEach-Object { $_.peso } | Measure-Object -Sum).Sum
        if ($somaPesos -gt 0) {
            $media = $somaNotasPeso / $somaPesos
            Write-Host "    MÉDIA: $([math]::Round($media, 2))" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

# 5. Ver notas de uma disciplina específica
Write-Host "`n5. CONSULTAR NOTAS DE DISCIPLINA ESPECÍFICA..." -ForegroundColor Yellow
$verEspecifica = Read-Host "Deseja ver notas de uma disciplina específica? (s/n)"

if ($verEspecifica -eq "s") {
    $disciplinaId = Read-Host "Digite o ID da disciplina"
    
    try {
        $notasDisciplina = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/aluno/$alunoId/disciplina/$disciplinaId" -Method Get -Headers $authHeader
        Write-Host "✓ Notas na disciplina:" -ForegroundColor Green
        
        $notasDisciplina | ForEach-Object {
            Write-Host "  - $($_.tipoAvaliacao): $($_.nota) (Peso: $($_.peso))" -ForegroundColor Cyan
            Write-Host "    Data: $($_.dataAvaliacao)" -ForegroundColor Gray
            if ($_.observacoes) {
                Write-Host "    Obs: $($_.observacoes)" -ForegroundColor Gray
            }
        }
        
        # Calcular média
        if ($notasDisciplina.Count -gt 0) {
            $somaNotasPeso = ($notasDisciplina | ForEach-Object { $_.nota * $_.peso } | Measure-Object -Sum).Sum
            $somaPesos = ($notasDisciplina | ForEach-Object { $_.peso } | Measure-Object -Sum).Sum
            if ($somaPesos -gt 0) {
                $media = $somaNotasPeso / $somaPesos
                Write-Host "`n  MÉDIA FINAL: $([math]::Round($media, 2))" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "✗ Erro: $_" -ForegroundColor Red
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "TESTE CONCLUÍDO!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
