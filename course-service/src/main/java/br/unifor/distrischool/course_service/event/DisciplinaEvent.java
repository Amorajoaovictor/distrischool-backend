package br.unifor.distrischool.course_service.event;

import java.time.LocalDateTime;

public class DisciplinaEvent {
    private Long disciplinaId;
    private Long cursoId;
    private Long professorId;
    private String codigo;
    private String nome;
    private String eventType; // CREATED, UPDATED, DELETED, PROFESSOR_ASSIGNED
    private LocalDateTime timestamp;

    public DisciplinaEvent() {
        this.timestamp = LocalDateTime.now();
    }

    public DisciplinaEvent(Long disciplinaId, Long cursoId, Long professorId, String codigo, String nome, String eventType) {
        this.disciplinaId = disciplinaId;
        this.cursoId = cursoId;
        this.professorId = professorId;
        this.codigo = codigo;
        this.nome = nome;
        this.eventType = eventType;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getDisciplinaId() {
        return disciplinaId;
    }

    public void setDisciplinaId(Long disciplinaId) {
        this.disciplinaId = disciplinaId;
    }

    public Long getCursoId() {
        return cursoId;
    }

    public void setCursoId(Long cursoId) {
        this.cursoId = cursoId;
    }

    public Long getProfessorId() {
        return professorId;
    }

    public void setProfessorId(Long professorId) {
        this.professorId = professorId;
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
        return "DisciplinaEvent{" +
                "disciplinaId=" + disciplinaId +
                ", cursoId=" + cursoId +
                ", professorId=" + professorId +
                ", codigo='" + codigo + '\'' +
                ", nome='" + nome + '\'' +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
