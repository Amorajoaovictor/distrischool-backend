package br.unifor.distrischool.course_service.event;

import java.time.LocalDateTime;

public class MatriculaEvent {
    private Long matriculaId;
    private Long alunoId;
    private Long disciplinaId;
    private String status;
    private String eventType; // CREATED, UPDATED, DELETED, STATUS_CHANGED
    private LocalDateTime timestamp;

    public MatriculaEvent() {
        this.timestamp = LocalDateTime.now();
    }

    public MatriculaEvent(Long matriculaId, Long alunoId, Long disciplinaId, String status, String eventType) {
        this.matriculaId = matriculaId;
        this.alunoId = alunoId;
        this.disciplinaId = disciplinaId;
        this.status = status;
        this.eventType = eventType;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getMatriculaId() {
        return matriculaId;
    }

    public void setMatriculaId(Long matriculaId) {
        this.matriculaId = matriculaId;
    }

    public Long getAlunoId() {
        return alunoId;
    }

    public void setAlunoId(Long alunoId) {
        this.alunoId = alunoId;
    }

    public Long getDisciplinaId() {
        return disciplinaId;
    }

    public void setDisciplinaId(Long disciplinaId) {
        this.disciplinaId = disciplinaId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    @Override
    public String toString() {
        return "MatriculaEvent{" +
                "matriculaId=" + matriculaId +
                ", alunoId=" + alunoId +
                ", disciplinaId=" + disciplinaId +
                ", status='" + status + '\'' +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
