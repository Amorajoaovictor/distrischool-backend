package br.unifor.distrischool.course_service.event;

import java.time.LocalDateTime;

public class CourseEvent {
    private Long cursoId;
    private String codigo;
    private String nome;
    private String eventType; // CREATED, UPDATED, DELETED, VALIDATED
    private LocalDateTime timestamp;

    public CourseEvent() {
        this.timestamp = LocalDateTime.now();
    }

    public CourseEvent(Long cursoId, String codigo, String nome, String eventType) {
        this.cursoId = cursoId;
        this.codigo = codigo;
        this.nome = nome;
        this.eventType = eventType;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getCursoId() {
        return cursoId;
    }

    public void setCursoId(Long cursoId) {
        this.cursoId = cursoId;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
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
        return "CourseEvent{" +
                "cursoId=" + cursoId +
                ", codigo='" + codigo + '\'' +
                ", nome='" + nome + '\'' +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
