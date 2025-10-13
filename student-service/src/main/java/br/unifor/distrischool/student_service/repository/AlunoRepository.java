package br.unifor.distrischool.student_service.repository;

import br.unifor.distrischool.student_service.model.Aluno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlunoRepository extends JpaRepository<Aluno, Long> {
    Optional<Aluno> findByMatricula(String matricula);
    List<Aluno> findByNomeContainingIgnoreCase(String nome);
    List<Aluno> findByTurma(String turma);
}
