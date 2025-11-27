package br.unifor.distrischool.course_service.repository;

import br.unifor.distrischool.course_service.model.Curso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface CursoRepository extends JpaRepository<Curso, Long> {
    Optional<Curso> findByCodigo(String codigo);
    List<Curso> findByStatus(String status);
    List<Curso> findByModalidade(String modalidade);
    List<Curso> findByTurno(String turno);
    boolean existsByCodigo(String codigo);
}
