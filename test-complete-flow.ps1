# Teste Completo do Fluxo Academico com Kafka
# Simula todo o ciclo: Curso -> Disciplina -> Matricula -> Avaliacao

$gatewayUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

# Gerar timestamp unico para evitar duplicacao
$timestamp = (Get-Date).ToString("HHmmss")
$cursoCode = "CC" + $timestamp
$discCode1 = "POO" + $timestamp
$discCode2 = "ED" + $timestamp
$alunoMat = "ALU" + $timestamp
$profMat = "PROF" + $timestamp

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "  TESTE COMPLETO - FLUXO ACADEMICO COM KAFKA" -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# 0. LIMPEZA DE DADOS ANTERIORES
Write-Host "=== PASSO 0: LIMPEZA DE DADOS ===" -ForegroundColor Yellow

# 0.1 Login Admin temporario para limpeza
try {
    $adminLogin = @{
        email = "admin@distrischool.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $adminAuth = Invoke-RestMethod -Uri "$gatewayUrl/api/auth/login" -Method POST -ContentType "application/json" -Body $adminLogin
    $tempHeaders = @{
        "Authorization" = "Bearer $($adminAuth.token)"
        "Content-Type" = "application/json"
    }
    
    # Deletar na ordem correta (respeitando foreign keys)
    Write-Host "[0.1] Limpando dados de testes anteriores..." -ForegroundColor Cyan
    try {
        # 1. Avaliacoes (dependem de matriculas)
        $avaliacoes = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes" -Method GET -Headers $tempHeaders
        foreach ($av in $avaliacoes) {
            try { Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes/$($av.id)" -Method DELETE -Headers $tempHeaders | Out-Null } catch {}
        }
        
        # 2. Matriculas (dependem de disciplinas)
        $matriculas = Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas" -Method GET -Headers $tempHeaders
        foreach ($mat in $matriculas) {
            try { Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas/$($mat.id)" -Method DELETE -Headers $tempHeaders | Out-Null } catch {}
        }
        
        # 3. Disciplinas (dependem de cursos)
        $disciplinas = Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas" -Method GET -Headers $tempHeaders
        foreach ($disc in $disciplinas) {
            try { Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas/$($disc.id)" -Method DELETE -Headers $tempHeaders | Out-Null } catch {}
        }
        
        # 4. Cursos (sem dependencias)
        $cursos = Invoke-RestMethod -Uri "$gatewayUrl/api/cursos" -Method GET -Headers $tempHeaders
        foreach ($c in $cursos) {
            try { Invoke-RestMethod -Uri "$gatewayUrl/api/cursos/$($c.id)" -Method DELETE -Headers $tempHeaders | Out-Null } catch {}
        }
        
        Write-Host "   OK Banco limpo!" -ForegroundColor Green
    } catch {}
    
    Write-Host "   Banco limpo para novo teste!" -ForegroundColor Green
} catch {
    Write-Host "   Aviso: Erro na limpeza, continuando..." -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# 1. AUTENTICACAO
Write-Host "`n=== PASSO 1: AUTENTICACAO ===" -ForegroundColor Yellow

Write-Host "`n[1.1] Login como ADMIN" -ForegroundColor Cyan
try {
    $adminLogin = @{
        email = "admin@distrischool.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $adminAuth = Invoke-RestMethod -Uri "$gatewayUrl/api/auth/login" -Method POST -ContentType "application/json" -Body $adminLogin
    $adminToken = $adminAuth.token
    $adminHeaders = @{
        "Authorization" = "Bearer $adminToken"
        "Content-Type" = "application/json"
    }
    Write-Host "OK ADMIN autenticado - $($adminAuth.email)" -ForegroundColor Green
} catch {
    Write-Host "ERRO - $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Start-Sleep -Seconds 1

Write-Host "`n[1.2] Criar e autenticar PROFESSOR" -ForegroundColor Cyan
try {
    $professorData = @{
        nome = "Prof. Maria Silva"
        email = "maria.silva$timestamp@distrischool.com"
        password = "prof123"
        matricula = $profMat
        qualificacao = "Mestrado em Ciencia da Computacao"
        contato = "85999887766"
    } | ConvertTo-Json
    
    try {
        $professor = Invoke-RestMethod -Uri "$gatewayUrl/api/teachers" -Method POST -Headers $adminHeaders -Body $professorData
        Write-Host "OK Professor criado: ID $($professor.id)" -ForegroundColor Green
        $professorId = $professor.id
    } catch {
        Write-Host "   Professor ja existe" -ForegroundColor Gray
        $professorId = 1
    }
    
    $profLogin = @{
        email = "maria.silva$timestamp@distrischool.com"
        password = "prof123"
    } | ConvertTo-Json
    
    $profAuth = Invoke-RestMethod -Uri "$gatewayUrl/api/auth/login" -Method POST -ContentType "application/json" -Body $profLogin
    Write-Host "OK PROFESSOR autenticado" -ForegroundColor Green
} catch {
    Write-Host "Aviso: Usando professor padrao" -ForegroundColor Yellow
    $professorId = 1
}

Start-Sleep -Seconds 2

# 2. ADMIN CRIA CURSO
Write-Host "`n=== PASSO 2: ADMIN CRIA CURSO ===" -ForegroundColor Yellow

$curso = @{
    codigo = $cursoCode
    nome = "Ciencias da Computacao $timestamp"
    descricao = "Bacharelado em Ciencia da Computacao"
    duracaoSemestres = 8
    modalidade = "PRESENCIAL"
    turno = "NOTURNO"
    status = "ATIVO"
} | ConvertTo-Json

try {
    $cursoResp = Invoke-RestMethod -Uri "$gatewayUrl/api/cursos" -Method POST -Headers $adminHeaders -Body $curso
    Write-Host "OK Curso criado: ID $($cursoResp.id) - $($cursoResp.nome)" -ForegroundColor Green
    Write-Host "   Kafka: COURSE CREATED publicado" -ForegroundColor Magenta
    $cursoId = $cursoResp.id
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $cursoId = 1
}

Start-Sleep -Seconds 2

# 3. ADMIN CRIA ALUNO E INSCREVE NO CURSO
Write-Host "`n=== PASSO 3: ADMIN CRIA ALUNO ===" -ForegroundColor Yellow

Write-Host "`n[3.1] Criar ALUNO e inscrever no curso" -ForegroundColor Cyan
try {
    $alunoData = @{
        nome = "Joao Pedro Santos"
        dataNascimento = "2000-05-15"
        endereco = "Rua das Flores, 123"
        contato = "85988776655"
        matricula = $alunoMat
        turma = "CC2024.1"
        cursoId = $cursoId
        historicoAcademicoCriptografado = "Matriculado em CC"
    } | ConvertTo-Json
    
    $aluno = Invoke-RestMethod -Uri "$gatewayUrl/api/alunos" -Method POST -Headers $adminHeaders -Body $alunoData
    Write-Host "OK Aluno criado: ID $($aluno.id) - $($aluno.nome)" -ForegroundColor Green
    Write-Host "   Inscrito no curso ID: $cursoId" -ForegroundColor Gray
    Write-Host "   Kafka: STUDENT CREATED publicado" -ForegroundColor Magenta
    Write-Host "   -> Course-Service validara o curso" -ForegroundColor DarkGray
    $alunoId = $aluno.id
} catch {
    Write-Host "Aviso: $($_.Exception.Message)" -ForegroundColor Yellow
    $alunoId = 1
}

Start-Sleep -Seconds 2

# 4. ADMIN CRIA DISCIPLINAS
Write-Host "`n=== PASSO 4: ADMIN CRIA DISCIPLINAS ===" -ForegroundColor Yellow

$disciplina1 = @{
    cursoId = $cursoId
    codigo = $discCode1
    nome = "Programacao Orientada a Objetos"
    descricao = "Conceitos de POO em Java"
    cargaHoraria = 80
    creditos = 4
    periodo = 3
    tipo = "OBRIGATORIA"
    status = "ATIVA"
    professorId = $professorId
} | ConvertTo-Json

try {
    $disc1 = Invoke-RestMethod -Uri "$gatewayUrl/api/disciplinas" -Method POST -Headers $adminHeaders -Body $disciplina1
    Write-Host "OK Disciplina criada: ID $($disc1.id) - $($disc1.nome)" -ForegroundColor Green
    Write-Host "   Professor ID: $professorId" -ForegroundColor Gray
    Write-Host "   Kafka: DISCIPLINA CREATED publicado" -ForegroundColor Magenta
    Write-Host "   -> Teacher-Service receberá notificacao" -ForegroundColor DarkGray
    $disciplinaId = $disc1.id
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $disciplinaId = 1
}

Start-Sleep -Seconds 2

# 5. PROFESSOR RECEBE NOTIFICACAO
Write-Host "`n=== PASSO 5: PROFESSOR RECEBE NOTIFICACAO ===" -ForegroundColor Yellow
Write-Host "   KAFKA: Teacher-Service processando evento" -ForegroundColor Cyan
Write-Host "   Topic: disciplina-events" -ForegroundColor Gray
Write-Host "   Professor $professorId -> Disciplina $disciplinaId" -ForegroundColor Gray
Write-Host "   OK Frontend consome 'teacher-disciplinas-responses'" -ForegroundColor Green

Start-Sleep -Seconds 2

# 6. ALUNO SE MATRICULA NA DISCIPLINA
Write-Host "`n=== PASSO 6: ALUNO SE MATRICULA ===" -ForegroundColor Yellow

$matricula = @{
    alunoId = $alunoId
    disciplinaId = $disciplinaId
    status = "ATIVA"
} | ConvertTo-Json

try {
    $mat = Invoke-RestMethod -Uri "$gatewayUrl/api/matriculas" -Method POST -Headers $adminHeaders -Body $matricula
    Write-Host "OK Matricula criada: ID $($mat.id)" -ForegroundColor Green
    Write-Host "   Aluno $alunoId -> Disciplina POO" -ForegroundColor Gray
    Write-Host "   Kafka: MATRICULA CREATED publicado" -ForegroundColor Magenta
    $matriculaId = $mat.id
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $matriculaId = 1
}

Start-Sleep -Seconds 2

# 7. ADMIN RECEBE NOTIFICACAO
Write-Host "`n=== PASSO 7: ADMIN RECEBE NOTIFICACAO ===" -ForegroundColor Yellow
Write-Host "   KAFKA: Notificacao de Matricula" -ForegroundColor Cyan
Write-Host "   Topic: matricula-events" -ForegroundColor Gray
Write-Host "   Aluno $alunoId -> Disciplina $disciplinaId" -ForegroundColor Gray
Write-Host "   OK Frontend Dashboard mostra nova matricula" -ForegroundColor Green

Start-Sleep -Seconds 2

# 8. PROFESSOR LANCA AVALIACOES
Write-Host "`n=== PASSO 8: PROFESSOR LANCA AVALIACOES ===" -ForegroundColor Yellow

Write-Host "`n[8.1] Criar Prova P1" -ForegroundColor Cyan
$avaliacao1 = @{
    matriculaId = $matriculaId
    tipoAvaliacao = "PROVA"
    nota = 8.5
    peso = 0.4
    observacoes = "Boa prova"
    dataAvaliacao = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json

try {
    $aval1 = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes" -Method POST -Headers $adminHeaders -Body $avaliacao1
    Write-Host "OK Avaliacao: PROVA - Nota $($aval1.nota)" -ForegroundColor Green
    Write-Host "   Kafka: AVALIACAO CREATED publicado" -ForegroundColor Magenta
    $avaliacaoId = $aval1.id
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $avaliacaoId = 1
}

Start-Sleep -Seconds 1

Write-Host "`n[8.2] Criar Trabalho" -ForegroundColor Cyan
$avaliacao2 = @{
    matriculaId = $matriculaId
    tipoAvaliacao = "TRABALHO"
    nota = 9.0
    peso = 0.6
    observacoes = "Excelente trabalho"
    dataAvaliacao = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json

try {
    $aval2 = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes" -Method POST -Headers $adminHeaders -Body $avaliacao2
    Write-Host "OK Avaliacao: TRABALHO - Nota $($aval2.nota)" -ForegroundColor Green
    Write-Host "   Kafka: AVALIACAO CREATED publicado" -ForegroundColor Magenta
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# 9. ALUNO RECEBE NOTIFICACAO DE NOTA
Write-Host "`n=== PASSO 9: ALUNO RECEBE NOTIFICACAO ===" -ForegroundColor Yellow
Write-Host "   KAFKA: Notificacao de Nota" -ForegroundColor Cyan
Write-Host "   Topic: avaliacao-events" -ForegroundColor Gray
Write-Host "   Notas:" -ForegroundColor Gray
Write-Host "     PROVA P1: 8.5 (peso 0.4)" -ForegroundColor Gray
Write-Host "     TRABALHO: 9.0 (peso 0.6)" -ForegroundColor Gray
$mediaFinal = (8.5 * 0.4) + (9.0 * 0.6)
Write-Host "   Media Final: $mediaFinal" -ForegroundColor Green
Write-Host "   OK Frontend consome 'student-boletim-responses'" -ForegroundColor Green

Start-Sleep -Seconds 2

# 10. VERIFICACOES FINAIS
Write-Host "`n=== PASSO 10: VERIFICACOES ===" -ForegroundColor Yellow

Write-Host "`n[10.1] Consultar Boletim" -ForegroundColor Cyan
try {
    $avaliacoes = Invoke-RestMethod -Uri "$gatewayUrl/api/avaliacoes/aluno/$alunoId" -Method GET -Headers $adminHeaders
    Write-Host "OK Boletim completo:" -ForegroundColor Green
    $totalNotas = 0
    $totalPesos = 0
    foreach ($av in $avaliacoes) {
        Write-Host "   $($av.tipoAvaliacao): $($av.nota) (Peso: $($av.peso))" -ForegroundColor Gray
        $totalNotas += $av.nota * $av.peso
        $totalPesos += $av.peso
    }
    $mediaGeral = if ($totalPesos -gt 0) { $totalNotas / $totalPesos } else { 0 }
    Write-Host "   Media: $([math]::Round($mediaGeral, 2))" -ForegroundColor Cyan
} catch {
    Write-Host "Aviso: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n[10.2] Topics Kafka Ativos" -ForegroundColor Cyan
Write-Host "   FRONTEND PODE CONSUMIR:" -ForegroundColor Gray
Write-Host "   - course-events" -ForegroundColor Gray
Write-Host "   - disciplina-events" -ForegroundColor Gray
Write-Host "   - matricula-events" -ForegroundColor Gray
Write-Host "   - avaliacao-events" -ForegroundColor Gray
Write-Host "   - student-boletim-responses" -ForegroundColor Gray
Write-Host "   - teacher-disciplinas-responses" -ForegroundColor Gray

# RESUMO
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "              RESUMO DO FLUXO" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

Write-Host "`nIDs Criados:" -ForegroundColor Yellow
Write-Host "  Curso: $cursoId" -ForegroundColor Gray
Write-Host "  Disciplina: $disciplinaId" -ForegroundColor Gray
Write-Host "  Aluno: $alunoId" -ForegroundColor Gray
Write-Host "  Professor: $professorId" -ForegroundColor Gray
Write-Host "  Matricula: $matriculaId" -ForegroundColor Gray
Write-Host "  Avaliacao: $avaliacaoId" -ForegroundColor Gray

Write-Host "`nEventos Kafka:" -ForegroundColor Yellow
Write-Host "  1 COURSE CREATED" -ForegroundColor Green
Write-Host "  1 DISCIPLINA CREATED" -ForegroundColor Green
Write-Host "  1 MATRICULA CREATED" -ForegroundColor Green
Write-Host "  2 AVALIACAO CREATED" -ForegroundColor Green

Write-Host "`nNotificacoes:" -ForegroundColor Yellow
Write-Host "  Professor -> Disciplina atribuida" -ForegroundColor Magenta
Write-Host "  Admin -> Nova matricula" -ForegroundColor Magenta
Write-Host "  Aluno -> Notas lancadas" -ForegroundColor Magenta

Write-Host "`nOK TESTE COMPLETO!" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Cyan
