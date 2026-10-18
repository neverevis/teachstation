package edu.ifsp.teachstation.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "tentativas_gamificadas", uniqueConstraints = @UniqueConstraint(
        name = "uk_tentativas_gamificadas",
        columnNames = {"aluno_id", "questao_gamificada_id", "rodada", "numero_tentativa"}))
public class TentativaGamificada {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "aluno_id", nullable = false)
    private Aluno aluno;

    @ManyToOne
    @JoinColumn(name = "questao_gamificada_id", nullable = false)
    private QuestaoGamificada questaoGamificada;

    // Permite jogar a fase de novo sem apagar o histórico
    @Column(name = "rodada", nullable = false)
    private Integer rodada = 1;

    @Column(name = "numero_tentativa", nullable = false)
    private Integer numeroTentativa = 1;

    @Column(name = "resposta_json", columnDefinition = "TEXT", nullable = false)
    private String respostaJson;

    @Column(name = "acertou", nullable = false)
    private Boolean acertou;

    @Column(name = "pontos_obtidos", nullable = false)
    private Integer pontosObtidos = 0;

    @Column(name = "data_tentativa")
    private LocalDateTime dataTentativa;

    public TentativaGamificada() {
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Aluno getAluno() {
        return aluno;
    }

    public void setAluno(Aluno aluno) {
        this.aluno = aluno;
    }

    public QuestaoGamificada getQuestaoGamificada() {
        return questaoGamificada;
    }

    public void setQuestaoGamificada(QuestaoGamificada questaoGamificada) {
        this.questaoGamificada = questaoGamificada;
    }

    public Integer getRodada() {
        return rodada;
    }

    public void setRodada(Integer rodada) {
        this.rodada = rodada;
    }

    public Integer getNumeroTentativa() {
        return numeroTentativa;
    }

    public void setNumeroTentativa(Integer numeroTentativa) {
        this.numeroTentativa = numeroTentativa;
    }

    public String getRespostaJson() {
        return respostaJson;
    }

    public void setRespostaJson(String respostaJson) {
        this.respostaJson = respostaJson;
    }

    public Boolean getAcertou() {
        return acertou;
    }

    public void setAcertou(Boolean acertou) {
        this.acertou = acertou;
    }

    public Integer getPontosObtidos() {
        return pontosObtidos;
    }

    public void setPontosObtidos(Integer pontosObtidos) {
        this.pontosObtidos = pontosObtidos;
    }

    public LocalDateTime getDataTentativa() {
        return dataTentativa;
    }

    public void setDataTentativa(LocalDateTime dataTentativa) {
        this.dataTentativa = dataTentativa;
    }
}
