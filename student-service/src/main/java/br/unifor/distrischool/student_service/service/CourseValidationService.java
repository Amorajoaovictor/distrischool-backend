package br.unifor.distrischool.student_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
public class CourseValidationService {

    private static final Logger logger = LoggerFactory.getLogger(CourseValidationService.class);
    private static final String VALIDATION_TOPIC = "course-validation-requests";

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public CourseValidationService(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    /**
     * Valida se um curso existe via evento Kafka
     * Nota: Esta é uma validação assíncrona. Para validação síncrona,
     * usar RestTemplate ou WebClient para chamar o course-service diretamente.
     */
    public void requestCourseValidation(Long cursoId, String context) {
        logger.info("Requesting course validation for cursoId: {} in context: {}", cursoId, context);
        
        Map<String, Object> validationRequest = Map.of(
            "cursoId", cursoId,
            "requestedBy", "student-service",
            "context", context,
            "timestamp", System.currentTimeMillis()
        );
        
        CompletableFuture<SendResult<String, Object>> future = 
            kafkaTemplate.send(VALIDATION_TOPIC, cursoId.toString(), validationRequest);
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                logger.info("Course validation request sent successfully for curso: {}", cursoId);
            } else {
                logger.error("Failed to send course validation request for curso: {}", cursoId, ex);
            }
        });
    }
    
    /**
     * Verifica se curso está disponível (baseado em cache local de eventos)
     * Nota: Implementação futura pode manter cache de cursos ativos
     */
    public boolean isCourseAvailable(Long cursoId) {
        // TODO: Implementar cache local de cursos baseado em eventos Kafka
        // Por enquanto, sempre retorna true (validação assíncrona)
        logger.warn("Course availability check not implemented yet. Assuming curso {} is available", cursoId);
        return true;
    }
}
