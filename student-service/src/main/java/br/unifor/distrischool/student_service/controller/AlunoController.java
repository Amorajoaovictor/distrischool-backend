package br.unifor.distrischool.student_service.controller;

import br.unifor.distrischool.student_service.dto.AlunoDTO;
import br.unifor.distrischool.student_service.model.Aluno;
import br.unifor.distrischool.student_service.service.AlunoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/alunos")
public class AlunoController {
    @Autowired
    private AlunoService alunoService;

    @PostMapping
    public ResponseEntity<Aluno> cadastrar(@RequestBody AlunoDTO alunoDTO) {
        // Converter DTO para entidade
        Aluno aluno = new Aluno();
        aluno.setNome(alunoDTO.getNome());
        aluno.setDataNascimento(alunoDTO.getDataNascimento());
        aluno.setEndereco(alunoDTO.getEndereco());
        aluno.setContato(alunoDTO.getContato());
        aluno.setMatricula(alunoDTO.getMatricula());
        aluno.setTurma(alunoDTO.getTurma());
        aluno.setHistoricoAcademicoCriptografado(alunoDTO.getHistoricoAcademico());
        
        return ResponseEntity.ok(alunoService.salvar(aluno));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Aluno> editar(@PathVariable Long id, @RequestBody AlunoDTO alunoDTO) {
        // Converter DTO para entidade
        Aluno aluno = new Aluno();
        aluno.setNome(alunoDTO.getNome());
        aluno.setDataNascimento(alunoDTO.getDataNascimento());
        aluno.setEndereco(alunoDTO.getEndereco());
        aluno.setContato(alunoDTO.getContato());
        aluno.setMatricula(alunoDTO.getMatricula());
        aluno.setTurma(alunoDTO.getTurma());
        aluno.setHistoricoAcademicoCriptografado(alunoDTO.getHistoricoAcademico());
        
        return ResponseEntity.ok(alunoService.editar(id, aluno));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        alunoService.excluir(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Aluno> buscarPorId(@PathVariable Long id) {
        Optional<Aluno> aluno = alunoService.buscarPorId(id);
        return aluno.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/matricula/{matricula}")
    public ResponseEntity<Aluno> buscarPorMatricula(@PathVariable String matricula) {
        Optional<Aluno> aluno = alunoService.buscarPorMatricula(matricula);
        return aluno.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/nome/{nome}")
    public ResponseEntity<List<Aluno>> buscarPorNome(@PathVariable String nome) {
        return ResponseEntity.ok(alunoService.buscarPorNome(nome));
    }

    @GetMapping("/turma/{turma}")
    public ResponseEntity<List<Aluno>> buscarPorTurma(@PathVariable String turma) {
        return ResponseEntity.ok(alunoService.buscarPorTurma(turma));
    }
}
