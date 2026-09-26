package edu.ifsp.teachstation.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "questoes")
public class Questao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    private String enunciado;
    
    private String tipo;
    
    private String dificuldade;
    
    private Integer pontos;

    @ManyToOne
    @JoinColumn(name = "area_id")
    private AreaConhecimento materia;

    @OneToMany(mappedBy = "questao", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OpcaoQuestao> opcoes = new ArrayList<>();

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getEnunciado() {
        return enunciado;
    }

    public void setEnunciado(String enunciado) {
        this.enunciado = enunciado;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getDificuldade() {
        return dificuldade;
    }

    public void setDificuldade(String dificuldade) {
        this.dificuldade = dificuldade;
    }

    public Integer getPontos() {
        return pontos;
    }

    public void setPontos(Integer pontos) {
        this.pontos = pontos;
    }

    public AreaConhecimento getMateria() {
        return materia;
    }

    public void setMateria(AreaConhecimento materia) {
        this.materia = materia;
    }

    public List<OpcaoQuestao> getOpcoes() {
        return opcoes;
    }

    public void setOpcoes(List<OpcaoQuestao> opcoes) {
        this.opcoes = opcoes;
    }

    // Método para localizar a opção correta
    public OpcaoQuestao getOpcaoCorreta() {
        if (opcoes != null) {
            for (OpcaoQuestao opt : opcoes) {
                if (Boolean.TRUE.equals(opt.getCorreta())) {
                    return opt;
                }
            }
        }
        return null;
    }
}