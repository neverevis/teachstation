package edu.ifsp.teachstation.persistence;

import java.util.List;
import edu.ifsp.teachstation.model.Aluno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface AlunoRepository extends JpaRepository<Aluno, Integer> {

    Aluno findByEmail(String email);

    Aluno findByRa(String ra);

    @Query("SELECT a FROM Aluno a WHERE LOWER(a.nomeCompleto) LIKE LOWER(CONCAT('%', :termo, '%')) OR LOWER(COALESCE(a.nomeSocial, '')) LIKE LOWER(CONCAT('%', :termo, '%')) OR LOWER(a.ra) LIKE LOWER(CONCAT('%', :termo, '%')) OR LOWER(a.email) LIKE LOWER(CONCAT('%', :termo, '%'))")
    List<Aluno> pesquisar(@Param("termo") String termo);
}
