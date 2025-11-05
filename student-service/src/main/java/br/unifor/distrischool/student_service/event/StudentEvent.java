package br.unifor.distrischool.student_service.event;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class StudentEvent {

    private Long studentId;
    private String nome;
    private String matricula;
    private String eventType; // CREATED, UPDATED, DELETED
    private LocalDateTime timestamp;
    
    // Campos para integração com auth-service
    private String email;
    
    @JsonProperty("fullName")
    private String fullName;
    
    private String role = "STUDENT";
    
    @JsonProperty("externalId")
    private String externalId;

    public StudentEvent() {
        this.timestamp = LocalDateTime.now();
        this.role = "STUDENT";
    }

    public StudentEvent(Long studentId, String nome, String matricula, String eventType) {
        this.studentId = studentId;
        this.nome = nome;
        this.matricula = matricula;
        this.eventType = eventType;
        this.timestamp = LocalDateTime.now();
        this.role = "STUDENT";
    }
    
    public StudentEvent(Long studentId, String nome, String matricula, String email, String eventType) {
        this.studentId = studentId;
        this.nome = nome;
        this.fullName = nome;
        this.matricula = matricula;
        this.email = email;
        this.eventType = eventType;
        this.externalId = studentId != null ? studentId.toString() : null;
        this.timestamp = LocalDateTime.now();
        this.role = "STUDENT";
    }

    // Getters and Setters
    public Long getStudentId() {
        return studentId;
    }

    public void setStudentId(Long studentId) {
        this.studentId = studentId;
        if (studentId != null) {
            this.externalId = studentId.toString();
        }
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
        this.fullName = nome;
    }

    public String getMatricula() {
        return matricula;
    }

    public void setMatricula(String matricula) {
        this.matricula = matricula;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
        this.nome = fullName;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getExternalId() {
        return externalId;
    }

    public void setExternalId(String externalId) {
        this.externalId = externalId;
    }

    @Override
    public String toString() {
        return "StudentEvent{" +
                "studentId=" + studentId +
                ", nome='" + nome + '\'' +
                ", matricula='" + matricula + '\'' +
                ", email='" + email + '\'' +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
