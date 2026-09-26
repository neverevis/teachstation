package edu.ifsp.teachstation.persistence;

import edu.ifsp.teachstation.model.Aluno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AlunoRepository extends JpaRepository<Aluno, Integer> {

    Aluno findByEmail(String email);
}