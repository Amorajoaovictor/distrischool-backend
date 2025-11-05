package br.unifor.distrischool.auth_service.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class UserCreatedEvent {
    private String email;
    private String fullName;
    private String role; // STUDENT, TEACHER, ADMIN, PARENT
    private String externalId; // ID do serviço de origem

    public UserCreatedEvent() {}

    public UserCreatedEvent(String email, String fullName, String role, String externalId) {
        this.email = email;
        this.fullName = fullName;
        this.role = role;
        this.externalId = externalId;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getExternalId() { return externalId; }
    public void setExternalId(String externalId) { this.externalId = externalId; }
}
