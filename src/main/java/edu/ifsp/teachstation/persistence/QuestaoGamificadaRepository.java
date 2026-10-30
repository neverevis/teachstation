package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.QuestaoGamificada;

@Repository
public interface QuestaoGamificadaRepository extends JpaRepository<QuestaoGamificada, Integer> {

    // Questões de uma fase no nível de dificuldade do aluno, na ordem em que aparecem no quiz
    List<QuestaoGamificada> findByFaseAndNivelDificuldadeOrderByOrdemAsc(Integer fase, String nivelDificuldade);

    // Números das fases que têm ao menos uma questão naquele nível (o mapa usa para liberar ou bloquear as fases)
    @Query("SELECT DISTINCT q.fase FROM QuestaoGamificada q WHERE q.nivelDificuldade = :nivel ORDER BY q.fase")
    List<Integer> findFasesDisponiveis(@Param("nivel") String nivel);
}
