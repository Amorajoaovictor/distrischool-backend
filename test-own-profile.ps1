# Teste - Visualizar Proprio Perfil (Student e Teacher)

$GATEWAY_URL = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TESTE: VER PROPRIO PERFIL" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Funcao para fazer login
function Get-AuthToken {
    param([string]$Email, [string]$Password, [string]$Role)
    
    Write-Host "[AUTH] Fazendo login como $Role ($Email)..." -ForegroundColor Cyan
    
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
            Write-Host "  ✅ Token obtido" -ForegroundColor Green
            return $response.token
        }
    } catch {
        Write-Host "  ❌ Falha ao obter token: $($_.Exception.Message)" -ForegroundColor Red
    }
    return $null
}

# ========================================================================
# FASE 1: LOGIN COMO STUDENT
# ========================================================================

Write-Host "`n========== FASE 1: STUDENT - VER PROPRIO PERFIL ==========" -ForegroundColor Yellow

$STUDENT_TOKEN = Get-AuthToken -Email "teste.user.2025999@unifor.br" -Password "ecfd4e61" -Role "STUDENT"

if ($STUDENT_TOKEN) {
    Write-Host "`n[STUDENT] Buscando lista de alunos..." -ForegroundColor Cyan
    
    try {
        $headers = @{ "Authorization" = "Bearer $STUDENT_TOKEN" }
        $students = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos" `
            -Method GET `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "  ✅ Lista obtida com sucesso!" -ForegroundColor Green
        Write-Host "  Alunos retornados: $($students.Count)" -ForegroundColor Gray
        
        if ($students.Count -gt 0) {
            $student = $students[0]
            Write-Host "`n  Dados do aluno:" -ForegroundColor Cyan
            Write-Host "    ID: $($student.id)" -ForegroundColor Gray
            Write-Host "    Nome: $($student.nome)" -ForegroundColor Gray
            Write-Host "    Matricula: $($student.matricula)" -ForegroundColor Gray
            Write-Host "    Email esperado: $($student.nome.ToLower().Replace(' ', '.')).$($student.matricula)@unifor.br" -ForegroundColor Gray
            
            # Tentar buscar por ID
            Write-Host "`n[STUDENT] Buscando aluno por ID: $($student.id)..." -ForegroundColor Cyan
            try {
                $studentDetail = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/$($student.id)" `
                    -Method GET `
                    -Headers $headers `
                    -ErrorAction Stop
                
                Write-Host "  ✅ Conseguiu buscar proprio perfil!" -ForegroundColor Green
                Write-Host "    Nome: $($studentDetail.nome)" -ForegroundColor Gray
                Write-Host "    Turma: $($studentDetail.turma)" -ForegroundColor Gray
            } catch {
                $statusCode = $_.Exception.Response.StatusCode.value__
                Write-Host "  ❌ FALHOU ao buscar proprio perfil: Status $statusCode" -ForegroundColor Red
                Write-Host "    Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
            }
            
            # Tentar buscar outro aluno (deve falhar)
            $otherStudentId = if ($student.id -eq 1) { 2 } else { 1 }
            Write-Host "`n[STUDENT] Tentando buscar OUTRO aluno (ID: $otherStudentId)..." -ForegroundColor Cyan
            try {
                $otherStudent = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/$otherStudentId" `
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
            
            # Tentar editar proprio perfil
            Write-Host "`n[STUDENT] Tentando editar proprio perfil..." -ForegroundColor Cyan
            try {
                $updateBody = @{
                    nome = $student.nome
                    dataNascimento = $student.dataNascimento
                    turma = $student.turma
                    endereco = "Endereco Atualizado Via Teste"
                    contato = $student.contato
                    matricula = $student.matricula
                    historicoAcademico = "Historico atualizado"
                } | ConvertTo-Json
                
                $updated = Invoke-RestMethod -Uri "$GATEWAY_URL/api/alunos/$($student.id)" `
                    -Method PUT `
                    -Headers $headers `
                    -ContentType "application/json" `
                    -Body $updateBody `
                    -ErrorAction Stop
                
                Write-Host "  ✅ Conseguiu editar proprio perfil!" -ForegroundColor Green
                Write-Host "    Endereco atualizado: $($updated.endereco)" -ForegroundColor Gray
            } catch {
                $statusCode = $_.Exception.Response.StatusCode.value__
                Write-Host "  ❌ FALHOU ao editar proprio perfil: Status $statusCode" -ForegroundColor Red
                Write-Host "    Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
            }
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "  ❌ FALHOU ao listar alunos: Status $statusCode" -ForegroundColor Red
        Write-Host "    Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
        
        if ($statusCode -eq 403) {
            Write-Host "`n  PROBLEMA IDENTIFICADO: StudentPermissionService pode não estar validando corretamente!" -ForegroundColor Yellow
            Write-Host "  O student deveria ver sua propria lista (com apenas ele mesmo)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "⚠️  Nao foi possivel obter token de STUDENT" -ForegroundColor Yellow
}

# ========================================================================
# FASE 2: LOGIN COMO TEACHER (se existir)
# ========================================================================

Write-Host "`n========== FASE 2: TEACHER - VER PROPRIO PERFIL ==========" -ForegroundColor Yellow

Write-Host "[SETUP] Criando professor de teste..." -ForegroundColor Cyan
$teacherBody = @{
    nome = "Professor Teste Perfil"
    matricula = "PROFTEST001"
    qualificacao = "Mestrado"
    contato = "85999887766"
} | ConvertTo-Json

try {
    # Criar professor sem autenticação para verificar se ainda permite
    $teacher = Invoke-RestMethod -Uri "$GATEWAY_URL/api/teachers" `
        -Method POST `
        -ContentType "application/json" `
        -Body $teacherBody `
        -ErrorAction Stop
    
    Write-Host "  ⚠️  Professor criado sem autenticacao (ID: $($teacher.id))" -ForegroundColor Yellow
    Write-Host "  Aguardando criacao de usuario via Kafka..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    # Tentar fazer login como professor
    $TEACHER_TOKEN = Get-AuthToken -Email "professor.teste.prof.PROFTEST001@unifor.br" -Password "senha_gerada" -Role "TEACHER"
    
    if ($TEACHER_TOKEN) {
        Write-Host "`n[TEACHER] Buscando proprio perfil (ID: $($teacher.id))..." -ForegroundColor Cyan
        
        try {
            $headers = @{ "Authorization" = "Bearer $TEACHER_TOKEN" }
            $teacherDetail = Invoke-RestMethod -Uri "$GATEWAY_URL/api/teachers/$($teacher.id)" `
                -Method GET `
                -Headers $headers `
                -ErrorAction Stop
            
            Write-Host "  ✅ Conseguiu buscar proprio perfil!" -ForegroundColor Green
            Write-Host "    Nome: $($teacherDetail.nome)" -ForegroundColor Gray
            Write-Host "    Qualificacao: $($teacherDetail.qualificacao)" -ForegroundColor Gray
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Host "  ❌ FALHOU ao buscar proprio perfil: Status $statusCode" -ForegroundColor Red
        }
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 403 -or $statusCode -eq 401) {
        Write-Host "  ✅ CORRETO: POST bloqueado (precisa ser ADMIN)" -ForegroundColor Green
        Write-Host "  Pulando testes de TEACHER pois nao podemos criar sem ADMIN" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Erro ao criar professor: Status $statusCode" -ForegroundColor Red
    }
}

# ========================================================================
# RESUMO
# ========================================================================

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "RESUMO" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`nCOMPORTAMENTO ESPERADO:" -ForegroundColor Yellow
Write-Host "  ✅ STUDENT consegue listar alunos (retorna apenas ele mesmo)" -ForegroundColor Green
Write-Host "  ✅ STUDENT consegue buscar proprio perfil por ID" -ForegroundColor Green
Write-Host "  ✅ STUDENT consegue editar proprio perfil" -ForegroundColor Green
Write-Host "  ❌ STUDENT NAO consegue buscar outro aluno (403)" -ForegroundColor Red
Write-Host "  ❌ STUDENT NAO consegue editar outro aluno (403)" -ForegroundColor Red

Write-Host "`nVERIFICAR:" -ForegroundColor Yellow
Write-Host "  - StudentPermissionService.canAccessStudent() deve validar por email" -ForegroundColor White
Write-Host "  - Email gerado: primeiro.ultimo.matricula@unifor.br" -ForegroundColor White
Write-Host "  - SecurityContext deve conter email do usuario autenticado" -ForegroundColor White

Write-Host "`n✅ Teste concluido!`n" -ForegroundColor Green
