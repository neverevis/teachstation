package edu.ifsp.teachstation.service.dto;

/**
 * Um "nível" e quantos alunos estão nele.
 * Usado para montar o gráfico de barras de distribuição por nível.
 */
public class NivelContagem {

    private String nivel;      // INICIANTE, INTERMEDIARIO, AVANCADO ou SEM NIVEL
    private long quantidade;   // quantos alunos
    private double percentual; // % em relação ao total (para desenhar a barra)

    public NivelContagem(String nivel, long quantidade, double percentual) {
        this.nivel = nivel;
        this.quantidade = quantidade;
        this.percentual = percentual;
    }

    public String getNivel() { 
    	return nivel; 
    }
    
    public long getQuantidade() { 
    	return quantidade; 
    }
    
    public double getPercentual() { 
    	return percentual; 
    }
}