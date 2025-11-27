package br.unifor.distrischool.student_service.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/alunos/{alunoId}")
public class StudentCourseController {

    private static final Logger logger = LoggerFactory.getLogger(StudentCourseController.class);
    
    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    /**
     * Solicita matrículas do aluno ao course-service via Kafka
     * O resultado será publicado em outro tópico e pode ser consumido
     */
    @GetMapping("/matriculas/request")
    public Map<String, Object> requestMatriculas(@PathVariable Long alunoId) {
        logger.info("Requesting matriculas for student: {}", alunoId);
        
        Map<String, Object> request = Map.of(
            "alunoId", alunoId,
            "requestType", "GET_MATRICULAS",
            "requestedBy", "student-service",
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send("course-data-requests", alunoId.toString(), request);
        
        return Map.of(
            "message", "Matriculas request sent",
            "alunoId", alunoId,
            "status", "PROCESSING"
        );
    }

    /**
     * Solicita avaliações do aluno ao course-service via Kafka
     */
    @GetMapping("/avaliacoes/request")
    public Map<String, Object> requestAvaliacoes(@PathVariable Long alunoId) {
        logger.info("Requesting avaliacoes for student: {}", alunoId);
        
        Map<String, Object> request = Map.of(
            "alunoId", alunoId,
            "requestType", "GET_AVALIACOES",
            "requestedBy", "student-service",
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send("course-data-requests", alunoId.toString(), request);
        
        return Map.of(
            "message", "Avaliacoes request sent",
            "alunoId", alunoId,
            "status", "PROCESSING"
        );
    }

    /**
     * Solicita boletim completo do aluno (matrículas + avaliações)
     */
    @GetMapping("/boletim/request")
    public Map<String, Object> requestBoletim(@PathVariable Long alunoId) {
        logger.info("Requesting complete boletim for student: {}", alunoId);
        
        Map<String, Object> request = Map.of(
            "alunoId", alunoId,
            "requestType", "GET_BOLETIM",
            "requestedBy", "student-service",
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send("course-data-requests", alunoId.toString(), request);
        
        return Map.of(
            "message", "Boletim request sent. Listen to 'student-boletim-responses' topic for results",
            "alunoId", alunoId,
            "status", "PROCESSING",
            "note", "This is an async operation. Results will be published to Kafka topic"
        );
    }
}
