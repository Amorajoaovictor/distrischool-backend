package br.unifor.distrischool.course_service.repository;

import br.unifor.distrischool.course_service.model.Avaliacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {
    List<Avaliacao> findByMatriculaId(Long matriculaId);
    
    @Query("SELECT a FROM Avaliacao a WHERE a.matricula.alunoId = :alunoId")
    List<Avaliacao> findByAlunoId(@Param("alunoId") Long alunoId);
    
    @Query("SELECT a FROM Avaliacao a WHERE a.matricula.disciplina.id = :disciplinaId")
    List<Avaliacao> findByDisciplinaId(@Param("disciplinaId") Long disciplinaId);
    
    @Query("SELECT a FROM Avaliacao a WHERE a.matricula.alunoId = :alunoId AND a.matricula.disciplina.id = :disciplinaId")
    List<Avaliacao> findByAlunoIdAndDisciplinaId(@Param("alunoId") Long alunoId, @Param("disciplinaId") Long disciplinaId);
}
