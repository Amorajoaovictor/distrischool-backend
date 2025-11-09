package br.unifor.distrischool.teacher_service.security;

import br.unifor.distrischool.teacher_service.model.Teacher;
import br.unifor.distrischool.teacher_service.repository.TeacherRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.Optional;

@Service("teacherPermission")
public class TeacherPermissionService {

    @Autowired
    private TeacherRepository teacherRepository;

    /**
     * Verifica se o usuário autenticado pode acessar/modificar o professor com o ID fornecido.
     * Regras:
     * - ADMIN: pode acessar qualquer professor
     * - TEACHER: pode acessar apenas seu próprio perfil (email deve corresponder ao email gerado do professor)
     */
    public boolean canAccessTeacher(Long teacherId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            return false;
        }

        // Se é ADMIN, pode acessar qualquer professor
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_ADMIN"))) {
            return true;
        }

        // Se é TEACHER, verifica se o email corresponde ao professor
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_TEACHER"))) {
            String userEmail = authentication.getName(); // Email do usuário logado
            
            Optional<Teacher> teacherOpt = teacherRepository.findById(teacherId);
            if (teacherOpt.isEmpty()) {
                return false;
            }
            
            Teacher teacher = teacherOpt.get();
            String teacherEmail = gerarEmailInstitucional(teacher.getNome(), teacher.getId());
            
            return userEmail.equalsIgnoreCase(teacherEmail);
        }

        return false;
    }

    private String gerarEmailInstitucional(String nomeCompleto, Long id) {
        // Remove acentos e caracteres especiais
        String nome = Normalizer.normalize(nomeCompleto, Normalizer.Form.NFD)
                .replaceAll("[^\\p{ASCII}]", "")
                .toLowerCase()
                .trim();
        
        // Pega primeiro nome e último sobrenome
        String[] partes = nome.split("\\s+");
        String primeiroNome = partes[0];
        String ultimoSobrenome = partes.length > 1 ? partes[partes.length - 1] : "";
        
        // Formato: primeiro.ultimo.prof.id@unifor.br
        if (!ultimoSobrenome.isEmpty()) {
            return String.format("%s.%s.prof.%d@unifor.br", primeiroNome, ultimoSobrenome, id);
        } else {
            return String.format("%s.prof.%d@unifor.br", primeiroNome, id);
        }
    }
}
