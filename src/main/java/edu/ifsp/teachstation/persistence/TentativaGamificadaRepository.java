package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.TentativaGamificada;

@Repository
public interface TentativaGamificadaRepository extends JpaRepository<TentativaGamificada, Integer> {

    // Todas as tentativas de um aluno em uma rodada de uma fase (no nível dele), na ordem em que foram feitas
    @Query("SELECT t FROM TentativaGamificada t "
            + "WHERE t.aluno.id = :alunoId AND t.rodada = :rodada AND t.questaoGamificada.fase = :fase "
            + "AND t.questaoGamificada.nivelDificuldade = :nivel ORDER BY t.id ASC")
    List<TentativaGamificada> findDaRodada(@Param("alunoId") Integer alunoId, @Param("rodada") Integer rodada,
                                           @Param("fase") Integer fase, @Param("nivel") String nivel);

    // Última rodada jogada pelo aluno na fase, no nível dele (0 se nunca jogou)
    @Query("SELECT COALESCE(MAX(t.rodada), 0) FROM TentativaGamificada t "
            + "WHERE t.aluno.id = :alunoId AND t.questaoGamificada.fase = :fase "
            + "AND t.questaoGamificada.nivelDificuldade = :nivel")
    Integer findUltimaRodada(@Param("alunoId") Integer alunoId, @Param("fase") Integer fase,
                             @Param("nivel") String nivel);
}
