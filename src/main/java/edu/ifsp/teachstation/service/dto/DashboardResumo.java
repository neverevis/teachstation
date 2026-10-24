package edu.ifsp.teachstation.service.dto;

/**
 * Guarda os números gerais que aparecem nos cards do topo do dashboard.
 * É só uma "caixa" de dados: o Service preenche e o template lê.
 */
public class DashboardResumo {

    private long totalAlunos;
    private long totalProfessores;
    private long totalQuestoes;
    private long totalQuestoesGamificadas;
    private long avaliacoesRealizadas;
    private long tentativasDiagnosticas;
    private long tentativasGamificadas;
    private double mediaNotaDiagnostica;
    private double taxaAcertoDiagnostica;   // % de acertos nas tentativas diagnósticas
    private double taxaAcertoGamificada;    // % de acertos nas tentativas gamificadas

    // Getters e setters
    public long getTotalAlunos() { 
    	return totalAlunos; 
    }
    
    public void setTotalAlunos(long totalAlunos) { 
    	this.totalAlunos = totalAlunos; 
    }

    public long getTotalProfessores() { 
    	return totalProfessores; 
    }
    
    public void setTotalProfessores(long totalProfessores) { 
    	this.totalProfessores = totalProfessores; 
    }

    public long getTotalQuestoes() { 
    	return totalQuestoes; 
    }
    
    public void setTotalQuestoes(long totalQuestoes) { 
    	this.totalQuestoes = totalQuestoes; 
    }

    public long getTotalQuestoesGamificadas() { 
    	return totalQuestoesGamificadas; 
    }
    
    public void setTotalQuestoesGamificadas(long totalQuestoesGamificadas) { 
    	this.totalQuestoesGamificadas = totalQuestoesGamificadas; 
    }

    public long getAvaliacoesRealizadas() { 
    	return avaliacoesRealizadas; 
    }
    
    public void setAvaliacoesRealizadas(long avaliacoesRealizadas) { 
    	this.avaliacoesRealizadas = avaliacoesRealizadas; 
    }

    public long getTentativasDiagnosticas() { 
    	return tentativasDiagnosticas; 
    }
    
    public void setTentativasDiagnosticas(long tentativasDiagnosticas) { 
    	this.tentativasDiagnosticas = tentativasDiagnosticas; 
    }

    public long getTentativasGamificadas() { 
    	return tentativasGamificadas; 
    }
    
    public void setTentativasGamificadas(long tentativasGamificadas) { 
    	this.tentativasGamificadas = tentativasGamificadas; 
    }

    public double getMediaNotaDiagnostica() { 
    	return mediaNotaDiagnostica; 
    }
    
    public void setMediaNotaDiagnostica(double mediaNotaDiagnostica) { 
    	this.mediaNotaDiagnostica = mediaNotaDiagnostica; 
    }

    public double getTaxaAcertoDiagnostica() { 
    	return taxaAcertoDiagnostica; 
    }
    
    public void setTaxaAcertoDiagnostica(double taxaAcertoDiagnostica) { 
    	this.taxaAcertoDiagnostica = taxaAcertoDiagnostica; 
    }

    public double getTaxaAcertoGamificada() { 
    	return taxaAcertoGamificada; 
    }
    
    public void setTaxaAcertoGamificada(double taxaAcertoGamificada) { 
    	this.taxaAcertoGamificada = taxaAcertoGamificada; 
    }
}