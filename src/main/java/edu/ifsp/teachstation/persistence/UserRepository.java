package edu.ifsp.teachstation.persistence;

import edu.ifsp.teachstation.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<Usuario, Integer> {
	
	Usuario findByEmail(String email);
}
