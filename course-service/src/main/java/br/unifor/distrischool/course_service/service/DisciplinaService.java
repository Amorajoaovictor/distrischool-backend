package br.unifor.distrischool.course_service.service;

import br.unifor.distrischool.course_service.dto.DisciplinaDTO;
import br.unifor.distrischool.course_service.model.Curso;
import br.unifor.distrischool.course_service.model.Disciplina;
import br.unifor.distrischool.course_service.repository.CursoRepository;
import br.unifor.distrischool.course_service.repository.DisciplinaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DisciplinaService {

    @Autowired
    private DisciplinaRepository disciplinaRepository;

    @Autowired
    private CursoRepository cursoRepository;

    @Transactional
    public DisciplinaDTO createDisciplina(DisciplinaDTO disciplinaDTO) {
        if (disciplinaRepository.existsByCodigo(disciplinaDTO.getCodigo())) {
            throw new RuntimeException("Já existe uma disciplina com este código");
        }

        Curso curso = cursoRepository.findById(disciplinaDTO.getCursoId())
                .orElseThrow(() -> new RuntimeException("Curso não encontrado com ID: " + disciplinaDTO.getCursoId()));

        Disciplina disciplina = convertToEntity(disciplinaDTO);
        disciplina.setCurso(curso);
        
        Disciplina savedDisciplina = disciplinaRepository.save(disciplina);
        return convertToDTO(savedDisciplina);
    }

    public DisciplinaDTO getDisciplinaById(Long id) {
        Disciplina disciplina = disciplinaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Disciplina não encontrada com ID: " + id));
        return convertToDTO(disciplina);
    }

    public DisciplinaDTO getDisciplinaByCodigo(String codigo) {
        Disciplina disciplina = disciplinaRepository.findByCodigo(codigo)
                .orElseThrow(() -> new RuntimeException("Disciplina não encontrada com código: " + codigo));
        return convertToDTO(disciplina);
    }

    public List<DisciplinaDTO> getAllDisciplinas() {
        return disciplinaRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<DisciplinaDTO> getDisciplinasByCurso(Long cursoId) {
        return disciplinaRepository.findByCursoId(cursoId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<DisciplinaDTO> getDisciplinasByStatus(String status) {
        return disciplinaRepository.findByStatus(status).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<DisciplinaDTO> getDisciplinasByCursoAndPeriodo(Long cursoId, Integer periodo) {
        return disciplinaRepository.findByCursoIdAndPeriodo(cursoId, periodo).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<DisciplinaDTO> getDisciplinasByProfessor(Long professorId) {
        return disciplinaRepository.findByProfessorId(professorId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public DisciplinaDTO updateDisciplina(Long id, DisciplinaDTO disciplinaDTO) {
        Disciplina disciplina = disciplinaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Disciplina não encontrada com ID: " + id));

        if (!disciplina.getCodigo().equals(disciplinaDTO.getCodigo()) && 
            disciplinaRepository.existsByCodigo(disciplinaDTO.getCodigo())) {
            throw new RuntimeException("Já existe uma disciplina com este código");
        }

        Curso curso = cursoRepository.findById(disciplinaDTO.getCursoId())
                .orElseThrow(() -> new RuntimeException("Curso não encontrado com ID: " + disciplinaDTO.getCursoId()));

        disciplina.setNome(disciplinaDTO.getNome());
        disciplina.setCodigo(disciplinaDTO.getCodigo());
        disciplina.setDescricao(disciplinaDTO.getDescricao());
        disciplina.setCargaHoraria(disciplinaDTO.getCargaHoraria());
        disciplina.setCreditos(disciplinaDTO.getCreditos());
        disciplina.setCurso(curso);
        disciplina.setProfessorId(disciplinaDTO.getProfessorId());
        disciplina.setPeriodo(disciplinaDTO.getPeriodo());
        disciplina.setTipo(disciplinaDTO.getTipo());
        disciplina.setStatus(disciplinaDTO.getStatus());

        Disciplina updatedDisciplina = disciplinaRepository.save(disciplina);
        return convertToDTO(updatedDisciplina);
    }

    @Transactional
    public void deleteDisciplina(Long id) {
        if (!disciplinaRepository.existsById(id)) {
            throw new RuntimeException("Disciplina não encontrada com ID: " + id);
        }
        disciplinaRepository.deleteById(id);
    }

    private DisciplinaDTO convertToDTO(Disciplina disciplina) {
        DisciplinaDTO dto = new DisciplinaDTO();
        dto.setId(disciplina.getId());
        dto.setNome(disciplina.getNome());
        dto.setCodigo(disciplina.getCodigo());
        dto.setDescricao(disciplina.getDescricao());
        dto.setCargaHoraria(disciplina.getCargaHoraria());
        dto.setCreditos(disciplina.getCreditos());
        dto.setCursoId(disciplina.getCurso().getId());
        dto.setProfessorId(disciplina.getProfessorId());
        dto.setPeriodo(disciplina.getPeriodo());
        dto.setTipo(disciplina.getTipo());
        dto.setStatus(disciplina.getStatus());
        return dto;
    }

    private Disciplina convertToEntity(DisciplinaDTO dto) {
        Disciplina disciplina = new Disciplina();
        disciplina.setNome(dto.getNome());
        disciplina.setCodigo(dto.getCodigo());
        disciplina.setDescricao(dto.getDescricao());
        disciplina.setCargaHoraria(dto.getCargaHoraria());
        disciplina.setCreditos(dto.getCreditos());
        disciplina.setProfessorId(dto.getProfessorId());
        disciplina.setPeriodo(dto.getPeriodo());
        disciplina.setTipo(dto.getTipo());
        disciplina.setStatus(dto.getStatus());
        return disciplina;
    }
}
