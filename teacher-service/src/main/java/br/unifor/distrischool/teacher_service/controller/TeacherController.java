package br.unifor.distrischool.teacher_service.controller;

import br.unifor.distrischool.teacher_service.exception.ResourceNotFoundException;
import br.unifor.distrischool.teacher_service.model.Teacher;
import br.unifor.distrischool.teacher_service.service.TeacherService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/teachers")
public class TeacherController {

    private final TeacherService service;

    public TeacherController(TeacherService service) {
        this.service = service;
    }

    @GetMapping
    public List<Teacher> list() {
        return service.listAll();
    }

    @GetMapping("/{id}")
    public Teacher get(@PathVariable Long id) {
        return service.getById(id);
    }

    @PostMapping
    public ResponseEntity<Teacher> create(@RequestBody Teacher t) {
        return ResponseEntity.ok(service.create(t));
    }

    @PutMapping("/{id}")
    public Teacher update(@PathVariable Long id, @RequestBody Teacher t) {
        return service.update(id, t);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        try {
            service.delete(id);
            return ResponseEntity.noContent().build();
        } catch (ResourceNotFoundException ex) {
            return ResponseEntity.notFound().build();
        }
    }
}
