package br.unifor.distrischool.course_service.kafka;

import br.unifor.distrischool.course_service.event.CourseEvent;
import br.unifor.distrischool.course_service.event.DisciplinaEvent;
import br.unifor.distrischool.course_service.event.MatriculaEvent;
import br.unifor.distrischool.course_service.event.AvaliacaoEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class CourseEventProducer {

    private static final Logger logger = LoggerFactory.getLogger(CourseEventProducer.class);
    
    private static final String COURSE_TOPIC = "course-events";
    private static final String DISCIPLINA_TOPIC = "disciplina-events";
    private static final String MATRICULA_TOPIC = "matricula-events";
    private static final String AVALIACAO_TOPIC = "avaliacao-events";

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public CourseEventProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishCourseEvent(CourseEvent event) {
        logger.info("Publishing course event: {}", event);
        CompletableFuture<SendResult<String, Object>> future = 
            kafkaTemplate.send(COURSE_TOPIC, event.getCursoId().toString(), event);
        
        logResult(future, "Course");
    }

    public void publishDisciplinaEvent(DisciplinaEvent event) {
        logger.info("Publishing disciplina event: {}", event);
        CompletableFuture<SendResult<String, Object>> future = 
            kafkaTemplate.send(DISCIPLINA_TOPIC, event.getDisciplinaId().toString(), event);
        
        logResult(future, "Disciplina");
    }

    public void publishMatriculaEvent(MatriculaEvent event) {
        logger.info("Publishing matricula event: {}", event);
        CompletableFuture<SendResult<String, Object>> future = 
            kafkaTemplate.send(MATRICULA_TOPIC, event.getMatriculaId().toString(), event);
        
        logResult(future, "Matricula");
    }

    public void publishAvaliacaoEvent(AvaliacaoEvent event) {
        logger.info("Publishing avaliacao event: {}", event);
        CompletableFuture<SendResult<String, Object>> future = 
            kafkaTemplate.send(AVALIACAO_TOPIC, event.getAvaliacaoId().toString(), event);
        
        logResult(future, "Avaliacao");
    }

    private void logResult(CompletableFuture<SendResult<String, Object>> future, String eventType) {
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                logger.info("{} event published successfully: topic={}, partition={}, offset={}",
                        eventType,
                        result.getRecordMetadata().topic(),
                        result.getRecordMetadata().partition(),
                        result.getRecordMetadata().offset());
            } else {
                logger.error("Failed to publish {} event", eventType, ex);
            }
        });
    }
}
