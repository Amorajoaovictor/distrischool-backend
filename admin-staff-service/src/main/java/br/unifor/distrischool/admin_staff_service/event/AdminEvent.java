package br.unifor.distrischool.admin_staff_service.event;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class AdminEvent {

    // Mantém adminId para compatibilidade interna, mas não serializa
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Long adminId;
    
    private String name;
    private String eventType; // CREATED, UPDATED, DELETED
    private LocalDateTime timestamp;
    
    // Campos para integração com auth-service
    private String email;
    
    @JsonProperty("fullName")
    private String fullName;
    
    private String role = "ADMIN";
    
    @JsonProperty("externalId")
    private String externalId;
    
    private String password; // Apenas para evento CREATED

    public AdminEvent() {
        this.timestamp = LocalDateTime.now();
        this.role = "ADMIN";
    }

    public AdminEvent(Long adminId, String name, String email, String eventType) {
        this.adminId = adminId;
        this.name = name;
        this.fullName = name;
        this.email = email;
        this.eventType = eventType;
        this.externalId = adminId != null ? adminId.toString() : null;
        this.timestamp = LocalDateTime.now();
        this.role = "ADMIN";
    }
    
    public AdminEvent(Long adminId, String name, String email, String password, String eventType) {
        this(adminId, name, email, eventType);
        this.password = password;
    }

    // Getters and Setters
    public Long getAdminId() {
        return adminId;
    }

    public void setAdminId(Long adminId) {
        this.adminId = adminId;
        if (adminId != null) {
            this.externalId = adminId.toString();
        }
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        this.fullName = name;
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
        this.name = fullName;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "AdminEvent{" +
                "adminId=" + adminId +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
