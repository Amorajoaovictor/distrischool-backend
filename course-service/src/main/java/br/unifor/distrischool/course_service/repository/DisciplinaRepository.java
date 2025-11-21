package main.java.br.unifor.distrischool.course_service.repository;

import br.unifor.distrischool.course_service.model.Disciplina;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface DisciplinaRepository extends JpaRepository<Disciplina, Long> {
    Optional<Disciplina> findByCodigo(String codigo);
    List<Disciplina> findByCursoId(Long cursoId);
    List<Disciplina> findByStatus(String status);
    List<Disciplina> findByTipo(String tipo);
    List<Disciplina> findByCursoIdAndPeriodo(Long cursoId, Integer periodo);
    List<Disciplina> findByProfessorId(Long professorId);
    boolean existsByCodigo(String codigo);
}
