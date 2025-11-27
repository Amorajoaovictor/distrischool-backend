# Teste Rápido - APIs Básicas
# PowerShell Script

$baseUrl = "http://localhost:8086"
$authHeader = @{
    "Authorization" = "Bearer seu-token-aqui"
    "Content-Type" = "application/json"
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTE RÁPIDO - COURSE SERVICE APIs" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Teste 1: Criar Curso
Write-Host "TESTE 1: Criar Curso" -ForegroundColor Yellow
$curso = @{
    nome = "Teste Engenharia"
    codigo = "ENG999"
    descricao = "Curso de teste"
    duracaoSemestres = 10
    modalidade = "Presencial"
    turno = "Integral"
    status = "ATIVO"
} | ConvertTo-Json

try {
    $respCurso = Invoke-RestMethod -Uri "$baseUrl/api/cursos" -Method Post -Body $curso -Headers $authHeader
    Write-Host "✓ PASSOU - Curso criado: ID $($respCurso.id)" -ForegroundColor Green
    $cursoId = $respCurso.id
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 2: Buscar Curso
Write-Host "`nTESTE 2: Buscar Curso por ID" -ForegroundColor Yellow
try {
    $curso = Invoke-RestMethod -Uri "$baseUrl/api/cursos/$cursoId" -Method Get -Headers $authHeader
    Write-Host "✓ PASSOU - Curso: $($curso.nome)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 3: Criar Disciplina
Write-Host "`nTESTE 3: Criar Disciplina" -ForegroundColor Yellow
$disciplina = @{
    nome = "Teste Programação"
    codigo = "PROG999"
    descricao = "Disciplina de teste"
    cargaHoraria = 60
    creditos = 3
    cursoId = $cursoId
    professorId = 1
    periodo = 1
    tipo = "OBRIGATORIA"
    status = "ATIVA"
} | ConvertTo-Json

try {
    $respDisc = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas" -Method Post -Body $disciplina -Headers $authHeader
    Write-Host "✓ PASSOU - Disciplina criada: ID $($respDisc.id)" -ForegroundColor Green
    $disciplinaId = $respDisc.id
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 4: Listar Disciplinas do Curso
Write-Host "`nTESTE 4: Listar Disciplinas do Curso" -ForegroundColor Yellow
try {
    $disciplinas = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas/curso/$cursoId" -Method Get -Headers $authHeader
    Write-Host "✓ PASSOU - Encontradas $($disciplinas.Count) disciplina(s)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 5: Criar Matrícula
Write-Host "`nTESTE 5: Criar Matrícula" -ForegroundColor Yellow
$matricula = @{
    alunoId = 1
    disciplinaId = $disciplinaId
    status = "ATIVA"
} | ConvertTo-Json

try {
    $respMat = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula -Headers $authHeader
    Write-Host "✓ PASSOU - Matrícula criada: ID $($respMat.id)" -ForegroundColor Green
    $matriculaId = $respMat.id
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 6: Tentar Matrícula Duplicada (deve falhar)
Write-Host "`nTESTE 6: Tentar Matrícula Duplicada (deve falhar)" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula -Headers $authHeader
    Write-Host "✗ FALHOU - Permitiu matrícula duplicada!" -ForegroundColor Red
} catch {
    Write-Host "✓ PASSOU - Bloqueou matrícula duplicada corretamente" -ForegroundColor Green
}

# Teste 7: Listar Matrículas do Aluno
Write-Host "`nTESTE 7: Listar Matrículas do Aluno" -ForegroundColor Yellow
try {
    $matriculas = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/aluno/1/ativas" -Method Get -Headers $authHeader
    Write-Host "✓ PASSOU - Aluno tem $($matriculas.Count) matrícula(s) ativa(s)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 8: Criar Avaliação
Write-Host "`nTESTE 8: Criar Avaliação" -ForegroundColor Yellow
$dataAtual = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$avaliacao = @{
    matriculaId = $matriculaId
    tipoAvaliacao = "PROVA"
    nota = 8.5
    peso = 0.5
    observacoes = "Teste automático"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

try {
    $respAval = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes" -Method Post -Body $avaliacao -Headers $authHeader
    Write-Host "✓ PASSOU - Avaliação criada: ID $($respAval.id)" -ForegroundColor Green
    $avaliacaoId = $respAval.id
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 9: Buscar Avaliações do Aluno
Write-Host "`nTESTE 9: Buscar Avaliações do Aluno" -ForegroundColor Yellow
try {
    $avaliacoes = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/aluno/1" -Method Get -Headers $authHeader
    Write-Host "✓ PASSOU - Aluno tem $($avaliacoes.Count) avaliação(ões)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 10: Atualizar Nota
Write-Host "`nTESTE 10: Atualizar Avaliação" -ForegroundColor Yellow
$avaliacaoAtualizada = @{
    matriculaId = $matriculaId
    tipoAvaliacao = "PROVA"
    nota = 9.0
    peso = 0.5
    observacoes = "Nota atualizada"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

try {
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/$avaliacaoId" -Method Put -Body $avaliacaoAtualizada -Headers $authHeader
    Write-Host "✓ PASSOU - Nota atualizada: $($resp.nota)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 11: Buscar Alunos Matriculados (Professor)
Write-Host "`nTESTE 11: Buscar Alunos Matriculados na Disciplina" -ForegroundColor Yellow
try {
    $alunos = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/disciplina/$disciplinaId/ativas" -Method Get -Headers $authHeader
    Write-Host "✓ PASSOU - Disciplina tem $($alunos.Count) aluno(s) matriculado(s)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 12: Alterar Status da Matrícula
Write-Host "`nTESTE 12: Alterar Status da Matrícula" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/$matriculaId/status?status=TRANCADA" -Method Put -Headers $authHeader
    Write-Host "✓ PASSOU - Status alterado para: $($resp.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Teste 13: Verificar Matrícula Trancada não Aparece em Ativas
Write-Host "`nTESTE 13: Verificar Filtro de Matrículas Ativas" -ForegroundColor Yellow
try {
    $ativas = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/disciplina/$disciplinaId/ativas" -Method Get -Headers $authHeader
    if ($ativas.Count -eq 0) {
        Write-Host "✓ PASSOU - Matrícula trancada não aparece em ativas" -ForegroundColor Green
    } else {
        Write-Host "✗ FALHOU - Matrícula trancada aparece em ativas" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ FALHOU - $_" -ForegroundColor Red
}

# Resumo
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Total: 13 testes executados" -ForegroundColor White
Write-Host ""
Write-Host "IDs Criados para referencia:" -ForegroundColor Yellow
Write-Host "  Curso ID: $cursoId" -ForegroundColor Gray
Write-Host "  Disciplina ID: $disciplinaId" -ForegroundColor Gray
Write-Host "  Matricula ID: $matriculaId" -ForegroundColor Gray
Write-Host "  Avaliacao ID: $avaliacaoId" -ForegroundColor Gray
Write-Host ""
