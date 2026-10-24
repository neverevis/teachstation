package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.TentativaGamificada;

@Repository
public interface TentativaGamificadaRepository extends JpaRepository<TentativaGamificada, Integer> {

    // Todas as tentativas de um aluno em uma rodada de uma fase, na ordem em que foram feitas
    List<TentativaGamificada> findByAlunoIdAndRodadaAndQuestaoGamificadaFaseOrderByIdAsc(
            Integer alunoId, Integer rodada, Integer fase);

    // Última rodada jogada pelo aluno na fase (0 se nunca jogou)
    @Query("SELECT COALESCE(MAX(t.rodada), 0) FROM TentativaGamificada t "
            + "WHERE t.aluno.id = :alunoId AND t.questaoGamificada.fase = :fase")
    Integer findUltimaRodada(@Param("alunoId") Integer alunoId, @Param("fase") Integer fase);
    
    // Soma total de acertos nas tentativas gamificadas de todos os alunos
    @Query("SELECT COALESCE(SUM(CASE WHEN t.acertou = true THEN 1 ELSE 0 END), 0) " + "FROM TentativaGamificada t")
    long countAcertosGamificados();

    // Total de tentativas gamificadas registradas
    @Query("SELECT COUNT(t) FROM TentativaGamificada t")
    long countTentativasGamificadas();

    // Total de acertos de um aluno
    @Query("SELECT COALESCE(SUM(CASE WHEN t.acertou = true THEN 1 ELSE 0 END), 0) " + "FROM TentativaGamificada t WHERE t.aluno.id = :alunoId")
    int countAcertosByAluno(@Param("alunoId") Integer alunoId);

    // Total de tentativas de um aluno
    long countByAlunoId(Integer alunoId);

    // Soma de pontos gamificados de um aluno
    @Query("SELECT COALESCE(SUM(t.pontosObtidos), 0) FROM TentativaGamificada t WHERE t.aluno.id = :alunoId")
    int sumPontosByAluno(@Param("alunoId") Integer alunoId);
    
    
}
