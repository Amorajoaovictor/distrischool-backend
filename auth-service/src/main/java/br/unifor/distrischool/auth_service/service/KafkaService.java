package br.unifor.distrischool.auth_service.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class KafkaService {

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    public void sendUserLoggedEvent(String email) {
        String message = String.format("{\"email\":\"%s\",\"timestamp\":\"%s\"}", 
            email, java.time.LocalDateTime.now());
        kafkaTemplate.send("user-events", message);
    }
}
