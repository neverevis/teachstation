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
@Table(name = "avaliacao_diagnostica")
public class AvaliacaoDiagnostica {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "aluno_id", nullable = false)
    private Aluno aluno;

    @Column(name = "data_avaliacao", insertable = false, updatable = false)
    private LocalDateTime dataAvaliacao;

    @Column(name = "nota_final")
    private Float notaFinal;

    @Column(name = "nivel_classificado")
    private String nivelClassificado; // 'INICIANTE', 'INTERMEDIARIO', 'AVANCADO'

    public AvaliacaoDiagnostica() {
    }

    public AvaliacaoDiagnostica(Aluno aluno, Float notaFinal, String nivelClassificado) {
        this.aluno = aluno;
        this.notaFinal = notaFinal;
        this.nivelClassificado = nivelClassificado;
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

    public LocalDateTime getDataAvaliacao() {
        return dataAvaliacao;
    }

    public void setDataAvaliacao(LocalDateTime dataAvaliacao) {
        this.dataAvaliacao = dataAvaliacao;
    }

    public Float getNotaFinal() {
        return notaFinal;
    }

    public void setNotaFinal(Float notaFinal) {
        this.notaFinal = notaFinal;
    }

    public String getNivelClassificado() {
        return nivelClassificado;
    }

    public void setNivelClassificado(String nivelClassificado) {
        this.nivelClassificado = nivelClassificado;
    }
}