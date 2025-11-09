package br.unifor.distrischool.student_service.security;

import br.unifor.distrischool.student_service.model.Aluno;
import br.unifor.distrischool.student_service.repository.AlunoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.Optional;

@Service("studentPermission")
public class StudentPermissionService {

    @Autowired
    private AlunoRepository alunoRepository;

    /**
     * Verifica se o usuário autenticado pode acessar/modificar o aluno com o ID fornecido.
     * Regras:
     * - ADMIN: pode acessar qualquer aluno
     * - STUDENT: pode acessar apenas seu próprio perfil (email deve corresponder ao email gerado do aluno)
     */
    public boolean canAccessStudent(Long studentId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            return false;
        }

        // Se é ADMIN, pode acessar qualquer aluno
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_ADMIN"))) {
            return true;
        }

        // Se é STUDENT, verifica se o email corresponde ao aluno
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_STUDENT"))) {
            String userEmail = authentication.getName(); // Email do usuário logado
            
            Optional<Aluno> alunoOpt = alunoRepository.findById(studentId);
            if (alunoOpt.isEmpty()) {
                return false;
            }
            
            Aluno aluno = alunoOpt.get();
            String alunoEmail = gerarEmailInstitucional(aluno.getNome(), aluno.getMatricula());
            
            return userEmail.equalsIgnoreCase(alunoEmail);
        }

        return false;
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
        
        if (!ultimoSobrenome.isEmpty()) {
            return String.format("%s.%s.%s@unifor.br", primeiroNome, ultimoSobrenome, matricula);
        } else {
            return String.format("%s.%s@unifor.br", primeiroNome, matricula);
        }
    }
}
