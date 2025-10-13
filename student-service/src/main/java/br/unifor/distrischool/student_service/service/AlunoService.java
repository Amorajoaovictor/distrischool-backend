package br.unifor.distrischool.student_service.service;

import br.unifor.distrischool.student_service.model.Aluno;
import br.unifor.distrischool.student_service.repository.AlunoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Base64;
import java.util.List;
import java.util.Optional;

@Service
public class AlunoService {
    private static final String ALGORITHM = "AES";
    private static final String SECRET_KEY = "distrischoolky16"; // Exatamente 16 chars

    @Autowired
    private AlunoRepository alunoRepository;

    public Aluno salvar(Aluno aluno) {
        aluno.setHistoricoAcademicoCriptografado(encrypt(aluno.getHistoricoAcademicoCriptografado()));
        return alunoRepository.save(aluno);
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
}
