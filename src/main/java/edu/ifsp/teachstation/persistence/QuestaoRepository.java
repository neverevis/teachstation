package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.Questao;

@Repository
public interface QuestaoRepository extends JpaRepository<Questao, Integer> {

    // Busca todas as questões de uma área do conhecimento
    List<Questao> findByMateriaId(Integer areaId);

    // Busca questões filtradas por nível de dificuldade
    List<Questao> findByDificuldade(String dificuldade);

    // Consulta para carregar as 10 questões da Avaliação Diagnóstica de Língua Portuguesa
    @Query(value = "SELECT * FROM questoes WHERE area_id = :areaId ORDER BY id ASC", nativeQuery = true)
    List<Questao> findQuestoesDiagnosticasByArea(@Param("areaId") Integer areaId);
}