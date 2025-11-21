package br.unifor.distrischool.course_service.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class CourseEventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(CourseEventConsumer.class);

    // Listener para eventos de alunos (student-service)
    @KafkaListener(topics = "student-events", groupId = "course-service")
    public void consumeStudentEvent(Map<String, Object> event) {
        logger.info("Received student event in course-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        
        // Processar eventos de alunos se necessário
        // Ex: quando aluno é deletado, cancelar todas as matrículas
        if ("DELETED".equals(eventType)) {
            Long studentId = ((Number) event.get("studentId")).longValue();
            logger.info("Student {} was deleted. Should cancel all matriculas", studentId);
            // TODO: Implementar cancelamento automático de matrículas
        }
    }

    // Listener para eventos de professores (teacher-service)
    @KafkaListener(topics = "teacher-events", groupId = "course-service")
    public void consumeTeacherEvent(Map<String, Object> event) {
        logger.info("Received teacher event in course-service: {}", event);
        
        String eventType = (String) event.get("eventType");
        
        // Processar eventos de professores se necessário
        // Ex: quando professor é deletado, desalocar de disciplinas
        if ("DELETED".equals(eventType)) {
            Long teacherId = ((Number) event.get("teacherId")).longValue();
            logger.info("Teacher {} was deleted. Should unassign from all disciplinas", teacherId);
            // TODO: Implementar desalocação automática de disciplinas
        }
    }
}
