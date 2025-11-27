package br.unifor.distrischool.course_service.controller;

import br.unifor.distrischool.course_service.dto.MatriculaDTO;
import br.unifor.distrischool.course_service.service.MatriculaService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/matriculas")
public class MatriculaController {

    @Autowired
    private MatriculaService matriculaService;

    @PostMapping
    public ResponseEntity<MatriculaDTO> createMatricula(@Valid @RequestBody MatriculaDTO matriculaDTO) {
        try {
            MatriculaDTO createdMatricula = matriculaService.createMatricula(matriculaDTO);
            return new ResponseEntity<>(createdMatricula, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/aluno/{alunoId}")
    public ResponseEntity<List<MatriculaDTO>> getMatriculasByAluno(@PathVariable Long alunoId) {
        List<MatriculaDTO> matriculas = matriculaService.getMatriculasByAluno(alunoId);
        return new ResponseEntity<>(matriculas, HttpStatus.OK);
    }

    @GetMapping("/aluno/{alunoId}/ativas")
    public ResponseEntity<List<MatriculaDTO>> getMatriculasAtivasByAluno(@PathVariable Long alunoId) {
        List<MatriculaDTO> matriculas = matriculaService.getMatriculasAtivasByAluno(alunoId);
        return new ResponseEntity<>(matriculas, HttpStatus.OK);
    }

    @GetMapping("/disciplina/{disciplinaId}")
    public ResponseEntity<List<MatriculaDTO>> getMatriculasByDisciplina(@PathVariable Long disciplinaId) {
        List<MatriculaDTO> matriculas = matriculaService.getMatriculasByDisciplina(disciplinaId);
        return new ResponseEntity<>(matriculas, HttpStatus.OK);
    }

    @GetMapping("/disciplina/{disciplinaId}/ativas")
    public ResponseEntity<List<MatriculaDTO>> getMatriculasAtivasByDisciplina(@PathVariable Long disciplinaId) {
        List<MatriculaDTO> matriculas = matriculaService.getMatriculasAtivasByDisciplina(disciplinaId);
        return new ResponseEntity<>(matriculas, HttpStatus.OK);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<MatriculaDTO> updateStatusMatricula(
            @PathVariable Long id, 
            @RequestParam String status) {
        try {
            MatriculaDTO updatedMatricula = matriculaService.updateStatusMatricula(id, status);
            return new ResponseEntity<>(updatedMatricula, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMatricula(@PathVariable Long id) {
        try {
            matriculaService.deleteMatricula(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
