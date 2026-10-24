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
    // COALESCE = retorna o primeiro valor que não seja NULL entre os valores passados
    @Query("SELECT COALESCE(SUM(t.pontosObtidos), 0) FROM TentativaAtividade t WHERE t.aluno.id = :alunoId")
    Integer sumPontosByAlunoId(@Param("alunoId") Integer alunoId);
    
    // Soma total de acertos nas tentativas diagnósticas de todos os alunos
    @Query("SELECT COALESCE(SUM(CASE WHEN t.acertou = true THEN 1 ELSE 0 END), 0) " + "FROM TentativaAtividade t")
    long countAcertosDiagnosticos();

    // Total de tentativas diagnósticas registradas
    @Query("SELECT COUNT(t) FROM TentativaAtividade t")
    long countTentativasDiagnosticas();

    // Total de acertos de um aluno específico
    @Query("SELECT COALESCE(SUM(CASE WHEN t.acertou = true THEN 1 ELSE 0 END), 0) " + "FROM TentativaAtividade t WHERE t.aluno.id = :alunoId")
    int countAcertosByAluno(@Param("alunoId") Integer alunoId);

    // Total de tentativas de um aluno específico
    long countByAlunoId(Integer alunoId);
}