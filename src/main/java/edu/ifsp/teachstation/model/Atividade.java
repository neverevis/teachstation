package edu.ifsp.teachstation.model;

import java.sql.Date;
import java.util.List;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

public class Atividade {

	
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
	
	private Date dataTentativa;
	
	private Integer acertos;
	
	private float pontosObtidos;
	
	private List<Questao> questoes;
	
	
	public float calcularPontos() {

		float total = 0;
		for (Questao questao : questoes) {
			total += questao.getPontos();
		}
		
		return total;
	}
	
	public boolean calculoAvanco() {
		
		if(calcularPontos() >= 70) {
			return true;
		}else {
			return false;
		}
	}
	
	
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
