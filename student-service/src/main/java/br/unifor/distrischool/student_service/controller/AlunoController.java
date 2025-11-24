package br.unifor.distrischool.student_service.controller;

import br.unifor.distrischool.student_service.dto.AlunoComCursoDTO;
import br.unifor.distrischool.student_service.dto.AlunoDTO;
import br.unifor.distrischool.student_service.model.Aluno;
import br.unifor.distrischool.student_service.service.AlunoService;
import br.unifor.distrischool.student_service.service.CourseValidationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/alunos")
public class AlunoController {
    @Autowired
    private AlunoService alunoService;
    
    @Autowired
    private CourseValidationService courseValidationService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'STUDENT', 'TEACHER')")
    public ResponseEntity<List<Aluno>> listarTodos() {
        return ResponseEntity.ok(alunoService.listarTodos());
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<Aluno> getMeuPerfil() {
        // Retorna o perfil do aluno logado baseado no email do SecurityContext
        Optional<Aluno> aluno = alunoService.buscarPorEmail();
        return aluno.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Aluno> cadastrar(@RequestBody AlunoDTO alunoDTO) {
        // Converter DTO para entidade
        Aluno aluno = new Aluno();
        aluno.setNome(alunoDTO.getNome());
        aluno.setDataNascimento(alunoDTO.getDataNascimento());
        aluno.setEndereco(alunoDTO.getEndereco());
        aluno.setContato(alunoDTO.getContato());
        aluno.setMatricula(alunoDTO.getMatricula());
        aluno.setTurma(alunoDTO.getTurma());
        aluno.setCursoId(alunoDTO.getCursoId());
        aluno.setHistoricoAcademicoCriptografado(alunoDTO.getHistoricoAcademico());
        
        return ResponseEntity.ok(alunoService.salvar(aluno));
    }

    @PutMapping("/{id}")
    @PreAuthorize("@studentPermission.canAccessStudent(#id)")
    public ResponseEntity<Aluno> editar(@PathVariable Long id, @RequestBody AlunoDTO alunoDTO) {
        // Converter DTO para entidade
        Aluno aluno = new Aluno();
        aluno.setNome(alunoDTO.getNome());
        aluno.setDataNascimento(alunoDTO.getDataNascimento());
        aluno.setEndereco(alunoDTO.getEndereco());
        aluno.setContato(alunoDTO.getContato());
        aluno.setMatricula(alunoDTO.getMatricula());
        aluno.setTurma(alunoDTO.getTurma());
        aluno.setCursoId(alunoDTO.getCursoId());
        aluno.setHistoricoAcademicoCriptografado(alunoDTO.getHistoricoAcademico());
        
        return ResponseEntity.ok(alunoService.editar(id, aluno));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        alunoService.excluir(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'STUDENT', 'TEACHER')")
    public ResponseEntity<AlunoComCursoDTO> buscarPorId(@PathVariable Long id) {
        Optional<Aluno> alunoOpt = alunoService.buscarPorId(id);
        
        if (alunoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        Aluno aluno = alunoOpt.get();
        AlunoComCursoDTO dto = convertToAlunoComCursoDTO(aluno);
        
        return ResponseEntity.ok(dto);
    }
    
    /**
     * Converte Aluno para AlunoComCursoDTO, buscando informações do curso via Kafka
     */
    private AlunoComCursoDTO convertToAlunoComCursoDTO(Aluno aluno) {
        AlunoComCursoDTO dto = new AlunoComCursoDTO();
        dto.setId(aluno.getId());
        dto.setNome(aluno.getNome());
        dto.setDataNascimento(aluno.getDataNascimento());
        dto.setEndereco(aluno.getEndereco());
        dto.setContato(aluno.getContato());
        dto.setMatricula(aluno.getMatricula());
        dto.setTurma(aluno.getTurma());
        dto.setHistoricoAcademico(aluno.getHistoricoAcademicoCriptografado());
        dto.setCursoId(aluno.getCursoId());
        
        // Busca informações do curso via Kafka se cursoId estiver presente
        if (aluno.getCursoId() != null) {
            Map<String, Object> cursoInfo = courseValidationService.getCursoInfo(aluno.getCursoId());
            
            if (cursoInfo != null) {
                dto.setCursoNome((String) cursoInfo.get("nome"));
                dto.setCursoCodigo((String) cursoInfo.get("codigo"));
                dto.setCursoModalidade((String) cursoInfo.get("modalidade"));
                dto.setCursoTurno((String) cursoInfo.get("turno"));
            }
        }
        
        return dto;
    }

    @GetMapping("/matricula/{matricula}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Aluno> buscarPorMatricula(@PathVariable String matricula) {
        Optional<Aluno> aluno = alunoService.buscarPorMatricula(matricula);
        return aluno.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/nome/{nome}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Aluno>> buscarPorNome(@PathVariable String nome) {
        return ResponseEntity.ok(alunoService.buscarPorNome(nome));
    }

    @GetMapping("/turma/{turma}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Aluno>> buscarPorTurma(@PathVariable String turma) {
        return ResponseEntity.ok(alunoService.buscarPorTurma(turma));
    }
}
