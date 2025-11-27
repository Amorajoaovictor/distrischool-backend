package br.unifor.distrischool.course_service.service;

import br.unifor.distrischool.course_service.dto.MatriculaDTO;
import br.unifor.distrischool.course_service.model.Disciplina;
import br.unifor.distrischool.course_service.model.Matricula;
import br.unifor.distrischool.course_service.repository.DisciplinaRepository;
import br.unifor.distrischool.course_service.repository.MatriculaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MatriculaService {

    @Autowired
    private MatriculaRepository matriculaRepository;

    @Autowired
    private DisciplinaRepository disciplinaRepository;

    @Transactional
    public MatriculaDTO createMatricula(MatriculaDTO matriculaDTO) {
        // Verifica se o aluno já está matriculado na disciplina
        if (matriculaRepository.existsByAlunoIdAndDisciplinaId(
                matriculaDTO.getAlunoId(), matriculaDTO.getDisciplinaId())) {
            throw new RuntimeException("Aluno já matriculado nesta disciplina");
        }

        Disciplina disciplina = disciplinaRepository.findById(matriculaDTO.getDisciplinaId())
                .orElseThrow(() -> new RuntimeException("Disciplina não encontrada"));

        Matricula matricula = new Matricula();
        matricula.setAlunoId(matriculaDTO.getAlunoId());
        matricula.setDisciplina(disciplina);
        matricula.setStatus("ATIVA");

        Matricula savedMatricula = matriculaRepository.save(matricula);
        return convertToDTO(savedMatricula);
    }

    public List<MatriculaDTO> getMatriculasByAluno(Long alunoId) {
        return matriculaRepository.findByAlunoId(alunoId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<MatriculaDTO> getMatriculasByDisciplina(Long disciplinaId) {
        return matriculaRepository.findByDisciplinaId(disciplinaId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<MatriculaDTO> getMatriculasAtivasByAluno(Long alunoId) {
        return matriculaRepository.findByAlunoIdAndStatus(alunoId, "ATIVA").stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<MatriculaDTO> getMatriculasAtivasByDisciplina(Long disciplinaId) {
        return matriculaRepository.findByDisciplinaIdAndStatus(disciplinaId, "ATIVA").stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public MatriculaDTO updateStatusMatricula(Long id, String novoStatus) {
        Matricula matricula = matriculaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Matrícula não encontrada"));
        
        matricula.setStatus(novoStatus);
        Matricula updatedMatricula = matriculaRepository.save(matricula);
        return convertToDTO(updatedMatricula);
    }

    @Transactional
    public void deleteMatricula(Long id) {
        if (!matriculaRepository.existsById(id)) {
            throw new RuntimeException("Matrícula não encontrada");
        }
        matriculaRepository.deleteById(id);
    }

    private MatriculaDTO convertToDTO(Matricula matricula) {
        MatriculaDTO dto = new MatriculaDTO();
        dto.setId(matricula.getId());
        dto.setAlunoId(matricula.getAlunoId());
        dto.setDisciplinaId(matricula.getDisciplina().getId());
        dto.setDisciplinaNome(matricula.getDisciplina().getNome());
        dto.setDisciplinaCodigo(matricula.getDisciplina().getCodigo());
        dto.setStatus(matricula.getStatus());
        dto.setDataMatricula(matricula.getDataMatricula());
        return dto;
    }
}
