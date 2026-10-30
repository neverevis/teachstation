package edu.ifsp.teachstation.model;

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
@Table(name = "questoes_gamificadas", uniqueConstraints = @UniqueConstraint(
        name = "uk_questoes_gamificadas_fase_nivel_ordem", columnNames = {"fase", "nivel_dificuldade", "ordem"}))
public class QuestaoGamificada {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Questão original em `questoes`, quando houver correspondência (pode ser nula)
    @ManyToOne
    @JoinColumn(name = "questao_id")
    private Questao questao;

    @ManyToOne
    @JoinColumn(name = "area_id", nullable = false)
    private AreaConhecimento materia;

    private Integer fase;

    private Integer ordem;

    // INICIANTE, INTERMEDIARIO ou AVANCADO: a mesma fase tem uma questão de cada nível
    // e o aluno só recebe as do nível definido na avaliação diagnóstica
    @Column(name = "nivel_dificuldade", nullable = false, length = 20,
            columnDefinition = "VARCHAR(20) NOT NULL DEFAULT 'INTERMEDIARIO'")
    private String nivelDificuldade = "INTERMEDIARIO";

    // ASSOCIACAO, PREENCHIMENTO ou MULTIPLA_ESCOLHA
    private String tipo;

    @Column(columnDefinition = "TEXT")
    private String enunciado;

    @Column(columnDefinition = "TEXT")
    private String textoApoio;

    // Parte exibida ao aluno (sem gabarito)
    @Column(columnDefinition = "TEXT")
    private String conteudoJson;

    // Respostas corretas: só o servidor lê até a questão ser resolvida
    @Column(columnDefinition = "TEXT")
    private String gabaritoJson;

    @Column(columnDefinition = "TEXT")
    private String explicacao;

    private Integer pontos;

    private String origem;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Questao getQuestao() {
        return questao;
    }

    public void setQuestao(Questao questao) {
        this.questao = questao;
    }

    public AreaConhecimento getMateria() {
        return materia;
    }

    public void setMateria(AreaConhecimento materia) {
        this.materia = materia;
    }

    public Integer getFase() {
        return fase;
    }

    public void setFase(Integer fase) {
        this.fase = fase;
    }

    public Integer getOrdem() {
        return ordem;
    }

    public void setOrdem(Integer ordem) {
        this.ordem = ordem;
    }

    public String getNivelDificuldade() {
        return nivelDificuldade;
    }

    public void setNivelDificuldade(String nivelDificuldade) {
        this.nivelDificuldade = nivelDificuldade;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getEnunciado() {
        return enunciado;
    }

    public void setEnunciado(String enunciado) {
        this.enunciado = enunciado;
    }

    public String getTextoApoio() {
        return textoApoio;
    }

    public void setTextoApoio(String textoApoio) {
        this.textoApoio = textoApoio;
    }

    public String getConteudoJson() {
        return conteudoJson;
    }

    public void setConteudoJson(String conteudoJson) {
        this.conteudoJson = conteudoJson;
    }

    public String getGabaritoJson() {
        return gabaritoJson;
    }

    public void setGabaritoJson(String gabaritoJson) {
        this.gabaritoJson = gabaritoJson;
    }

    public String getExplicacao() {
        return explicacao;
    }

    public void setExplicacao(String explicacao) {
        this.explicacao = explicacao;
    }

    public Integer getPontos() {
        return pontos;
    }

    public void setPontos(Integer pontos) {
        this.pontos = pontos;
    }

    public String getOrigem() {
        return origem;
    }

    public void setOrigem(String origem) {
        this.origem = origem;
    }
}
