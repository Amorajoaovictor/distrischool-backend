package br.unifor.distrischool.teacher_service.repository;

import br.unifor.distrischool.teacher_service.model.Teacher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TeacherRepository extends JpaRepository<Teacher, Long> {
}
