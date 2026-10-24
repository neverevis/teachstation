package edu.ifsp.teachstation.persistence;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.AvaliacaoDiagnostica;

@Repository
public interface AvaliacaoDiagnosticaRepository extends JpaRepository<AvaliacaoDiagnostica, Integer> {

    // Busca a avaliação diagnóstica realizada por um aluno
	// Optional = pode ou não existir
    Optional<AvaliacaoDiagnostica> findByAlunoId(Integer alunoId);

    // Verifica se o aluno já realizou a avaliação diagnóstica
    boolean existsByAlunoId(Integer alunoId);
    
    // Média das notas finais de todas as avaliações
    @Query("SELECT COALESCE(AVG(a.notaFinal), 0) FROM AvaliacaoDiagnostica a")
    double calcularMediaNotas();
}