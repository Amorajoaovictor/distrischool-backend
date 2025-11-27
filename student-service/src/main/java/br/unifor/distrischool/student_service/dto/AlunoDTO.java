package br.unifor.distrischool.student_service.dto;

import java.time.LocalDate;

public class AlunoDTO {
    private Long id;
    private String nome;
    private LocalDate dataNascimento;
    private String endereco;
    private String contato;
    private String matricula;
    private String turma;
    private Long cursoId;
    private String historicoAcademico; // Campo não criptografado para receber do cliente

    // Getters e setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public LocalDate getDataNascimento() { return dataNascimento; }
    public void setDataNascimento(LocalDate dataNascimento) { this.dataNascimento = dataNascimento; }
    
    public String getEndereco() { return endereco; }
    public void setEndereco(String endereco) { this.endereco = endereco; }
    
    public String getContato() { return contato; }
    public void setContato(String contato) { this.contato = contato; }
    
    public String getMatricula() { return matricula; }
    public void setMatricula(String matricula) { this.matricula = matricula; }
    
    public String getTurma() { return turma; }
    public void setTurma(String turma) { this.turma = turma; }
    
    public Long getCursoId() { return cursoId; }
    public void setCursoId(Long cursoId) { this.cursoId = cursoId; }
    
    public String getHistoricoAcademico() { return historicoAcademico; }
    public void setHistoricoAcademico(String historicoAcademico) { this.historicoAcademico = historicoAcademico; }
}
