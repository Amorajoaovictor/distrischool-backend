package br.unifor.distrischool.course_service.kafka;

import br.unifor.distrischool.course_service.dto.AvaliacaoDTO;
import br.unifor.distrischool.course_service.dto.DisciplinaDTO;
import br.unifor.distrischool.course_service.dto.MatriculaDTO;
import br.unifor.distrischool.course_service.service.AvaliacaoService;
import br.unifor.distrischool.course_service.service.DisciplinaService;
import br.unifor.distrischool.course_service.service.MatriculaService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CourseDataRequestConsumer {

    private static final Logger logger = LoggerFactory.getLogger(CourseDataRequestConsumer.class);

    @Autowired
    private MatriculaService matriculaService;

    @Autowired
    private AvaliacaoService avaliacaoService;

    @Autowired
    private DisciplinaService disciplinaService;

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    /**
     * Processa requisições de dados de outros serviços
     */
    @KafkaListener(topics = "course-data-requests", groupId = "course-service")
    public void processDataRequest(Map<String, Object> request) {
        logger.info("Received data request: {}", request);

        String requestType = (String) request.get("requestType");
        String requestedBy = (String) request.get("requestedBy");

        try {
            switch (requestType) {
                case "GET_MATRICULAS":
                    handleGetMatriculas(request, requestedBy);
                    break;
                case "GET_AVALIACOES":
                    handleGetAvaliacoes(request, requestedBy);
                    break;
                case "GET_BOLETIM":
                    handleGetBoletim(request, requestedBy);
                    break;
                case "GET_DISCIPLINAS":
                    handleGetDisciplinas(request, requestedBy);
                    break;
                case "GET_ALUNOS_BY_PROFESSOR":
                    handleGetAlunosByProfessor(request, requestedBy);
                    break;
                case "GET_TURMAS":
                    handleGetTurmas(request, requestedBy);
                    break;
                default:
                    logger.warn("Unknown request type: {}", requestType);
            }
        } catch (Exception e) {
            logger.error("Error processing data request: {}", request, e);
            sendErrorResponse(request, requestedBy, e.getMessage());
        }
    }

    private void handleGetMatriculas(Map<String, Object> request, String requestedBy) {
        Long alunoId = ((Number) request.get("alunoId")).longValue();
        List<MatriculaDTO> matriculas = matriculaService.getMatriculasByAluno(alunoId);

        Map<String, Object> response = new HashMap<>();
        response.put("requestType", "GET_MATRICULAS");
        response.put("alunoId", alunoId);
        response.put("matriculas", matriculas);
        response.put("count", matriculas.size());
        response.put("timestamp", System.currentTimeMillis());

        kafkaTemplate.send("student-boletim-responses", alunoId.toString(), response);
        logger.info("Sent matriculas response for student {}: {} matriculas", alunoId, matriculas.size());
    }

    private void handleGetAvaliacoes(Map<String, Object> request, String requestedBy) {
        Long alunoId = ((Number) request.get("alunoId")).longValue();
        List<AvaliacaoDTO> avaliacoes = avaliacaoService.getAvaliacoesByAluno(alunoId);

        Map<String, Object> response = new HashMap<>();
        response.put("requestType", "GET_AVALIACOES");
        response.put("alunoId", alunoId);
        response.put("avaliacoes", avaliacoes);
        response.put("count", avaliacoes.size());
        response.put("timestamp", System.currentTimeMillis());

        kafkaTemplate.send("student-boletim-responses", alunoId.toString(), response);
        logger.info("Sent avaliacoes response for student {}: {} avaliacoes", alunoId, avaliacoes.size());
    }

    private void handleGetBoletim(Map<String, Object> request, String requestedBy) {
        Long alunoId = ((Number) request.get("alunoId")).longValue();
        List<MatriculaDTO> matriculas = matriculaService.getMatriculasAtivasByAluno(alunoId);
        List<AvaliacaoDTO> avaliacoes = avaliacaoService.getAvaliacoesByAluno(alunoId);

        Map<String, Object> response = new HashMap<>();
        response.put("requestType", "GET_BOLETIM");
        response.put("alunoId", alunoId);
        response.put("matriculas", matriculas);
        response.put("avaliacoes", avaliacoes);
        response.put("timestamp", System.currentTimeMillis());

        kafkaTemplate.send("student-boletim-responses", alunoId.toString(), response);
        logger.info("Sent complete boletim for student {}: {} matriculas, {} avaliacoes", 
            alunoId, matriculas.size(), avaliacoes.size());
    }

    private void handleGetDisciplinas(Map<String, Object> request, String requestedBy) {
        Long professorId = ((Number) request.get("professorId")).longValue();
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByProfessor(professorId);

        Map<String, Object> response = new HashMap<>();
        response.put("requestType", "GET_DISCIPLINAS");
        response.put("professorId", professorId);
        response.put("disciplinas", disciplinas);
        response.put("count", disciplinas.size());
        response.put("timestamp", System.currentTimeMillis());

        kafkaTemplate.send("teacher-disciplinas-responses", professorId.toString(), response);
        logger.info("Sent disciplinas response for teacher {}: {} disciplinas", professorId, disciplinas.size());
    }

    private void handleGetAlunosByProfessor(Map<String, Object> request, String requestedBy) {
        Long professorId = ((Number) request.get("professorId")).longValue();
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByProfessor(professorId);

        // Para cada disciplina, buscar matrículas ativas
        Map<Long, List<MatriculaDTO>> alunosPorDisciplina = new HashMap<>();
        for (DisciplinaDTO disciplina : disciplinas) {
            List<MatriculaDTO> matriculas = matriculaService.getMatriculasAtivasByDisciplina(disciplina.getId());
            alunosPorDisciplina.put(disciplina.getId(), matriculas);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("requestType", "GET_ALUNOS_BY_PROFESSOR");
        response.put("professorId", professorId);
        response.put("disciplinas", disciplinas);
        response.put("alunosPorDisciplina", alunosPorDisciplina);
        response.put("timestamp", System.currentTimeMillis());

        kafkaTemplate.send("teacher-turmas-responses", professorId.toString(), response);
        logger.info("Sent students response for teacher {}: {} disciplinas", professorId, disciplinas.size());
    }

    private void handleGetTurmas(Map<String, Object> request, String requestedBy) {
        Long professorId = ((Number) request.get("professorId")).longValue();
        List<DisciplinaDTO> disciplinas = disciplinaService.getDisciplinasByProfessor(professorId);

        // Para cada disciplina, contar alunos ativos
        Map<Long, Integer> countPorDisciplina = new HashMap<>();
        for (DisciplinaDTO disciplina : disciplinas) {
            List<MatriculaDTO> matriculas = matriculaService.getMatriculasAtivasByDisciplina(disciplina.getId());
            countPorDisciplina.put(disciplina.getId(), matriculas.size());
        }

        Map<String, Object> response = new HashMap<>();
        response.put("requestType", "GET_TURMAS");
        response.put("professorId", professorId);
        response.put("disciplinas", disciplinas);
        response.put("countPorDisciplina", countPorDisciplina);
        response.put("timestamp", System.currentTimeMillis());

        kafkaTemplate.send("teacher-turmas-responses", professorId.toString(), response);
        logger.info("Sent turmas response for teacher {}: {} disciplinas", professorId, disciplinas.size());
    }

    private void sendErrorResponse(Map<String, Object> request, String requestedBy, String errorMessage) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("error", true);
        errorResponse.put("message", errorMessage);
        errorResponse.put("originalRequest", request);
        errorResponse.put("timestamp", System.currentTimeMillis());

        String topic = requestedBy.equals("student-service") ? 
            "student-boletim-responses" : "teacher-disciplinas-responses";
        
        kafkaTemplate.send(topic, "error", errorResponse);
        logger.error("Sent error response to {}: {}", requestedBy, errorMessage);
    }
}
