package br.unifor.distrischool.student_service.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class CourseEventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(CourseEventConsumer.class);

    // Listener para eventos de cursos
    @KafkaListener(topics = "course-events", groupId = "student-service")
    public void consumeCourseEvent(Map<String, Object> event) {
        logger.info("Received course event in student-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        Long cursoId = ((Number) event.get("cursoId")).longValue();
        
        if ("CREATED".equals(eventType)) {
            logger.info("New course created: ID={}, codigo={}, nome={}", 
                cursoId, event.get("codigo"), event.get("nome"));
            // Curso está disponível para novos alunos
        } else if ("DELETED".equals(eventType)) {
            logger.warn("Course {} was deleted. Students with this course may need attention", cursoId);
            // TODO: Notificar alunos ou tomar ação apropriada
        }
    }

    // Listener para eventos de disciplinas
    @KafkaListener(topics = "disciplina-events", groupId = "student-service")
    public void consumeDisciplinaEvent(Map<String, Object> event) {
        logger.info("Received disciplina event in student-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        
        if ("CREATED".equals(eventType)) {
            logger.info("New disciplina created: ID={}, nome={}", 
                event.get("disciplinaId"), event.get("nome"));
        }
    }

    // Listener para eventos de matrículas
    @KafkaListener(topics = "matricula-events", groupId = "student-service")
    public void consumeMatriculaEvent(Map<String, Object> event) {
        logger.info("Received matricula event in student-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        Long alunoId = ((Number) event.get("alunoId")).longValue();
        
        if ("CREATED".equals(eventType)) {
            logger.info("Student {} enrolled in disciplina {}", 
                alunoId, event.get("disciplinaId"));
            // TODO: Atualizar cache local ou histórico do aluno
        } else if ("STATUS_CHANGED".equals(eventType)) {
            logger.info("Matricula {} status changed to {}", 
                event.get("matriculaId"), event.get("status"));
        }
    }

    // Listener para eventos de avaliações
    @KafkaListener(topics = "avaliacao-events", groupId = "student-service")
    public void consumeAvaliacaoEvent(Map<String, Object> event) {
        logger.info("Received avaliacao event in student-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        Long alunoId = ((Number) event.get("alunoId")).longValue();
        
        if ("CREATED".equals(eventType) || "UPDATED".equals(eventType) || "GRADE_RELEASED".equals(eventType)) {
            logger.info("Grade for student {} in disciplina {}: nota={}", 
                alunoId, event.get("disciplinaId"), event.get("nota"));
            // TODO: Notificar aluno sobre nova nota
            // TODO: Atualizar histórico acadêmico
        }
    }
}
