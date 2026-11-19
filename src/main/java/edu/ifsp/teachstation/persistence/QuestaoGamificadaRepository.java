package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.QuestaoGamificada;

@Repository
public interface QuestaoGamificadaRepository extends JpaRepository<QuestaoGamificada, Integer> {
    List<QuestaoGamificada> findByFaseOrderByOrdemAsc(Integer fase);

    @Query("SELECT DISTINCT q.fase FROM QuestaoGamificada q ORDER BY q.fase")
    List<Integer> findFasesDisponiveis();

    // Versões por nível: cada aluno joga só as questões do seu nível
    List<QuestaoGamificada> findByNivelAndFaseOrderByOrdemAsc(String nivel, Integer fase);

    @Query("SELECT DISTINCT q.fase FROM QuestaoGamificada q WHERE q.nivel = :nivel ORDER BY q.fase")
    List<Integer> findFasesDisponiveisPorNivel(@Param("nivel") String nivel);

    boolean existsByNivel(String nivel);
}
