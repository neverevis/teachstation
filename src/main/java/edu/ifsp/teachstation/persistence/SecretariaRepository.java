package edu.ifsp.teachstation.persistence;

import edu.ifsp.teachstation.model.Secretaria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SecretariaRepository extends JpaRepository<Secretaria, Integer> {
}
