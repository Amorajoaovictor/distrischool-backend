package br.unifor.distrischool.course_service.event;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AvaliacaoEvent {
    private Long avaliacaoId;
    private Long matriculaId;
    private Long alunoId;
    private Long disciplinaId;
    private String tipoAvaliacao;
    private BigDecimal nota;
    private String eventType; // CREATED, UPDATED, DELETED, GRADE_RELEASED
    private LocalDateTime timestamp;

    public AvaliacaoEvent() {
        this.timestamp = LocalDateTime.now();
    }

    public AvaliacaoEvent(Long avaliacaoId, Long matriculaId, Long alunoId, Long disciplinaId, 
                         String tipoAvaliacao, BigDecimal nota, String eventType) {
        this.avaliacaoId = avaliacaoId;
        this.matriculaId = matriculaId;
        this.alunoId = alunoId;
        this.disciplinaId = disciplinaId;
        this.tipoAvaliacao = tipoAvaliacao;
        this.nota = nota;
        this.eventType = eventType;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getAvaliacaoId() {
        return avaliacaoId;
    }

    public void setAvaliacaoId(Long avaliacaoId) {
        this.avaliacaoId = avaliacaoId;
    }

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

    public String getTipoAvaliacao() {
        return tipoAvaliacao;
    }

    public void setTipoAvaliacao(String tipoAvaliacao) {
        this.tipoAvaliacao = tipoAvaliacao;
    }

    public BigDecimal getNota() {
        return nota;
    }

    public void setNota(BigDecimal nota) {
        this.nota = nota;
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
        return "AvaliacaoEvent{" +
                "avaliacaoId=" + avaliacaoId +
                ", matriculaId=" + matriculaId +
                ", alunoId=" + alunoId +
                ", disciplinaId=" + disciplinaId +
                ", tipoAvaliacao='" + tipoAvaliacao + '\'' +
                ", nota=" + nota +
                ", eventType='" + eventType + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
