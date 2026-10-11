package edu.ifsp.teachstation.model;

import java.util.Date;
import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "atividades")
public class Atividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    private Date dataTentativa;
    
    private Integer acertos;
    
    private float pontosObtidos;
    
    // Getters e Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Date getDataTentativa() {
        return dataTentativa;
    }

    public void setDataTentativa(Date dataTentativa) {
        this.dataTentativa = dataTentativa;
    }

    public Integer getAcertos() {
        return acertos;
    }

    public void setAcertos(Integer acertos) {
        this.acertos = acertos;
    }

    public float getPontosObtidos() {
        return pontosObtidos;
    }

    public void setPontosObtidos(float pontosObtidos) {
        this.pontosObtidos = pontosObtidos;
    }
}