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

@Entity
@Table(name = "tentativas_atividades")
public class TentativaAtividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "aluno_id", nullable = false)
    private Aluno aluno;

    @ManyToOne
    @JoinColumn(name = "questao_id", nullable = false)
    private Questao questao;

    @ManyToOne
    @JoinColumn(name = "opcao_selecionada_id")
    private OpcaoQuestao opcaoSelecionada;

    @Column(name = "data_tentativa")
    private LocalDateTime dataTentativa;

    @Column(name = "acertou", nullable = false)
    private Boolean acertou;

    @Column(name = "pontos_obtidos")
    private Integer pontosObtidos = 0;

    public TentativaAtividade() {
    }

    public TentativaAtividade(Aluno aluno, Questao questao, OpcaoQuestao opcaoSelecionada, Boolean acertou, Integer pontosObtidos) {
        this.aluno = aluno;
        this.questao = questao;
        this.opcaoSelecionada = opcaoSelecionada;
        this.acertou = acertou;
        this.pontosObtidos = pontosObtidos;
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

    public Questao getQuestao() {
        return questao;
    }

    public void setQuestao(Questao questao) {
        this.questao = questao;
    }

    public OpcaoQuestao getOpcaoSelecionada() {
        return opcaoSelecionada;
    }

    public void setOpcaoSelecionada(OpcaoQuestao opcaoSelecionada) {
        this.opcaoSelecionada = opcaoSelecionada;
    }

    public LocalDateTime getDataTentativa() {
        return dataTentativa;
    }

    public void setDataTentativa(LocalDateTime dataTentativa) {
        this.dataTentativa = dataTentativa;
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
}