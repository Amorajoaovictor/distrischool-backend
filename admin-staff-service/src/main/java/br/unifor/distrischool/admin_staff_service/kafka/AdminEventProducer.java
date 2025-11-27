package br.unifor.distrischool.admin_staff_service.kafka;

import br.unifor.distrischool.admin_staff_service.event.AdminEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class AdminEventProducer {

    private static final Logger logger = LoggerFactory.getLogger(AdminEventProducer.class);
    private static final String TOPIC = "admin-events";

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public AdminEventProducer(KafkaTemplate<String, String> kafkaTemplate, ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }

    public void publishAdminEvent(AdminEvent event) {
        try {
            String eventJson = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(TOPIC, eventJson);
            logger.info("📤 Evento de admin publicado: {}", event.getEventType());
        } catch (Exception e) {
            logger.error("❌ Erro ao publicar evento de admin", e);
            throw new RuntimeException("Falha ao publicar evento Kafka", e);
        }
    }
}
