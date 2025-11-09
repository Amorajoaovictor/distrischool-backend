package br.unifor.distrischool.student_service.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
public class Aluno {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false)
    private LocalDate dataNascimento;

    @Column(nullable = false)
    private String endereco;

    @Column(nullable = false)
    private String contato;

    @Column(nullable = false, unique = true)
    private String matricula;

    @Column(nullable = false)
    private String turma;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String historicoAcademicoCriptografado;

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
    public String getHistoricoAcademicoCriptografado() { return historicoAcademicoCriptografado; }
    public void setHistoricoAcademicoCriptografado(String historicoAcademicoCriptografado) { this.historicoAcademicoCriptografado = historicoAcademicoCriptografado; }
}
