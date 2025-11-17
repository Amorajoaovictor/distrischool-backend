package br.unifor.distrischool.auth_service.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
public class UserCreationEventProducer {

    private static final Logger logger = LoggerFactory.getLogger(UserCreationEventProducer.class);

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * Publica evento de criação de usuário específico para cada tipo
     * Tópicos: student-username-creation-event, teacher-username-creation-event, admin-username-creation-event
     */
    public void publishUserCreationEvent(String email, String role, String username, Long externalId, String password, boolean passwordGenerated) {
        try {
            // Define o tópico baseado no role
            String topic = getTopicForRole(role);
            
            Map<String, Object> event = new HashMap<>();
            event.put("email", email);
            event.put("username", username);
            event.put("password", password);
            event.put("passwordGenerated", passwordGenerated);
            event.put("role", role);
            event.put("externalId", externalId);
            event.put("createdAt", LocalDateTime.now().toString());
            event.put("eventType", "USER_CREATED");

            String eventJson = objectMapper.writeValueAsString(event);
            
            kafkaTemplate.send(topic, eventJson);
            
            logger.info("📤 Published user creation event to topic '{}': {} (password: {})", 
                    topic, username, passwordGenerated ? "[GENERATED]" : "[PROVIDED]");
        } catch (Exception e) {
            logger.error("❌ Error publishing user creation event for {}", email, e);
        }
    }

    /**
     * Retorna o nome do tópico baseado no role
     */
    private String getTopicForRole(String role) {
        switch (role) {
            case "ROLE_STUDENT":
                return "student-username-creation-event";
            case "ROLE_TEACHER":
                return "teacher-username-creation-event";
            case "ROLE_ADMIN":
                return "admin-username-creation-event";
            default:
                logger.warn("⚠️ Unknown role '{}', using generic topic", role);
                return "user-username-creation-event";
        }
    }
}
