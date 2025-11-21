package br.unifor.distrischool.teacher_service.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class CourseEventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(CourseEventConsumer.class);

    // Listener para eventos de disciplinas
    @KafkaListener(topics = "disciplina-events", groupId = "teacher-service")
    public void consumeDisciplinaEvent(Map<String, Object> event) {
        logger.info("Received disciplina event in teacher-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        Object professorIdObj = event.get("professorId");
        
        if ("CREATED".equals(eventType) && professorIdObj != null) {
            Long professorId = ((Number) professorIdObj).longValue();
            logger.info("Teacher {} assigned to new disciplina: ID={}, nome={}", 
                professorId, event.get("disciplinaId"), event.get("nome"));
            // TODO: Notificar professor sobre nova disciplina
        } else if ("PROFESSOR_ASSIGNED".equals(eventType)) {
            Long professorId = ((Number) professorIdObj).longValue();
            logger.info("Teacher {} was assigned to disciplina {}", 
                professorId, event.get("disciplinaId"));
        } else if ("UPDATED".equals(eventType) && professorIdObj != null) {
            Long professorId = ((Number) professorIdObj).longValue();
            logger.info("Disciplina {} updated for teacher {}", 
                event.get("disciplinaId"), professorId);
        }
    }

    // Listener para eventos de matrículas (para saber quantos alunos tem na turma)
    @KafkaListener(topics = "matricula-events", groupId = "teacher-service")
    public void consumeMatriculaEvent(Map<String, Object> event) {
        logger.info("Received matricula event in teacher-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        
        if ("CREATED".equals(eventType)) {
            logger.info("New student enrolled in disciplina {}", event.get("disciplinaId"));
            // TODO: Atualizar cache de contagem de alunos
        } else if ("STATUS_CHANGED".equals(eventType)) {
            String status = (String) event.get("status");
            if ("TRANCADA".equals(status) || "CANCELADA".equals(status)) {
                logger.info("Student left disciplina {}", event.get("disciplinaId"));
            }
        }
    }

    // Listener para eventos de avaliações
    @KafkaListener(topics = "avaliacao-events", groupId = "teacher-service")
    public void consumeAvaliacaoEvent(Map<String, Object> event) {
        logger.info("Received avaliacao event in teacher-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        
        if ("CREATED".equals(eventType)) {
            logger.info("Grade registered for disciplina {}: aluno={}, nota={}", 
                event.get("disciplinaId"), event.get("alunoId"), event.get("nota"));
        }
    }
}
