package br.unifor.distrischool.course_service.controller;

import br.unifor.distrischool.course_service.dto.AvaliacaoDTO;
import br.unifor.distrischool.course_service.service.AvaliacaoService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/avaliacoes")
public class AvaliacaoController {

    @Autowired
    private AvaliacaoService avaliacaoService;

    @PostMapping
    public ResponseEntity<AvaliacaoDTO> createAvaliacao(@Valid @RequestBody AvaliacaoDTO avaliacaoDTO) {
        try {
            AvaliacaoDTO createdAvaliacao = avaliacaoService.createAvaliacao(avaliacaoDTO);
            return new ResponseEntity<>(createdAvaliacao, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<AvaliacaoDTO> getAvaliacaoById(@PathVariable Long id) {
        try {
            AvaliacaoDTO avaliacao = avaliacaoService.getAvaliacaoById(id);
            return new ResponseEntity<>(avaliacao, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/matricula/{matriculaId}")
    public ResponseEntity<List<AvaliacaoDTO>> getAvaliacoesByMatricula(@PathVariable Long matriculaId) {
        List<AvaliacaoDTO> avaliacoes = avaliacaoService.getAvaliacoesByMatricula(matriculaId);
        return new ResponseEntity<>(avaliacoes, HttpStatus.OK);
    }

    @GetMapping("/aluno/{alunoId}")
    public ResponseEntity<List<AvaliacaoDTO>> getAvaliacoesByAluno(@PathVariable Long alunoId) {
        List<AvaliacaoDTO> avaliacoes = avaliacaoService.getAvaliacoesByAluno(alunoId);
        return new ResponseEntity<>(avaliacoes, HttpStatus.OK);
    }

    @GetMapping("/disciplina/{disciplinaId}")
    public ResponseEntity<List<AvaliacaoDTO>> getAvaliacoesByDisciplina(@PathVariable Long disciplinaId) {
        List<AvaliacaoDTO> avaliacoes = avaliacaoService.getAvaliacoesByDisciplina(disciplinaId);
        return new ResponseEntity<>(avaliacoes, HttpStatus.OK);
    }

    @GetMapping("/aluno/{alunoId}/disciplina/{disciplinaId}")
    public ResponseEntity<List<AvaliacaoDTO>> getAvaliacoesByAlunoAndDisciplina(
            @PathVariable Long alunoId,
            @PathVariable Long disciplinaId) {
        List<AvaliacaoDTO> avaliacoes = avaliacaoService.getAvaliacoesByAlunoAndDisciplina(alunoId, disciplinaId);
        return new ResponseEntity<>(avaliacoes, HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AvaliacaoDTO> updateAvaliacao(
            @PathVariable Long id, 
            @Valid @RequestBody AvaliacaoDTO avaliacaoDTO) {
        try {
            AvaliacaoDTO updatedAvaliacao = avaliacaoService.updateAvaliacao(id, avaliacaoDTO);
            return new ResponseEntity<>(updatedAvaliacao, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAvaliacao(@PathVariable Long id) {
        try {
            avaliacaoService.deleteAvaliacao(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
