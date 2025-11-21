package br.unifor.distrischool.course_service.controller;

import br.unifor.distrischool.course_service.dto.CursoDTO;
import br.unifor.distrischool.course_service.service.CursoService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cursos")
public class CursoController {

    @Autowired
    private CursoService cursoService;

    @PostMapping
    public ResponseEntity<CursoDTO> createCurso(@Valid @RequestBody CursoDTO cursoDTO) {
        try {
            CursoDTO createdCurso = cursoService.createCurso(cursoDTO);
            return new ResponseEntity<>(createdCurso, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<CursoDTO> getCursoById(@PathVariable Long id) {
        try {
            CursoDTO curso = cursoService.getCursoById(id);
            return new ResponseEntity<>(curso, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<CursoDTO> getCursoByCodigo(@PathVariable String codigo) {
        try {
            CursoDTO curso = cursoService.getCursoByCodigo(codigo);
            return new ResponseEntity<>(curso, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping
    public ResponseEntity<List<CursoDTO>> getAllCursos() {
        List<CursoDTO> cursos = cursoService.getAllCursos();
        return new ResponseEntity<>(cursos, HttpStatus.OK);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<CursoDTO>> getCursosByStatus(@PathVariable String status) {
        List<CursoDTO> cursos = cursoService.getCursosByStatus(status);
        return new ResponseEntity<>(cursos, HttpStatus.OK);
    }

    @GetMapping("/modalidade/{modalidade}")
    public ResponseEntity<List<CursoDTO>> getCursosByModalidade(@PathVariable String modalidade) {
        List<CursoDTO> cursos = cursoService.getCursosByModalidade(modalidade);
        return new ResponseEntity<>(cursos, HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CursoDTO> updateCurso(@PathVariable Long id, @Valid @RequestBody CursoDTO cursoDTO) {
        try {
            CursoDTO updatedCurso = cursoService.updateCurso(id, cursoDTO);
            return new ResponseEntity<>(updatedCurso, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCurso(@PathVariable Long id) {
        try {
            cursoService.deleteCurso(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
