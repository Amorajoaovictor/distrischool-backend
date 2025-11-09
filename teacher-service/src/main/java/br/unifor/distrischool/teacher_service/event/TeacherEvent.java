package br.unifor.distrischool.teacher_service.event;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class TeacherEvent {

    private Long teacherId;
    private String nome;
    private String qualificacao;
    private String contato;
    private String eventType; // CREATED, UPDATED, DELETED
    private LocalDateTime timestamp;
    
    // Campos para integração com auth-service
    private String email;
    
    @JsonProperty("fullName")
    private String fullName;
    
    private String role = "TEACHER";
    
    @JsonProperty("externalId")
    private String externalId;

    public TeacherEvent() {
        this.timestamp = LocalDateTime.now();
        this.role = "TEACHER";
    }

    public TeacherEvent(Long teacherId, String nome, String qualificacao, String contato, String eventType) {
        this.teacherId = teacherId;
        this.nome = nome;
        this.qualificacao = qualificacao;
        this.contato = contato;
        this.eventType = eventType;
        this.timestamp = LocalDateTime.now();
        this.role = "TEACHER";
    }
    
    public TeacherEvent(Long teacherId, String nome, String qualificacao, String contato, String email, String eventType) {
        this.teacherId = teacherId;
        this.nome = nome;
        this.fullName = nome;
        this.qualificacao = qualificacao;
        this.contato = contato;
        this.email = email;
        this.eventType = eventType;
        this.externalId = teacherId != null ? teacherId.toString() : null;
        this.timestamp = LocalDateTime.now();
        this.role = "TEACHER";
    }

    // Getters and Setters
    public Long getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(Long teacherId) {
        this.teacherId = teacherId;
        if (teacherId != null) {
            this.externalId = teacherId.toString();
        }
    }

    public String getNome() {
        return nome;
    }
-*********
    public void setNome(String nome) {
        this.nome = nome;
        this.fullName = nome;
    }

    public String getQualificacao() {
        return qualificacao;
    }

    public void setQualificacao(String qualificacao) {
        this.qualificacao = qualificacao;
    }

    public String getContato() {
        return contato;
    }

    public void setContato(String contato) {
        this.contato = contato;
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
        return "TeacherEvent{" +
                "teacherId=" + teacherId +
                ", nome='" + nome + '\'' +
                ", email='" + email + '\'' +
                ", qualificacao='" + qualificacao + '\'' +
                ", contato='" + contato + '\'' +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
