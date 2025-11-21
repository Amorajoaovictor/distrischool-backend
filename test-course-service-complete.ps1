# Teste Completo do Fluxo: Curso -> Disciplina -> Matrícula -> Avaliação
# PowerShell Script

$baseUrl = "http://localhost:8086"
$authHeader = @{
    "Authorization" = "Bearer seu-token-aqui"
    "Content-Type" = "application/json"
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTE COMPLETO - COURSE SERVICE" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. CRIAR CURSOS
# ============================================
Write-Host "1. CRIANDO CURSOS..." -ForegroundColor Yellow

$cursoCC = @{
    nome = "Ciências da Computação"
    codigo = "CC001"
    descricao = "Curso de Bacharelado em Ciências da Computação"
    duracaoSemestres = 8
    modalidade = "Presencial"
    turno = "Noturno"
    status = "ATIVO"
} | ConvertTo-Json

$cursoDireito = @{
    nome = "Direito"
    codigo = "DIR001"
    descricao = "Curso de Bacharelado em Direito"
    duracaoSemestres = 10
    modalidade = "Presencial"
    turno = "Matutino"
    status = "ATIVO"
} | ConvertTo-Json

try {
    $responseCC = Invoke-RestMethod -Uri "$baseUrl/api/cursos" -Method Post -Body $cursoCC -Headers $authHeader
    Write-Host "✓ Curso CC criado - ID: $($responseCC.id)" -ForegroundColor Green
    $cursoIdCC = $responseCC.id
} catch {
    Write-Host "✗ Erro ao criar curso CC: $_" -ForegroundColor Red
}

try {
    $responseDireito = Invoke-RestMethod -Uri "$baseUrl/api/cursos" -Method Post -Body $cursoDireito -Headers $authHeader
    Write-Host "✓ Curso Direito criado - ID: $($responseDireito.id)" -ForegroundColor Green
    $cursoIdDireito = $responseDireito.id
} catch {
    Write-Host "✗ Erro ao criar curso Direito: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 2. CRIAR DISCIPLINAS
# ============================================
Write-Host "`n2. CRIANDO DISCIPLINAS..." -ForegroundColor Yellow

$disciplinaPOO = @{
    nome = "Programação Orientada a Objetos"
    codigo = "POO001"
    descricao = "Conceitos de POO com Java"
    cargaHoraria = 80
    creditos = 4
    cursoId = $cursoIdCC
    professorId = 1
    periodo = 3
    tipo = "OBRIGATORIA"
    status = "ATIVA"
} | ConvertTo-Json

$disciplinaCANA = @{
    nome = "Cálculo Numérico e Análise"
    codigo = "CANA001"
    descricao = "Métodos numéricos e análise matemática"
    cargaHoraria = 80
    creditos = 4
    cursoId = $cursoIdCC
    professorId = 1
    periodo = 4
    tipo = "OBRIGATORIA"
    status = "ATIVA"
} | ConvertTo-Json

$disciplinaDiscreta = @{
    nome = "Matemática Discreta"
    codigo = "MAT001"
    descricao = "Fundamentos de matemática discreta"
    cargaHoraria = 80
    creditos = 4
    cursoId = $cursoIdCC
    professorId = 2
    periodo = 2
    tipo = "OBRIGATORIA"
    status = "ATIVA"
} | ConvertTo-Json

try {
    $respPOO = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas" -Method Post -Body $disciplinaPOO -Headers $authHeader
    Write-Host "✓ Disciplina POO criada - ID: $($respPOO.id)" -ForegroundColor Green
    $disciplinaIdPOO = $respPOO.id
} catch {
    Write-Host "✗ Erro ao criar disciplina POO: $_" -ForegroundColor Red
}

try {
    $respCANA = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas" -Method Post -Body $disciplinaCANA -Headers $authHeader
    Write-Host "✓ Disciplina CANA criada - ID: $($respCANA.id)" -ForegroundColor Green
    $disciplinaIdCANA = $respCANA.id
} catch {
    Write-Host "✗ Erro ao criar disciplina CANA: $_" -ForegroundColor Red
}

try {
    $respDiscreta = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas" -Method Post -Body $disciplinaDiscreta -Headers $authHeader
    Write-Host "✓ Disciplina Matemática Discreta criada - ID: $($respDiscreta.id)" -ForegroundColor Green
    $disciplinaIdDiscreta = $respDiscreta.id
} catch {
    Write-Host "✗ Erro ao criar disciplina Matemática Discreta: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 3. MATRICULAR ALUNOS
# ============================================
Write-Host "`n3. MATRICULANDO ALUNOS..." -ForegroundColor Yellow

$alunoId1 = 1
$alunoId2 = 2

# Aluno 1 se matricula em POO e CANA
$matricula1POO = @{
    alunoId = $alunoId1
    disciplinaId = $disciplinaIdPOO
    status = "ATIVA"
} | ConvertTo-Json

$matricula1CANA = @{
    alunoId = $alunoId1
    disciplinaId = $disciplinaIdCANA
    status = "ATIVA"
} | ConvertTo-Json

# Aluno 2 se matricula em POO e Matemática Discreta
$matricula2POO = @{
    alunoId = $alunoId2
    disciplinaId = $disciplinaIdPOO
    status = "ATIVA"
} | ConvertTo-Json

$matricula2Discreta = @{
    alunoId = $alunoId2
    disciplinaId = $disciplinaIdDiscreta
    status = "ATIVA"
} | ConvertTo-Json

try {
    $mat1POO = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula1POO -Headers $authHeader
    Write-Host "✓ Aluno $alunoId1 matriculado em POO - Matrícula ID: $($mat1POO.id)" -ForegroundColor Green
    $matriculaId1POO = $mat1POO.id
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $mat1CANA = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula1CANA -Headers $authHeader
    Write-Host "✓ Aluno $alunoId1 matriculado em CANA - Matrícula ID: $($mat1CANA.id)" -ForegroundColor Green
    $matriculaId1CANA = $mat1CANA.id
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $mat2POO = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula2POO -Headers $authHeader
    Write-Host "✓ Aluno $alunoId2 matriculado em POO - Matrícula ID: $($mat2POO.id)" -ForegroundColor Green
    $matriculaId2POO = $mat2POO.id
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $mat2Disc = Invoke-RestMethod -Uri "$baseUrl/api/matriculas" -Method Post -Body $matricula2Discreta -Headers $authHeader
    Write-Host "✓ Aluno $alunoId2 matriculado em Matemática Discreta - Matrícula ID: $($mat2Disc.id)" -ForegroundColor Green
    $matriculaId2Discreta = $mat2Disc.id
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 4. PROFESSOR CONSULTA ALUNOS MATRICULADOS
# ============================================
Write-Host "`n4. PROFESSOR CONSULTANDO ALUNOS MATRICULADOS..." -ForegroundColor Yellow

try {
    $alunosPOO = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/disciplina/$disciplinaIdPOO/ativas" -Method Get -Headers $authHeader
    Write-Host "✓ Disciplina POO tem $($alunosPOO.Count) aluno(s) matriculado(s)" -ForegroundColor Green
    $alunosPOO | ForEach-Object {
        Write-Host "  - Aluno ID: $($_.alunoId) | Status: $($_.status)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erro ao consultar alunos: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 5. PROFESSOR LANÇA NOTAS
# ============================================
Write-Host "`n5. PROFESSOR LANÇANDO NOTAS..." -ForegroundColor Yellow

$dataAtual = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

# Avaliação 1 - Aluno 1 em POO
$avaliacao1 = @{
    matriculaId = $matriculaId1POO
    tipoAvaliacao = "PROVA"
    nota = 8.5
    peso = 0.4
    observacoes = "Ótimo desempenho na prova"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

# Avaliação 2 - Aluno 1 em POO
$avaliacao2 = @{
    matriculaId = $matriculaId1POO
    tipoAvaliacao = "TRABALHO"
    nota = 9.0
    peso = 0.3
    observacoes = "Trabalho bem desenvolvido"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

# Avaliação 3 - Aluno 2 em POO
$avaliacao3 = @{
    matriculaId = $matriculaId2POO
    tipoAvaliacao = "PROVA"
    nota = 7.0
    peso = 0.4
    observacoes = "Precisa melhorar"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

# Avaliação 4 - Aluno 1 em CANA
$avaliacao4 = @{
    matriculaId = $matriculaId1CANA
    tipoAvaliacao = "PROVA"
    nota = 9.5
    peso = 0.5
    observacoes = "Excelente!"
    dataAvaliacao = $dataAtual
} | ConvertTo-Json

try {
    $av1 = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes" -Method Post -Body $avaliacao1 -Headers $authHeader
    Write-Host "✓ Nota lançada - Aluno $alunoId1 | POO | PROVA: 8.5" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $av2 = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes" -Method Post -Body $avaliacao2 -Headers $authHeader
    Write-Host "✓ Nota lançada - Aluno $alunoId1 | POO | TRABALHO: 9.0" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $av3 = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes" -Method Post -Body $avaliacao3 -Headers $authHeader
    Write-Host "✓ Nota lançada - Aluno $alunoId2 | POO | PROVA: 7.0" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $av4 = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes" -Method Post -Body $avaliacao4 -Headers $authHeader
    Write-Host "✓ Nota lançada - Aluno $alunoId1 | CANA | PROVA: 9.5" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 6. ALUNO CONSULTA SUAS NOTAS
# ============================================
Write-Host "`n6. ALUNO CONSULTANDO SUAS NOTAS..." -ForegroundColor Yellow

try {
    $notasAluno1 = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/aluno/$alunoId1" -Method Get -Headers $authHeader
    Write-Host "✓ Aluno $alunoId1 tem $($notasAluno1.Count) avaliação(ões)" -ForegroundColor Green
    $notasAluno1 | ForEach-Object {
        Write-Host "  - Disciplina: $($_.disciplinaNome) | Tipo: $($_.tipoAvaliacao) | Nota: $($_.nota) | Peso: $($_.peso)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

try {
    $notasAluno2 = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/aluno/$alunoId2" -Method Get -Headers $authHeader
    Write-Host "`n✓ Aluno $alunoId2 tem $($notasAluno2.Count) avaliação(ões)" -ForegroundColor Green
    $notasAluno2 | ForEach-Object {
        Write-Host "  - Disciplina: $($_.disciplinaNome) | Tipo: $($_.tipoAvaliacao) | Nota: $($_.nota) | Peso: $($_.peso)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 7. ALUNO CONSULTA MATRÍCULAS ATIVAS
# ============================================
Write-Host "`n7. ALUNO CONSULTANDO MATRÍCULAS ATIVAS..." -ForegroundColor Yellow

try {
    $matriculasAluno1 = Invoke-RestMethod -Uri "$baseUrl/api/matriculas/aluno/$alunoId1/ativas" -Method Get -Headers $authHeader
    Write-Host "✓ Aluno $alunoId1 tem $($matriculasAluno1.Count) matrícula(s) ativa(s)" -ForegroundColor Green
    $matriculasAluno1 | ForEach-Object {
        Write-Host "  - Disciplina: $($_.disciplinaNome) [$($_.disciplinaCodigo)] | Status: $($_.status)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 1

# ============================================
# 8. CONSULTAS ADICIONAIS
# ============================================
Write-Host "`n8. CONSULTAS ADICIONAIS..." -ForegroundColor Yellow

# Listar todos os cursos
try {
    $cursos = Invoke-RestMethod -Uri "$baseUrl/api/cursos" -Method Get -Headers $authHeader
    Write-Host "✓ Total de cursos cadastrados: $($cursos.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro ao listar cursos: $_" -ForegroundColor Red
}

# Listar disciplinas do curso CC
try {
    $disciplinasCC = Invoke-RestMethod -Uri "$baseUrl/api/disciplinas/curso/$cursoIdCC" -Method Get -Headers $authHeader
    Write-Host "✓ Curso CC tem $($disciplinasCC.Count) disciplina(s)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro ao listar disciplinas: $_" -ForegroundColor Red
}

# Notas específicas de um aluno em uma disciplina
try {
    $notasEspecificas = Invoke-RestMethod -Uri "$baseUrl/api/avaliacoes/aluno/$alunoId1/disciplina/$disciplinaIdPOO" -Method Get -Headers $authHeader
    Write-Host "✓ Aluno $alunoId1 tem $($notasEspecificas.Count) nota(s) em POO" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "TESTES CONCLUÍDOS!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
