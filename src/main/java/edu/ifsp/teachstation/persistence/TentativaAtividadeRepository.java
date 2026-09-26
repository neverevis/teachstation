package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.TentativaAtividade;

@Repository
public interface TentativaAtividadeRepository extends JpaRepository<TentativaAtividade, Integer> {

    // Busca histórico de tentativas de um aluno específico
    List<TentativaAtividade> findByAlunoId(Integer alunoId);

    // Verifica se o aluno já respondeu a uma questão específica
    boolean existsByAlunoIdAndQuestaoId(Integer alunoId, Integer questaoId);

    // Calcula a pontuação total acumulada pelo aluno nas tentativas
    @Query("SELECT COALESCE(SUM(t.pontosObtidos), 0) FROM TentativaAtividade t WHERE t.aluno.id = :alunoId")
    Integer sumPontosByAlunoId(@Param("alunoId") Integer alunoId);
}