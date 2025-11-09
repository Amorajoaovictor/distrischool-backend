package br.unifor.distrischool.student_service.service;

import br.unifor.distrischool.student_service.event.StudentEvent;
import br.unifor.distrischool.student_service.kafka.StudentEventProducer;
import br.unifor.distrischool.student_service.model.Aluno;
import br.unifor.distrischool.student_service.repository.AlunoRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.text.Normalizer;
import java.util.Base64;
import java.util.List;
import java.util.Optional;

@Service
public class AlunoService {
    private static final Logger logger = LoggerFactory.getLogger(AlunoService.class);
    private static final String ALGORITHM = "AES";
    private static final String SECRET_KEY = "distrischoolky16"; // Exatamente 16 chars

    @Autowired
    private AlunoRepository alunoRepository;
    
    @Autowired
    private StudentEventProducer studentEventProducer;

    public List<Aluno> listarTodos() {
        return alunoRepository.findAll();
    }

    public Aluno salvar(Aluno aluno) {
        // Gera matrícula automaticamente se não foi fornecida
        if (aluno.getMatricula() == null || aluno.getMatricula().isEmpty()) {
            aluno.setMatricula(gerarMatricula());
        }
        aluno.setHistoricoAcademicoCriptografado(encrypt(aluno.getHistoricoAcademicoCriptografado()));
        
        // Salva o aluno no banco
        Aluno savedAluno = alunoRepository.save(aluno);
        
        // Gera email institucional
        String email = gerarEmailInstitucional(savedAluno.getNome(), savedAluno.getMatricula());
        
        // Publica evento Kafka para criação de credenciais de autenticação
        try {
            StudentEvent event = new StudentEvent(
                savedAluno.getId(),
                savedAluno.getNome(),
                savedAluno.getMatricula(),
                email,
                "CREATED"
            );
            studentEventProducer.publishStudentEvent(event);
            logger.info("📤 Evento de criação publicado para aluno: {} ({})", savedAluno.getNome(), email);
        } catch (Exception e) {
            logger.error("❌ Erro ao publicar evento Kafka para aluno {}", savedAluno.getId(), e);
            // Não falha a criação do aluno se o evento falhar
        }
        
        return savedAluno;
    }

    public Aluno editar(Long id, Aluno alunoAtualizado) {
        Optional<Aluno> opt = alunoRepository.findById(id);
        if (opt.isPresent()) {
            Aluno aluno = opt.get();
            aluno.setNome(alunoAtualizado.getNome());
            aluno.setDataNascimento(alunoAtualizado.getDataNascimento());
            aluno.setEndereco(alunoAtualizado.getEndereco());
            aluno.setContato(alunoAtualizado.getContato());
            aluno.setMatricula(alunoAtualizado.getMatricula());
            aluno.setTurma(alunoAtualizado.getTurma());
            aluno.setHistoricoAcademicoCriptografado(encrypt(alunoAtualizado.getHistoricoAcademicoCriptografado()));
            return alunoRepository.save(aluno);
        }
        throw new RuntimeException("Aluno não encontrado");
    }

    public void excluir(Long id) {
        alunoRepository.deleteById(id);
    }

    public Optional<Aluno> buscarPorId(Long id) {
        return alunoRepository.findById(id);
    }

    public Optional<Aluno> buscarPorMatricula(String matricula) {
        return alunoRepository.findByMatricula(matricula);
    }

    public List<Aluno> buscarPorNome(String nome) {
        return alunoRepository.findByNomeContainingIgnoreCase(nome);
    }

    public List<Aluno> buscarPorTurma(String turma) {
        return alunoRepository.findByTurma(turma);
    }

    /**
     * Busca o aluno pelo email do usuário logado
     */
    public Optional<Aluno> buscarPorEmail() {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            return Optional.empty();
        }
        
        String email = authentication.getName(); // Email do usuário logado
        
        // Procura o aluno cujo email institucional corresponda
        List<Aluno> todosAlunos = alunoRepository.findAll();
        for (Aluno aluno : todosAlunos) {
            String emailAluno = gerarEmailInstitucional(aluno.getNome(), aluno.getMatricula());
            if (emailAluno.equalsIgnoreCase(email)) {
                return Optional.of(aluno);
            }
        }
        
        return Optional.empty();
    }

    private String encrypt(String value) {
        try {
            Key key = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, key);
            byte[] encrypted = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao criptografar histórico acadêmico", e);
        }
    }

    public String decrypt(String encryptedValue) {
        try {
            Key key = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, key);
            byte[] decoded = Base64.getDecoder().decode(encryptedValue);
            return new String(cipher.doFinal(decoded), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao descriptografar histórico acadêmico", e);
        }
    }

    private String gerarMatricula() {
        // Gera matrícula no formato: ANO + NÚMERO_SEQUENCIAL
        int ano = java.time.Year.now().getValue();
        long count = alunoRepository.count();
        // Formato: 2025001, 2025002, etc.
        return String.format("%d%03d", ano, count + 1);
    }
    
    private String gerarEmailInstitucional(String nomeCompleto, String matricula) {
        // Remove acentos e caracteres especiais
        String nome = Normalizer.normalize(nomeCompleto, Normalizer.Form.NFD)
                .replaceAll("[^\\p{ASCII}]", "")
                .toLowerCase()
                .trim();
        
        // Pega primeiro nome e último sobrenome
        String[] partes = nome.split("\\s+");
        String primeiroNome = partes[0];
        String ultimoSobrenome = partes.length > 1 ? partes[partes.length - 1] : "";
        
        // Formato: primeiro.ultimo.matricula@unifor.br
        // Exemplo: maria.silva.2024777@unifor.br
        if (!ultimoSobrenome.isEmpty()) {
            return String.format("%s.%s.%s@unifor.br", primeiroNome, ultimoSobrenome, matricula);
        } else {
            return String.format("%s.%s@unifor.br", primeiroNome, matricula);
        }
    }
}
