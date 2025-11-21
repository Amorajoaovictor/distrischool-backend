package br.unifor.distrischool.course_service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;

public class CursoDTO {
    private Long id;
    
    @NotBlank(message = "Nome é obrigatório")
    private String nome;
    
    @NotBlank(message = "Código é obrigatório")
    private String codigo;
    
    private String descricao;
    
    @NotNull(message = "Duração em semestres é obrigatória")
    @Min(value = 1, message = "Duração deve ser de pelo menos 1 semestre")
    private Integer duracaoSemestres;
    
    @NotBlank(message = "Modalidade é obrigatória")
    private String modalidade;
    
    @NotBlank(message = "Turno é obrigatório")
    private String turno;
    
    @NotBlank(message = "Status é obrigatório")
    private String status;

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public Integer getDuracaoSemestres() {
        return duracaoSemestres;
    }

    public void setDuracaoSemestres(Integer duracaoSemestres) {
        this.duracaoSemestres = duracaoSemestres;
    }

    public String getModalidade() {
        return modalidade;
    }

    public void setModalidade(String modalidade) {
        this.modalidade = modalidade;
    }

    public String getTurno() {
        return turno;
    }

    public void setTurno(String turno) {
        this.turno = turno;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
