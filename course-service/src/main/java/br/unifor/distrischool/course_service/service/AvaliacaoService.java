package br.unifor.distrischool.course_service.service;

import br.unifor.distrischool.course_service.dto.AvaliacaoDTO;
import br.unifor.distrischool.course_service.model.Avaliacao;
import br.unifor.distrischool.course_service.model.Matricula;
import br.unifor.distrischool.course_service.repository.AvaliacaoRepository;
import br.unifor.distrischool.course_service.repository.MatriculaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AvaliacaoService {

    @Autowired
    private AvaliacaoRepository avaliacaoRepository;

    @Autowired
    private MatriculaRepository matriculaRepository;

    @Transactional
    public AvaliacaoDTO createAvaliacao(AvaliacaoDTO avaliacaoDTO) {
        Matricula matricula = matriculaRepository.findById(avaliacaoDTO.getMatriculaId())
                .orElseThrow(() -> new RuntimeException("Matrícula não encontrada"));

        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setMatricula(matricula);
        avaliacao.setTipoAvaliacao(avaliacaoDTO.getTipoAvaliacao());
        avaliacao.setNota(avaliacaoDTO.getNota());
        avaliacao.setPeso(avaliacaoDTO.getPeso());
        avaliacao.setObservacoes(avaliacaoDTO.getObservacoes());
        avaliacao.setDataAvaliacao(avaliacaoDTO.getDataAvaliacao());

        Avaliacao savedAvaliacao = avaliacaoRepository.save(avaliacao);
        return convertToDTO(savedAvaliacao);
    }

    public AvaliacaoDTO getAvaliacaoById(Long id) {
        Avaliacao avaliacao = avaliacaoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Avaliação não encontrada"));
        return convertToDTO(avaliacao);
    }

    public List<AvaliacaoDTO> getAvaliacoesByMatricula(Long matriculaId) {
        return avaliacaoRepository.findByMatriculaId(matriculaId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AvaliacaoDTO> getAvaliacoesByAluno(Long alunoId) {
        return avaliacaoRepository.findByAlunoId(alunoId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AvaliacaoDTO> getAvaliacoesByDisciplina(Long disciplinaId) {
        return avaliacaoRepository.findByDisciplinaId(disciplinaId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AvaliacaoDTO> getAvaliacoesByAlunoAndDisciplina(Long alunoId, Long disciplinaId) {
        return avaliacaoRepository.findByAlunoIdAndDisciplinaId(alunoId, disciplinaId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public AvaliacaoDTO updateAvaliacao(Long id, AvaliacaoDTO avaliacaoDTO) {
        Avaliacao avaliacao = avaliacaoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Avaliação não encontrada"));

        avaliacao.setTipoAvaliacao(avaliacaoDTO.getTipoAvaliacao());
        avaliacao.setNota(avaliacaoDTO.getNota());
        avaliacao.setPeso(avaliacaoDTO.getPeso());
        avaliacao.setObservacoes(avaliacaoDTO.getObservacoes());
        avaliacao.setDataAvaliacao(avaliacaoDTO.getDataAvaliacao());

        Avaliacao updatedAvaliacao = avaliacaoRepository.save(avaliacao);
        return convertToDTO(updatedAvaliacao);
    }

    @Transactional
    public void deleteAvaliacao(Long id) {
        if (!avaliacaoRepository.existsById(id)) {
            throw new RuntimeException("Avaliação não encontrada");
        }
        avaliacaoRepository.deleteById(id);
    }

    private AvaliacaoDTO convertToDTO(Avaliacao avaliacao) {
        AvaliacaoDTO dto = new AvaliacaoDTO();
        dto.setId(avaliacao.getId());
        dto.setMatriculaId(avaliacao.getMatricula().getId());
        dto.setAlunoId(avaliacao.getMatricula().getAlunoId());
        dto.setDisciplinaId(avaliacao.getMatricula().getDisciplina().getId());
        dto.setDisciplinaNome(avaliacao.getMatricula().getDisciplina().getNome());
        dto.setTipoAvaliacao(avaliacao.getTipoAvaliacao());
        dto.setNota(avaliacao.getNota());
        dto.setPeso(avaliacao.getPeso());
        dto.setObservacoes(avaliacao.getObservacoes());
        dto.setDataAvaliacao(avaliacao.getDataAvaliacao());
        return dto;
    }
}
