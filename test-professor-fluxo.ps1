# Teste do Fluxo do Professor
# PowerShell Script

$baseUrl = "http://localhost:8085"
$authHeader = @{
    "Authorization" = "Bearer seu-token-aqui"
    "Content-Type" = "application/json"
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTE - FLUXO DO PROFESSOR" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$professorId = Read-Host "Digite o ID do professor"

# 1. Ver suas disciplinas
Write-Host "`n1. CONSULTANDO SUAS DISCIPLINAS..." -ForegroundColor Yellow

try {
    $disciplinas = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas/professor/$professorId" -Method Get -Headers $authHeader
    Write-Host "✓ Você leciona $($disciplinas.Count) disciplina(s):" -ForegroundColor Green
    $disciplinas | ForEach-Object {
        Write-Host "  [$($_.id)] $($_.nome) - $($_.codigo)" -ForegroundColor Cyan
        Write-Host "      Curso: ID $($_.cursoId) | Período: $($_.periodo) | Créditos: $($_.creditos)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
    exit
}

# 2. Selecionar disciplina para trabalhar
Write-Host "`n2. SELECIONAR DISCIPLINA..." -ForegroundColor Yellow
$disciplinaId = Read-Host "Digite o ID da disciplina"

# 3. Ver alunos matriculados
Write-Host "`n3. CONSULTANDO ALUNOS MATRICULADOS..." -ForegroundColor Yellow

try {
    $matriculas = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/disciplina/$disciplinaId/ativas" -Method Get -Headers $authHeader
    Write-Host "✓ Total de $($matriculas.Count) aluno(s) matriculado(s):" -ForegroundColor Green
    $matriculas | ForEach-Object {
        Write-Host "  [Matrícula: $($_.id)] Aluno ID: $($_.alunoId) | Status: $($_.status) | Data: $($_.dataMatricula)" -ForegroundColor Cyan
    }
    
    # Salvar IDs de matrícula para uso posterior
    $global:matriculasDisponiveis = $matriculas
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
    exit
}

# 4. Lançar notas
Write-Host "`n4. LANÇAR NOTAS..." -ForegroundColor Yellow
$lancarNotas = Read-Host "Deseja lançar notas? (s/n)"

while ($lancarNotas -eq "s") {
    Write-Host "`nAlunos disponíveis:" -ForegroundColor Cyan
    $global:matriculasDisponiveis | ForEach-Object {
        Write-Host "  [Matrícula: $($_.id)] Aluno: $($_.alunoId)" -ForegroundColor Gray
    }
    
    $matriculaId = Read-Host "`nDigite o ID da matrícula"
    
    Write-Host "`nTipos de avaliação disponíveis:" -ForegroundColor Cyan
    Write-Host "  1. PROVA" -ForegroundColor Gray
    Write-Host "  2. TRABALHO" -ForegroundColor Gray
    Write-Host "  3. ATIVIDADE" -ForegroundColor Gray
    Write-Host "  4. PROJETO" -ForegroundColor Gray
    Write-Host "  5. EXAME_FINAL" -ForegroundColor Gray
    
    $tipoOpcao = Read-Host "`nEscolha o tipo (1-5)"
    $tipos = @("PROVA", "TRABALHO", "ATIVIDADE", "PROJETO", "EXAME_FINAL")
    $tipoAvaliacao = $tipos[[int]$tipoOpcao - 1]
    
    $nota = Read-Host "Digite a nota (0-10)"
    $peso = Read-Host "Digite o peso da avaliação (ex: 0.4 para 40%)"
    $observacoes = Read-Host "Observações (opcional)"
    
    $dataAtual = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    
    $avaliacao = @{
        matriculaId = [int]$matriculaId
        tipoAvaliacao = $tipoAvaliacao
        nota = [double]$nota
        peso = [double]$peso
        observacoes = $observacoes
        dataAvaliacao = $dataAtual
    } | ConvertTo-Json
    
    try {
        $resp = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes" -Method Post -Body $avaliacao -Headers $authHeader
        Write-Host "✓ Nota lançada com sucesso! ID: $($resp.id)" -ForegroundColor Green
        Write-Host "  Aluno: $($resp.alunoId) | Tipo: $($resp.tipoAvaliacao) | Nota: $($resp.nota)" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Erro ao lançar nota: $_" -ForegroundColor Red
    }
    
    $lancarNotas = Read-Host "`nLançar outra nota? (s/n)"
}

# 5. Ver todas as avaliações da disciplina
Write-Host "`n5. CONSULTANDO TODAS AS AVALIAÇÕES DA DISCIPLINA..." -ForegroundColor Yellow

try {
    $todasAvaliacoes = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/disciplina/$disciplinaId" -Method Get -Headers $authHeader
    Write-Host "✓ Total de $($todasAvaliacoes.Count) avaliação(ões) lançada(s):" -ForegroundColor Green
    
    $todasAvaliacoes | Group-Object alunoId | ForEach-Object {
        Write-Host "`n  Aluno ID: $($_.Name)" -ForegroundColor Yellow
        $_.Group | ForEach-Object {
            Write-Host "    - $($_.tipoAvaliacao): $($_.nota) (Peso: $($_.peso))" -ForegroundColor Cyan
            Write-Host "      Data: $($_.dataAvaliacao)" -ForegroundColor Gray
            if ($_.observacoes) {
                Write-Host "      Obs: $($_.observacoes)" -ForegroundColor Gray
            }
        }
        
        # Calcular média do aluno
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

# 6. Atualizar uma nota
Write-Host "`n6. ATUALIZAR NOTA..." -ForegroundColor Yellow
$atualizar = Read-Host "Deseja atualizar alguma nota? (s/n)"

if ($atualizar -eq "s") {
    $avaliacaoId = Read-Host "Digite o ID da avaliação"
    
    $nota = Read-Host "Nova nota (0-10)"
    $peso = Read-Host "Novo peso"
    $observacoes = Read-Host "Novas observações"
    $dataAtual = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    
    # Buscar avaliação atual
    try {
        $avaliacaoAtual = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/$avaliacaoId" -Method Get -Headers $authHeader
        
        $avaliacaoAtualizada = @{
            matriculaId = $avaliacaoAtual.matriculaId
            tipoAvaliacao = $avaliacaoAtual.tipoAvaliacao
            nota = [double]$nota
            peso = [double]$peso
            observacoes = $observacoes
            dataAvaliacao = $dataAtual
        } | ConvertTo-Json
        
        $resp = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/$avaliacaoId" -Method Put -Body $avaliacaoAtualizada -Headers $authHeader
        Write-Host "✓ Nota atualizada com sucesso!" -ForegroundColor Green
        Write-Host "  Nova nota: $($resp.nota) | Novo peso: $($resp.peso)" -ForegroundColor Cyan
    } catch {
        Write-Host "✗ Erro ao atualizar: $_" -ForegroundColor Red
    }
}

# 7. Relatório de desempenho da turma
Write-Host "`n7. RELATÓRIO DE DESEMPENHO DA TURMA..." -ForegroundColor Yellow

try {
    $todasAvaliacoes = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/disciplina/$disciplinaId" -Method Get -Headers $authHeader
    
    if ($todasAvaliacoes.Count -gt 0) {
        $medias = $todasAvaliacoes | Group-Object alunoId | ForEach-Object {
            $somaNotasPeso = ($_.Group | ForEach-Object { $_.nota * $_.peso } | Measure-Object -Sum).Sum
            $somaPesos = ($_.Group | ForEach-Object { $_.peso } | Measure-Object -Sum).Sum
            if ($somaPesos -gt 0) {
                [PSCustomObject]@{
                    AlunoId = $_.Name
                    Media = [math]::Round($somaNotasPeso / $somaPesos, 2)
                }
            }
        }
        
        Write-Host "`n✓ ESTATÍSTICAS DA TURMA:" -ForegroundColor Green
        $mediaGeral = ($medias.Media | Measure-Object -Average).Average
        $mediaMaxima = ($medias.Media | Measure-Object -Maximum).Maximum
        $mediaMinima = ($medias.Media | Measure-Object -Minimum).Minimum
        
        Write-Host "  Média Geral da Turma: $([math]::Round($mediaGeral, 2))" -ForegroundColor Cyan
        Write-Host "  Maior Média: $mediaMaxima" -ForegroundColor Cyan
        Write-Host "  Menor Média: $mediaMinima" -ForegroundColor Cyan
        Write-Host "  Total de Alunos Avaliados: $($medias.Count)" -ForegroundColor Cyan
        
        $aprovados = ($medias | Where-Object { $_.Media -ge 7.0 }).Count
        $reprovados = ($medias | Where-Object { $_.Media -lt 7.0 }).Count
        
        Write-Host "`n  Aprovados (média >= 7.0): $aprovados" -ForegroundColor Green
        Write-Host "  Reprovados (média < 7.0): $reprovados" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "TESTE CONCLUÍDO!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
