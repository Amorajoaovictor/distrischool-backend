package br.unifor.distrischool.teacher_service.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/teachers/{teacherId}")
public class TeacherCourseController {

    private static final Logger logger = LoggerFactory.getLogger(TeacherCourseController.class);
    
    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    /**
     * Solicita disciplinas do professor ao course-service via Kafka
     */
    @GetMapping("/disciplinas/request")
    public Map<String, Object> requestDisciplinas(@PathVariable Long teacherId) {
        logger.info("Requesting disciplinas for teacher: {}", teacherId);
        
        Map<String, Object> request = Map.of(
            "professorId", teacherId,
            "requestType", "GET_DISCIPLINAS",
            "requestedBy", "teacher-service",
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send("course-data-requests", teacherId.toString(), request);
        
        return Map.of(
            "message", "Disciplinas request sent",
            "professorId", teacherId,
            "status", "PROCESSING",
            "note", "Results will be published to Kafka topic 'teacher-disciplinas-responses'"
        );
    }

    /**
     * Solicita alunos matriculados nas disciplinas do professor
     */
    @GetMapping("/alunos/request")
    public Map<String, Object> requestAlunos(@PathVariable Long teacherId) {
        logger.info("Requesting students for teacher: {}", teacherId);
        
        Map<String, Object> request = Map.of(
            "professorId", teacherId,
            "requestType", "GET_ALUNOS_BY_PROFESSOR",
            "requestedBy", "teacher-service",
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send("course-data-requests", teacherId.toString(), request);
        
        return Map.of(
            "message", "Students request sent",
            "professorId", teacherId,
            "status", "PROCESSING"
        );
    }

    /**
     * Solicita turmas (disciplinas com quantidade de alunos) do professor
     */
    @GetMapping("/turmas/request")
    public Map<String, Object> requestTurmas(@PathVariable Long teacherId) {
        logger.info("Requesting turmas for teacher: {}", teacherId);
        
        Map<String, Object> request = Map.of(
            "professorId", teacherId,
            "requestType", "GET_TURMAS",
            "requestedBy", "teacher-service",
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send("course-data-requests", teacherId.toString(), request);
        
        return Map.of(
            "message", "Turmas request sent",
            "professorId", teacherId,
            "status", "PROCESSING",
            "note", "Listen to 'teacher-turmas-responses' for async results"
        );
    }
}
