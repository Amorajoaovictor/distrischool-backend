package br.unifor.distrischool.course_service.service;

import br.unifor.distrischool.course_service.dto.CursoDTO;
import br.unifor.distrischool.course_service.model.Curso;
import br.unifor.distrischool.course_service.repository.CursoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CursoService {

    @Autowired
    private CursoRepository cursoRepository;

    @Transactional
    public CursoDTO createCurso(CursoDTO cursoDTO) {
        if (cursoRepository.existsByCodigo(cursoDTO.getCodigo())) {
            throw new RuntimeException("Já existe um curso com este código");
        }
        
        Curso curso = convertToEntity(cursoDTO);
        Curso savedCurso = cursoRepository.save(curso);
        return convertToDTO(savedCurso);
    }

    public CursoDTO getCursoById(Long id) {
        Curso curso = cursoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Curso não encontrado com ID: " + id));
        return convertToDTO(curso);
    }

    public CursoDTO getCursoByCodigo(String codigo) {
        Curso curso = cursoRepository.findByCodigo(codigo)
                .orElseThrow(() -> new RuntimeException("Curso não encontrado com código: " + codigo));
        return convertToDTO(curso);
    }

    public List<CursoDTO> getAllCursos() {
        return cursoRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<CursoDTO> getCursosByStatus(String status) {
        return cursoRepository.findByStatus(status).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<CursoDTO> getCursosByModalidade(String modalidade) {
        return cursoRepository.findByModalidade(modalidade).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public CursoDTO updateCurso(Long id, CursoDTO cursoDTO) {
        Curso curso = cursoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Curso não encontrado com ID: " + id));

        if (!curso.getCodigo().equals(cursoDTO.getCodigo()) && 
            cursoRepository.existsByCodigo(cursoDTO.getCodigo())) {
            throw new RuntimeException("Já existe um curso com este código");
        }

        curso.setNome(cursoDTO.getNome());
        curso.setCodigo(cursoDTO.getCodigo());
        curso.setDescricao(cursoDTO.getDescricao());
        curso.setDuracaoSemestres(cursoDTO.getDuracaoSemestres());
        curso.setModalidade(cursoDTO.getModalidade());
        curso.setTurno(cursoDTO.getTurno());
        curso.setStatus(cursoDTO.getStatus());

        Curso updatedCurso = cursoRepository.save(curso);
        return convertToDTO(updatedCurso);
    }

    @Transactional
    public void deleteCurso(Long id) {
        if (!cursoRepository.existsById(id)) {
            throw new RuntimeException("Curso não encontrado com ID: " + id);
        }
        cursoRepository.deleteById(id);
    }

    private CursoDTO convertToDTO(Curso curso) {
        CursoDTO dto = new CursoDTO();
        dto.setId(curso.getId());
        dto.setNome(curso.getNome());
        dto.setCodigo(curso.getCodigo());
        dto.setDescricao(curso.getDescricao());
        dto.setDuracaoSemestres(curso.getDuracaoSemestres());
        dto.setModalidade(curso.getModalidade());
        dto.setTurno(curso.getTurno());
        dto.setStatus(curso.getStatus());
        return dto;
    }

    private Curso convertToEntity(CursoDTO dto) {
        Curso curso = new Curso();
        curso.setNome(dto.getNome());
        curso.setCodigo(dto.getCodigo());
        curso.setDescricao(dto.getDescricao());
        curso.setDuracaoSemestres(dto.getDuracaoSemestres());
        curso.setModalidade(dto.getModalidade());
        curso.setTurno(dto.getTurno());
        curso.setStatus(dto.getStatus());
        return curso;
    }
}
