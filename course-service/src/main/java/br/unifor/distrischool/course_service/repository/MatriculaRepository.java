package br.unifor.distrischool.course_service.repository;

import br.unifor.distrischool.course_service.model.Matricula;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MatriculaRepository extends JpaRepository<Matricula, Long> {
    List<Matricula> findByAlunoId(Long alunoId);
    List<Matricula> findByDisciplinaId(Long disciplinaId);
    List<Matricula> findByAlunoIdAndStatus(Long alunoId, String status);
    List<Matricula> findByDisciplinaIdAndStatus(Long disciplinaId, String status);
    Optional<Matricula> findByAlunoIdAndDisciplinaId(Long alunoId, Long disciplinaId);
    boolean existsByAlunoIdAndDisciplinaId(Long alunoId, Long disciplinaId);
}
