# Teste do Course Service via Gateway
# PowerShell Script

$gatewayUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTE - COURSE SERVICE (via Gateway)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Login como ADMIN
Write-Host "[1] AUTENTICACAO ADMIN" -ForegroundColor Yellow
try {
    $loginBody = @{
        email = "admin@distrischool.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$gatewayUrl/api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    
    $token = $response.token
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    Write-Host "PASSOU - Login realizado" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Start-Sleep -Seconds 1

# 2. Limpar dados anteriores
Write-Host "`n[2] LIMPAR DADOS ANTERIORES" -ForegroundColor Yellow
try {
    # Listar e deletar avaliacoes
    $avaliacoes = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes/aluno/1" -Method GET -Headers $headers
    foreach ($aval in $avaliacoes) {
        Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes/$($aval.id)" -Method DELETE -Headers $headers | Out-Null
    }
    
    # Listar e deletar matriculas
    $matriculas = Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas/aluno/1" -Method GET -Headers $headers
    foreach ($mat in $matriculas) {
        Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas/$($mat.id)" -Method DELETE -Headers $headers | Out-Null
    }
    
    # Listar e deletar disciplinas
    $cursos = Invoke-RestMethod -Uri "$gatewayUrl/api/cursos" -Method GET -Headers $headers
    foreach ($c in $cursos) {
        $discs = Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas/curso/$($c.id)" -Method GET -Headers $headers
        foreach ($disc in $discs) {
            Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas/$($disc.id)" -Method DELETE -Headers $headers | Out-Null
        }
        Invoke-RestMethod -Uri "$gatewayUrl/api/cursos/$($c.id)" -Method DELETE -Headers $headers | Out-Null
    }
    
    Write-Host "PASSOU - Dados anteriores limpos" -ForegroundColor Green
} catch {
    Write-Host "AVISO - Nenhum dado anterior para limpar" -ForegroundColor Gray
}

Start-Sleep -Seconds 1

# 3. Criar Curso
Write-Host "`n[3] CRIAR CURSO" -ForegroundColor Yellow
$curso = @{
    nome = "Ciencias da Computacao"
    codigo = "CC001"
    descricao = "Bacharelado em CC"
    duracaoSemestres = 8
    modalidade = "Presencial"
    turno = "Noturno"
    status = "ATIVO"
} | ConvertTo-Json

try {
    $cursoResp = Invoke-RestMethod -Uri "$gatewayUrl/api/cursos" -Method POST -Headers $headers -Body $curso
    Write-Host "PASSOU - Curso criado: ID $($cursoResp.id)" -ForegroundColor Green
    $cursoId = $cursoResp.id
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 4. Listar Cursos
Write-Host "`n[4] LISTAR CURSOS" -ForegroundColor Yellow
try {
    $cursos = Invoke-RestMethod -Uri "$gatewayUrl/api/cursos" -Method GET -Headers $headers
    Write-Host "PASSOU - Total de cursos: $($cursos.Count)" -ForegroundColor Green
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 5. Buscar Curso por ID
Write-Host "`n[5] BUSCAR CURSO POR ID" -ForegroundColor Yellow
try {
    $cursoGet = Invoke-RestMethod -Uri "$gatewayUrl/api/cursos/$cursoId" -Method GET -Headers $headers
    Write-Host "PASSOU - Curso: $($cursoGet.nome)" -ForegroundColor Green
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 6. Criar Disciplina
Write-Host "`n[6] CRIAR DISCIPLINA" -ForegroundColor Yellow
$disciplina = @{
    nome = "Programacao Orientada a Objetos"
    codigo = "POO001"
    descricao = "POO com Java"
    cargaHoraria = 80
    creditos = 4
    cursoId = $cursoId
    professorId = 1
    periodo = 3
    tipo = "OBRIGATORIA"
    status = "ATIVA"
} | ConvertTo-Json

try {
    $discResp = Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas" -Method POST -Headers $headers -Body $disciplina
    Write-Host "PASSOU - Disciplina criada: ID $($discResp.id)" -ForegroundColor Green
    $disciplinaId = $discResp.id
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 7. Listar Disciplinas do Curso
Write-Host "`n[7] LISTAR DISCIPLINAS DO CURSO" -ForegroundColor Yellow
try {
    $disciplinas = Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas/curso/$cursoId" -Method GET -Headers $headers
    Write-Host "PASSOU - Disciplinas do curso: $($disciplinas.Count)" -ForegroundColor Green
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 8. Criar Matricula
Write-Host "`n[8] CRIAR MATRICULA" -ForegroundColor Yellow
$matricula = @{
    alunoId = 1
    disciplinaId = $disciplinaId
    status = "ATIVA"
} | ConvertTo-Json

try {
    $matResp = Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas" -Method POST -Headers $headers -Body $matricula
    Write-Host "PASSOU - Matricula criada: ID $($matResp.id)" -ForegroundColor Green
    $matriculaId = $matResp.id
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 9. Listar Matriculas do Aluno
Write-Host "`n[9] LISTAR MATRICULAS DO ALUNO" -ForegroundColor Yellow
try {
    $matriculas = Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas/aluno/1/ativas" -Method GET -Headers $headers
    Write-Host "PASSOU - Matriculas ativas: $($matriculas.Count)" -ForegroundColor Green
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 10. Criar Avaliacao
Write-Host "`n[10] CRIAR AVALIACAO" -ForegroundColor Yellow
$dataAtual = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$avaliacao = @{
    matriculaId = $matriculaId
    tipoAvaliacao = "PROVA"
    nota = 8.5
    peso = 0.4
    observacoes = "Bom desempenho"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

try {
    $avalResp = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes" -Method POST -Headers $headers -Body $avaliacao
    Write-Host "PASSOU - Avaliacao criada: ID $($avalResp.id) | Nota: $($avalResp.nota)" -ForegroundColor Green
    $avaliacaoId = $avalResp.id
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 11. Listar Avaliacoes do Aluno
Write-Host "`n[11] LISTAR AVALIACOES DO ALUNO" -ForegroundColor Yellow
try {
    $avaliacoes = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes/aluno/1" -Method GET -Headers $headers
    Write-Host "PASSOU - Avaliacoes do aluno: $($avaliacoes.Count)" -ForegroundColor Green
    $avaliacoes | ForEach-Object {
        Write-Host "   - Disciplina: $($_.disciplinaNome) | Tipo: $($_.tipoAvaliacao) | Nota: $($_.nota)" -ForegroundColor Gray
    }
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 12. Atualizar Avaliacao
Write-Host "`n[12] ATUALIZAR AVALIACAO" -ForegroundColor Yellow
$avaliacaoUpdate = @{
    matriculaId = $matriculaId
    tipoAvaliacao = "PROVA"
    nota = 9.0
    peso = 0.4
    observacoes = "Nota atualizada"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

try {
    $avalUpdate = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes/$avaliacaoId" -Method PUT -Headers $headers -Body $avaliacaoUpdate
    Write-Host "PASSOU - Nota atualizada: $($avalUpdate.nota)" -ForegroundColor Green
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# 13. Listar Alunos Matriculados (Professor)
Write-Host "`n[13] LISTAR ALUNOS MATRICULADOS NA DISCIPLINA" -ForegroundColor Yellow
try {
    $alunosMatriculados = Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas/disciplina/$disciplinaId/ativas" -Method GET -Headers $headers
    Write-Host "PASSOU - Alunos matriculados: $($alunosMatriculados.Count)" -ForegroundColor Green
} catch {
    Write-Host "FALHOU - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUMO - 13 testes executados" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IDs criados:" -ForegroundColor Yellow
Write-Host "  Curso: $cursoId" -ForegroundColor Gray
Write-Host "  Disciplina: $disciplinaId" -ForegroundColor Gray
Write-Host "  Matricula: $matriculaId" -ForegroundColor Gray
Write-Host "  Avaliacao: $avaliacaoId" -ForegroundColor Gray
Write-Host ""
