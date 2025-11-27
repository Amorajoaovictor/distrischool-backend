package br.unifor.distrischool.student_service.dto;

import java.time.LocalDate;

public class AlunoComCursoDTO {
    private Long id;
    private String nome;
    private LocalDate dataNascimento;
    private String endereco;
    private String contato;
    private String matricula;
    private String turma;
    private String historicoAcademico;
    
    // Informações do curso
    private Long cursoId;
    private String cursoNome;
    private String cursoCodigo;
    private String cursoModalidade;
    private String cursoTurno;

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
    
    public String getHistoricoAcademico() { return historicoAcademico; }
    public void setHistoricoAcademico(String historicoAcademico) { this.historicoAcademico = historicoAcademico; }
    
    public Long getCursoId() { return cursoId; }
    public void setCursoId(Long cursoId) { this.cursoId = cursoId; }
    
    public String getCursoNome() { return cursoNome; }
    public void setCursoNome(String cursoNome) { this.cursoNome = cursoNome; }
    
    public String getCursoCodigo() { return cursoCodigo; }
    public void setCursoCodigo(String cursoCodigo) { this.cursoCodigo = cursoCodigo; }
    
    public String getCursoModalidade() { return cursoModalidade; }
    public void setCursoModalidade(String cursoModalidade) { this.cursoModalidade = cursoModalidade; }
    
    public String getCursoTurno() { return cursoTurno; }
    public void setCursoTurno(String cursoTurno) { this.cursoTurno = cursoTurno; }
}
