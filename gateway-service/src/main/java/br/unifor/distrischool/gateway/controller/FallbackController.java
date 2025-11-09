package br.unifor.distrischool.gateway.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/auth")
    @PostMapping("/auth")
    public ResponseEntity<Map<String, Object>> authServiceFallback() {
        return buildFallbackResponse("Auth Service", "Circuit Breaker ativado após 5s de timeout");
    }

    @GetMapping("/users")
    @PostMapping("/users")
    public ResponseEntity<Map<String, Object>> userServiceFallback() {
        return buildFallbackResponse("User Service", "Circuit Breaker ativado após 5s de timeout");
    }

    @GetMapping("/students")
    @PostMapping("/students")
    public ResponseEntity<Map<String, Object>> studentServiceFallback() {
        return buildFallbackResponse("Student Service", "Circuit Breaker ativado após 5s de timeout");
    }

    @GetMapping("/teachers")
    @PostMapping("/teachers")
    public ResponseEntity<Map<String, Object>> teacherServiceFallback() {
        return buildFallbackResponse("Teacher Service", "Circuit Breaker ativado após 5s de timeout");
    }

    @GetMapping("/admin")
    @PostMapping("/admin")
    public ResponseEntity<Map<String, Object>> adminServiceFallback() {
        return buildFallbackResponse("Admin Staff Service", "Circuit Breaker ativado após 5s de timeout");
    }

    private ResponseEntity<Map<String, Object>> buildFallbackResponse(String serviceName, String details) {
        Map<String, Object> response = new HashMap<>();
        response.put("error", "Service Unavailable");
        response.put("service", serviceName);
        response.put("message", serviceName + " está temporariamente indisponível. " + details);
        response.put("status", HttpStatus.SERVICE_UNAVAILABLE.value());
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("circuitBreakerActive", true);
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

}
