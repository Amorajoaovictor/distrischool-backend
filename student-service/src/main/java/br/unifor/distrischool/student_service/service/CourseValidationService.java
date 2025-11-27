package br.unifor.distrischool.student_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Service
public class CourseValidationService {

    private static final Logger logger = LoggerFactory.getLogger(CourseValidationService.class);
    private static final String VALIDATION_TOPIC = "course-validation-requests";
    private static final String DATA_REQUEST_TOPIC = "course-data-requests";
    
    // Cache temporário para responses do Kafka
    private final Map<String, Map<String, Object>> responseCache = new ConcurrentHashMap<>();

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public CourseValidationService(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }
    
    /**
     * Busca informações completas de um curso via Kafka request/response
     */
    public Map<String, Object> getCursoInfo(Long cursoId) {
        String requestId = "curso-info-" + cursoId + "-" + System.currentTimeMillis();
        
        logger.info("Requesting curso info for cursoId: {} with requestId: {}", cursoId, requestId);
        
        Map<String, Object> request = Map.of(
            "requestId", requestId,
            "requestType", "GET_CURSO",
            "cursoId", cursoId,
            "timestamp", System.currentTimeMillis()
        );
        
        kafkaTemplate.send(DATA_REQUEST_TOPIC, requestId, request);
        
        // Aguarda resposta no cache (timeout de 5 segundos)
        return waitForResponse(requestId, 5000);
    }
    
    /**
     * Método chamado pelo consumer quando recebe resposta
     */
    public void cacheResponse(String requestId, Map<String, Object> data) {
        logger.info("Caching response for requestId: {}", requestId);
        responseCache.put(requestId, data);
    }
    
    /**
     * Aguarda resposta no cache
     */
    private Map<String, Object> waitForResponse(String requestId, long timeoutMs) {
        long startTime = System.currentTimeMillis();
        
        while (System.currentTimeMillis() - startTime < timeoutMs) {
            Map<String, Object> response = responseCache.remove(requestId);
            if (response != null) {
                logger.info("Response received for requestId: {}", requestId);
                return response;
            }
            
            try {
                TimeUnit.MILLISECONDS.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.warn("Thread interrupted while waiting for response", e);
                return null;
            }
        }
        
        logger.warn("Timeout waiting for response for requestId: {}", requestId);
        return null;
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
