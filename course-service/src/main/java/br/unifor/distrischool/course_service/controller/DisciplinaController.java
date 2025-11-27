package br.unifor.distrischool.course_service.controller;

import br.unifor.distrischool.course_service.dto.DisciplinaDTO;
import br.unifor.distrischool.course_service.service.DisciplinaService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/disciplinas")
public class DisciplinaController {

    @Autowired
    private DisciplinaService disciplinaService;

    @PostMapping
    public ResponseEntity<DisciplinaDTO> createDisciplina(@Valid @RequestBody DisciplinaDTO disciplinaDTO) {
        try {
            DisciplinaDTO createdDisciplina = disciplinaService.createDisciplina(disciplinaDTO);
            return new ResponseEntity<>(createdDisciplina, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<DisciplinaDTO> getDisciplinaById(@PathVariable Long id) {
        try {
            DisciplinaDTO disciplina = disciplinaService.getDisciplinaById(id);
            return new ResponseEntity<>(disciplina, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<DisciplinaDTO> getDisciplinaByCodigo(@PathVariable String codigo) {
        try {
            DisciplinaDTO disciplina = disciplinaService.getDisciplinaByCodigo(codigo);
            return new ResponseEntity<>(disciplina, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping
    public ResponseEntity<List<DisciplinaDTO>> getAllDisciplinas() {
        List<DisciplinaDTO> disciplinas = disciplinaService.getAllDisciplinas();
        return new ResponseEntity<>(disciplinas, HttpStatus.OK);
    }

    @GetMapping("/curso/{cursoId}")
    public ResponseEntity<List<DisciplinaDTO>> getDisciplinasByCurso(@PathVariable Long cursoId) {
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByCurso(cursoId);
        return new ResponseEntity<>(disciplinas, HttpStatus.OK);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<DisciplinaDTO>> getDisciplinasByStatus(@PathVariable String status) {
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByStatus(status);
        return new ResponseEntity<>(disciplinas, HttpStatus.OK);
    }

    @GetMapping("/curso/{cursoId}/periodo/{periodo}")
    public ResponseEntity<List<DisciplinaDTO>> getDisciplinasByCursoAndPeriodo(
            @PathVariable Long cursoId, 
            @PathVariable Integer periodo) {
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByCursoAndPeriodo(cursoId, periodo);
        return new ResponseEntity<>(disciplinas, HttpStatus.OK);
    }

    @GetMapping("/professor/{professorId}")
    public ResponseEntity<List<DisciplinaDTO>> getDisciplinasByProfessor(@PathVariable Long professorId) {
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByProfessor(professorId);
        return new ResponseEntity<>(disciplinas, HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DisciplinaDTO> updateDisciplina(@PathVariable Long id, @Valid @RequestBody DisciplinaDTO disciplinaDTO) {
        try {
            DisciplinaDTO updatedDisciplina = disciplinaService.updateDisciplina(id, disciplinaDTO);
            return new ResponseEntity<>(updatedDisciplina, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDisciplina(@PathVariable Long id) {
        try {
            disciplinaService.deleteDisciplina(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
