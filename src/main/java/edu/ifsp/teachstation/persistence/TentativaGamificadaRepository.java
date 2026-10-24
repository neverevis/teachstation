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
}
