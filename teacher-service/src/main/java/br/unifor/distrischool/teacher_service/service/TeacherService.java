package br.unifor.distrischool.teacher_service.service;

import br.unifor.distrischool.teacher_service.exception.ResourceNotFoundException;
import br.unifor.distrischool.teacher_service.model.Teacher;
import br.unifor.distrischool.teacher_service.repository.TeacherRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TeacherService {

    private final TeacherRepository repository;

    public TeacherService(TeacherRepository repository) {
        this.repository = repository;
    }

    public Teacher create(Teacher t) {
        return repository.save(t);
    }

    public Teacher update(Long id, Teacher t) {
        Teacher exist = repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Teacher not found"));
        exist.setNome(t.getNome());
        exist.setQualificacao(t.getQualificacao());
        exist.setContato(t.getContato());
        return repository.save(exist);
    }

    public Teacher getById(Long id) {
        return repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Teacher not found"));
    }

    public List<Teacher> listAll() {
        return repository.findAll();
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
