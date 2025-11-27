# README - Testes do Course Service

## Scripts de Teste Disponíveis

### 1. `test-course-service-quick.ps1` ⚡
**Teste rápido automatizado de todas as APIs**

Executa 13 testes automáticos cobrindo:
- ✅ CRUD de Cursos
- ✅ CRUD de Disciplinas
- ✅ CRUD de Matrículas
- ✅ CRUD de Avaliações
- ✅ Validações (matrícula duplicada, filtros, etc)

**Como usar:**
```powershell
.\test-course-service-quick.ps1
```

---

### 2. `test-course-service-complete.ps1` 🎯
**Teste completo do fluxo end-to-end**

Simula todo o fluxo acadêmico:
1. Cria cursos (Ciências da Computação, Direito)
2. Cria disciplinas (POO, CANA, Matemática Discreta)
3. Matricula alunos nas disciplinas
4. Professor consulta alunos matriculados
5. Professor lança notas
6. Alunos consultam suas notas
7. Relatórios e consultas

**Como usar:**
```powershell
.\test-course-service-complete.ps1
```

---

### 3. `test-aluno-fluxo.ps1` 🎓
**Teste interativo do fluxo do aluno**

Permite simular as ações de um aluno:
- Ver disciplinas disponíveis do curso
- Se matricular em disciplinas
- Ver suas matrículas ativas
- Consultar todas as notas
- Ver notas de disciplina específica
- Calcular médias

**Como usar:**
```powershell
.\test-aluno-fluxo.ps1
# Será solicitado: ID do aluno e ID do curso
```

---

### 4. `test-professor-fluxo.ps1` 👨‍🏫
**Teste interativo do fluxo do professor**

Permite simular as ações de um professor:
- Ver suas disciplinas
- Ver alunos matriculados
- Lançar notas para alunos
- Ver todas as avaliações da disciplina
- Atualizar notas
- Relatório de desempenho da turma (estatísticas)

**Como usar:**
```powershell
.\test-professor-fluxo.ps1
# Será solicitado: ID do professor
```

---

## Pré-requisitos

1. **Course Service rodando na porta 8085**
   ```bash
   cd course-service
   mvn spring-boot:run
   ```

2. **Banco de dados PostgreSQL configurado**

3. **Token de autenticação**
   - Edite os scripts e substitua `"Bearer seu-token-aqui"` pelo token válido

---

## Ordem Recomendada de Testes

### Primeira vez:
1. `test-course-service-quick.ps1` - Para validar que tudo está funcionando
2. `test-course-service-complete.ps1` - Para popular o banco com dados de teste
3. `test-professor-fluxo.ps1` - Para testar funcionalidades do professor
4. `test-aluno-fluxo.ps1` - Para testar funcionalidades do aluno

### Testes subsequentes:
- Use os scripts interativos para simular cenários específicos

---

## Endpoints Testados

### Cursos
- `POST /api/cursos` - Criar curso
- `GET /api/cursos` - Listar todos
- `GET /api/cursos/{id}` - Buscar por ID
- `GET /api/cursos/codigo/{codigo}` - Buscar por código
- `PUT /api/cursos/{id}` - Atualizar
- `DELETE /api/cursos/{id}` - Deletar

### Disciplinas
- `POST /api/disciplinas` - Criar disciplina
- `GET /api/disciplinas` - Listar todas
- `GET /api/disciplinas/{id}` - Buscar por ID
- `GET /api/disciplinas/curso/{cursoId}` - Listar por curso
- `GET /api/disciplinas/professor/{professorId}` - Listar por professor
- `PUT /api/disciplinas/{id}` - Atualizar
- `DELETE /api/disciplinas/{id}` - Deletar

### Matrículas
- `POST /api/matriculas` - Criar matrícula
- `GET /api/matriculas/aluno/{alunoId}` - Todas do aluno
- `GET /api/matriculas/aluno/{alunoId}/ativas` - Ativas do aluno
- `GET /api/matriculas/disciplina/{disciplinaId}` - Todas da disciplina
- `GET /api/matriculas/disciplina/{disciplinaId}/ativas` - Ativas da disciplina
- `PUT /api/matriculas/{id}/status` - Alterar status
- `DELETE /api/matriculas/{id}` - Deletar

### Avaliações
- `POST /api/avaliacoes` - Criar avaliação
- `GET /api/avaliacoes/{id}` - Buscar por ID
- `GET /api/avaliacoes/aluno/{alunoId}` - Todas do aluno
- `GET /api/avaliacoes/disciplina/{disciplinaId}` - Todas da disciplina
- `GET /api/avaliacoes/aluno/{alunoId}/disciplina/{disciplinaId}` - Específicas
- `PUT /api/avaliacoes/{id}` - Atualizar
- `DELETE /api/avaliacoes/{id}` - Deletar

---

## Validações Testadas

✅ Não permite matrícula duplicada (aluno + disciplina)
✅ Calcula médias ponderadas corretamente
✅ Filtra matrículas por status (ATIVA, TRANCADA, etc)
✅ Notas entre 0.0 e 10.0
✅ Curso do aluno não pode ser alterado após criação
✅ Relacionamentos entre entidades (curso -> disciplina -> matrícula -> avaliação)

---

## Troubleshooting

### Erro de conexão
- Verifique se o serviço está rodando: `http://localhost:8085`
- Teste com: `curl http://localhost:8085/actuator/health`

### Erro 401/403
- Verifique o token de autenticação nos scripts
- Token deve começar com "Bearer "

### Erro ao criar matrícula
- Certifique-se que curso e disciplina existem
- Verifique se aluno já não está matriculado na disciplina

---

## Exemplos de Dados para Teste Manual

### Curso
```json
{
  "nome": "Ciências da Computação",
  "codigo": "CC001",
  "descricao": "Bacharelado em CC",
  "duracaoSemestres": 8,
  "modalidade": "Presencial",
  "turno": "Noturno",
  "status": "ATIVO"
}
```

### Disciplina
```json
{
  "nome": "POO",
  "codigo": "POO001",
  "cargaHoraria": 80,
  "creditos": 4,
  "cursoId": 1,
  "professorId": 1,
  "periodo": 3,
  "tipo": "OBRIGATORIA",
  "status": "ATIVA"
}
```

### Matrícula
```json
{
  "alunoId": 1,
  "disciplinaId": 1,
  "status": "ATIVA"
}
```

### Avaliação
```json
{
  "matriculaId": 1,
  "tipoAvaliacao": "PROVA",
  "nota": 8.5,
  "peso": 0.4,
  "observacoes": "Ótimo desempenho",
  "dataAvaliacao": "2025-11-19T10:30:00"
}
```
