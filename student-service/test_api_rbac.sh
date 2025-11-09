#!/bin/bash

# Script de Testes Automatizados - Student Service API com RBAC
# Versão 2.0 - Com autenticação JWT e controle de acesso

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"
PASSED=0
FAILED=0

# Tokens de autenticação
ADMIN_TOKEN=""
STUDENT_TOKEN=""

# Função para imprimir com cor
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Função para fazer login e obter token
get_token() {
    email=$1
    password=$2
    role=$3
    
    print_color "$CYAN" "🔐 Fazendo login como $role ($email)..."
    
    login_data=$(cat <<EOF
{
  "email": "$email",
  "password": "$password"
}
EOF
)
    
    response=$(curl -s -X POST "$BASE_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "$login_data")
    
    token=$(echo "$response" | jq -r '.token' 2>/dev/null)
    
    if [ "$token" != "null" ] && [ ! -z "$token" ]; then
        print_color "$GREEN" "   ✅ Token obtido para $role"
        echo "$token"
    else
        print_color "$RED" "   ❌ Falha ao obter token para $role"
        echo ""
    fi
}

# Função para testar endpoint com autenticação
test_endpoint() {
    test_name=$1
    method=$2
    endpoint=$3
    data=$4
    expected_status=$5
    token=$6
    
    print_color "$BLUE" "\n=== Teste: $test_name ==="
    
    if [ -z "$data" ]; then
        if [ -z "$token" ]; then
            response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
                -H "Authorization: Bearer $token")
        fi
    else
        if [ -z "$token" ]; then
            response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
                -H "Content-Type: application/json" \
                -d "$data")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $token" \
                -d "$data")
        fi
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" == "$expected_status" ]; then
        print_color "$GREEN" "✓ PASSOU - Status: $http_code"
        PASSED=$((PASSED + 1))
    else
        print_color "$RED" "✗ FALHOU - Esperado: $expected_status, Recebido: $http_code"
        FAILED=$((FAILED + 1))
    fi
    
    echo "Resposta: $body" | jq . 2>/dev/null || echo "Resposta: $body"
    
    echo "$body"
}

# Banner
print_color "$MAGENTA" "╔════════════════════════════════════════════════╗"
print_color "$MAGENTA" "║   STUDENT SERVICE API - TESTES COM RBAC       ║"
print_color "$MAGENTA" "╚════════════════════════════════════════════════╝"

# Verificar dependências
if ! command -v jq &> /dev/null; then
    print_color "$YELLOW" "⚠ Aviso: jq não encontrado. Instale para melhor formatação: sudo apt-get install jq"
fi

# ==================== BLOCO 1: AUTENTICAÇÃO ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 1: AUTENTICAÇÃO"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ADMIN_TOKEN=$(get_token "admin@distrischool.com" "admin123" "ADMIN")
STUDENT_TOKEN=$(get_token "teste.user.2025999@unifor.br" "ecfd4e61" "STUDENT")

if [ -z "$ADMIN_TOKEN" ]; then
    print_color "$YELLOW" "\n⚠️  AVISO: Token ADMIN não disponível. Alguns testes serão pulados."
    print_color "$YELLOW" "   Para criar um admin, execute:"
    print_color "$YELLOW" "   POST /api/v1/admins com { name, email, password, role }"
fi

# ==================== BLOCO 2: HEALTH CHECK ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 2: HEALTH CHECK"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_endpoint "Health Check" "GET" "/actuator/health" "" "200" ""

# ==================== BLOCO 3: CRIAR ALUNOS (ADMIN) ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 3: CRIAR ALUNOS (APENAS ADMIN)"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -z "$ADMIN_TOKEN" ]; then
    aluno1_data='{
      "nome": "João Victor Amora",
      "dataNascimento": "2000-01-15",
      "endereco": "Rua das Flores, 123",
      "contato": "85999999999",
      "matricula": "2024001",
      "turma": "3A",
      "historicoAcademico": "Cursou Matemática e Português com bom desempenho"
    }'

    aluno1_response=$(test_endpoint "Criar Aluno 1 - João Victor (ADMIN)" "POST" "/api/alunos" "$aluno1_data" "200" "$ADMIN_TOKEN")
    aluno1_id=$(echo "$aluno1_response" | jq -r '.id' 2>/dev/null)

    aluno2_data='{
      "nome": "Maria Silva Santos",
      "dataNascimento": "1999-05-20",
      "endereco": "Av. Principal, 789",
      "contato": "85987654321",
      "matricula": "2024002",
      "turma": "3A",
      "historicoAcademico": "Excelente desempenho em Ciências"
    }'

    aluno2_response=$(test_endpoint "Criar Aluno 2 - Maria Silva (ADMIN)" "POST" "/api/alunos" "$aluno2_data" "200" "$ADMIN_TOKEN")
    aluno2_id=$(echo "$aluno2_response" | jq -r '.id' 2>/dev/null)

    print_color "$GREEN" "\n✓ Alunos criados - IDs: $aluno1_id, $aluno2_id"
else
    print_color "$YELLOW" "⚠️  Pulando criação de alunos - Token ADMIN não disponível"
fi

# ==================== BLOCO 4: TESTAR CRIAÇÃO SEM ADMIN ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 4: TESTAR CRIAÇÃO SEM PERMISSÃO"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

aluno_hack='{
  "nome": "Tentativa Hack",
  "dataNascimento": "2000-01-01",
  "turma": "1A"
}'

test_endpoint "Criar aluno SEM TOKEN (deve FALHAR)" "POST" "/api/alunos" "$aluno_hack" "401" ""

if [ ! -z "$STUDENT_TOKEN" ]; then
    test_endpoint "Criar aluno com STUDENT TOKEN (deve FALHAR)" "POST" "/api/alunos" "$aluno_hack" "403" "$STUDENT_TOKEN"
fi

# ==================== BLOCO 5: BUSCAR ALUNOS (ADMIN) ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 5: BUSCAR ALUNOS (ADMIN)"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -z "$ADMIN_TOKEN" ]; then
    test_endpoint "Listar todos alunos (ADMIN)" "GET" "/api/alunos" "" "200" "$ADMIN_TOKEN"
    
    if [ ! -z "$aluno1_id" ]; then
        test_endpoint "Buscar por ID - Aluno 1 (ADMIN)" "GET" "/api/alunos/$aluno1_id" "" "200" "$ADMIN_TOKEN"
    fi
    
    test_endpoint "Buscar por Matrícula - 2024001 (ADMIN)" "GET" "/api/alunos/matricula/2024001" "" "200" "$ADMIN_TOKEN"
    test_endpoint "Buscar por Nome - João (ADMIN)" "GET" "/api/alunos/nome/João" "" "200" "$ADMIN_TOKEN"
    test_endpoint "Buscar por Turma - 3A (ADMIN)" "GET" "/api/alunos/turma/3A" "" "200" "$ADMIN_TOKEN"
else
    print_color "$YELLOW" "⚠️  Pulando buscas - Token ADMIN não disponível"
fi

# ==================== BLOCO 6: STUDENT - PRÓPRIO PERFIL ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 6: STUDENT - VISUALIZAR PRÓPRIO PERFIL"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -z "$STUDENT_TOKEN" ]; then
    my_profile=$(test_endpoint "Ver próprio perfil (/me) - STUDENT" "GET" "/api/alunos/me" "" "200" "$STUDENT_TOKEN")
    my_id=$(echo "$my_profile" | jq -r '.id' 2>/dev/null)
    
    if [ ! -z "$my_id" ] && [ "$my_id" != "null" ]; then
        print_color "$GREEN" "   Meu ID: $my_id"
        
        test_endpoint "Ver próprio perfil por ID - STUDENT" "GET" "/api/alunos/$my_id" "" "200" "$STUDENT_TOKEN"
        
        # Tentar acessar outro aluno
        other_id=$(if [ "$my_id" == "1" ]; then echo "2"; else echo "1"; fi)
        test_endpoint "Tentar acessar OUTRO aluno (deve FALHAR)" "GET" "/api/alunos/$other_id" "" "403" "$STUDENT_TOKEN"
    fi
    
    # Tentar listar todos
    test_endpoint "Tentar listar TODOS alunos (deve FALHAR)" "GET" "/api/alunos" "" "403" "$STUDENT_TOKEN"
else
    print_color "$YELLOW" "⚠️  Pulando testes STUDENT - Token não disponível"
fi

# ==================== BLOCO 7: EDITAR ALUNO ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 7: EDITAR ALUNOS"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -z "$ADMIN_TOKEN" ] && [ ! -z "$aluno1_id" ]; then
    aluno1_edit='{
      "nome": "João Victor Amora - ATUALIZADO",
      "dataNascimento": "2000-01-15",
      "endereco": "Rua Atualizada, 999",
      "contato": "85999999999",
      "matricula": "2024001",
      "turma": "3B",
      "historicoAcademico": "Histórico atualizado"
    }'
    
    test_endpoint "Editar Aluno 1 (ADMIN)" "PUT" "/api/alunos/$aluno1_id" "$aluno1_edit" "200" "$ADMIN_TOKEN"
fi

if [ ! -z "$STUDENT_TOKEN" ] && [ ! -z "$my_id" ] && [ "$my_id" != "null" ]; then
    my_edit='{
      "nome": "Meu Nome Atualizado",
      "dataNascimento": "2000-01-01",
      "endereco": "Meu Endereco Atualizado",
      "contato": "85999887766",
      "matricula": "2025999",
      "turma": "TEST",
      "historicoAcademico": "Atualizado por mim"
    }'
    
    test_endpoint "Editar PRÓPRIO perfil (STUDENT)" "PUT" "/api/alunos/$my_id" "$my_edit" "200" "$STUDENT_TOKEN"
    
    # Tentar editar outro aluno
    other_id=$(if [ "$my_id" == "1" ]; then echo "2"; else echo "1"; fi)
    test_endpoint "Tentar editar OUTRO aluno (deve FALHAR)" "PUT" "/api/alunos/$other_id" "$my_edit" "403" "$STUDENT_TOKEN"
fi

# ==================== BLOCO 8: EXCLUIR ALUNOS ====================
print_color "$YELLOW" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$YELLOW" "BLOCO 8: EXCLUIR ALUNOS (APENAS ADMIN)"
print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -z "$STUDENT_TOKEN" ]; then
    test_endpoint "Tentar DELETAR com STUDENT (deve FALHAR)" "DELETE" "/api/alunos/1" "" "403" "$STUDENT_TOKEN"
fi

test_endpoint "Tentar DELETAR SEM TOKEN (deve FALHAR)" "DELETE" "/api/alunos/1" "" "401" ""

if [ ! -z "$ADMIN_TOKEN" ] && [ ! -z "$aluno2_id" ]; then
    test_endpoint "Excluir Aluno 2 (ADMIN)" "DELETE" "/api/alunos/$aluno2_id" "" "204" "$ADMIN_TOKEN"
    
    test_endpoint "Verificar exclusão (deve dar 404)" "GET" "/api/alunos/$aluno2_id" "" "404" "$ADMIN_TOKEN"
fi

# ==================== RESULTADO FINAL ====================
print_color "$MAGENTA" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$MAGENTA" "RESULTADO FINAL"
print_color "$MAGENTA" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL=$((PASSED + FAILED))

if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PASSED * 100 / $TOTAL" | bc 2>/dev/null || echo "N/A")
else
    SUCCESS_RATE="0"
fi

print_color "$GREEN" "✓ Testes Passou: $PASSED"
print_color "$RED" "✗ Testes Falhou: $FAILED"
print_color "$YELLOW" "Total de Testes: $TOTAL"
print_color "$YELLOW" "Taxa de Sucesso: ${SUCCESS_RATE}%"

print_color "$CYAN" "\n📋 RESUMO RBAC:"
print_color "$CYAN" "   ✅ ADMIN: Acesso total"
print_color "$CYAN" "   ✅ STUDENT: Apenas próprio perfil via /me"
print_color "$CYAN" "   🔒 POST/DELETE: Apenas ADMIN"
print_color "$CYAN" "   🔒 Sem token: Bloqueado (401)"

if [ $FAILED -eq 0 ]; then
    print_color "$GREEN" "\n🎉 TODOS OS TESTES PASSARAM! 🎉"
    exit 0
else
    print_color "$RED" "\n⚠️  ALGUNS TESTES FALHARAM ⚠️"
    exit 1
fi
