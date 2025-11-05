1. POST /api/alunos (student-service)
   ↓
2. Salva no PostgreSQL (id=53, nome="Ana Paula Costa")
   ↓
3. Gera email: ana.costa.2025101@unifor.br
   ↓
4. Publica evento Kafka → topic: student-events
   {
     "email": "ana.costa.2025101@unifor.br",
     "fullName": "Ana Paula Costa",
     "role": "STUDENT",
     "externalId": "53"
   }
   ↓
5. Auth-service consome evento
   ↓
6. Cria usuário automaticamente
   - Email: ana.costa.2025101@unifor.br
   - Senha temp: 0980e678 (BCrypt hasheada)
   - Role: ROLE_STUDENT
   ↓
7. Login funcional
   POST /api/auth/login
   → Retorna JWT token válido ✅