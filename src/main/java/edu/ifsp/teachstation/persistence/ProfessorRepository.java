package edu.ifsp.teachstation.persistence;

import java.util.List;
import edu.ifsp.teachstation.model.Professor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ProfessorRepository extends JpaRepository<Professor, Integer> {

    Professor findByEmail(String email);

    Professor findByProntuario(String prontuario);

    @Query("SELECT p FROM Professor p WHERE LOWER(p.nomeCompleto) LIKE LOWER(CONCAT('%', :termo, '%')) OR LOWER(p.prontuario) LIKE LOWER(CONCAT('%', :termo, '%')) OR LOWER(p.areaAtuacao) LIKE LOWER(CONCAT('%', :termo, '%')) OR LOWER(p.email) LIKE LOWER(CONCAT('%', :termo, '%'))")
    List<Professor> pesquisar(@Param("termo") String termo);
}
