package edu.ifsp.teachstation.persistence;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import edu.ifsp.teachstation.model.OpcaoQuestao;

@Repository
public interface OpcaoQuestaoRepository extends JpaRepository<OpcaoQuestao, Integer> {
    List<OpcaoQuestao> findByQuestaoId(Integer questaoId);
}