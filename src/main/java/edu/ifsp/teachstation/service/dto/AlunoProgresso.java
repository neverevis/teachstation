package edu.ifsp.teachstation.service.dto;

/**
 * Linha da tabela de alunos no dashboard.
 * Junta os dados do aluno com o progresso dele nas atividades.
 */
public class AlunoProgresso {

    private Integer id;
    private String ra;
    private String nome;
    private String email;
    private String telefoneResponsavel;
    private Integer idade;
    private String nivelAtual;
    private int progressoNivel;        // 0 a 100 (para a barra)
    private int pontosDiagnosticos;    // soma de pontos nas tentativas diagnósticas
    private int pontosGamificados;     // soma de pontos nas tentativas gamificadas
    private int acertos;               // total de acertos (diagnóstica + gamificada)
    private int totalTentativas;       // total de tentativas (diagnóstica + gamificada)
    private double taxaAcerto;         // % (acertos / tentativas)
    private boolean fezDiagnostica;

    // Getters e setters
    public Integer getId() { 
    	return id; 
    }
    
    public void setId(Integer id) { 
    	this.id = id; 
    }

    public String getRa() { 
    	return ra; 
    }
    
    public void setRa(String ra) { 
    	this.ra = ra; 
    }

    public String getNome() { 
    	return nome; 
    }
    
    public void setNome(String nome) { 
    	this.nome = nome; 
    }

    public String getEmail() { 
    	return email; 
    }
    
    public void setEmail(String email) { 
    	this.email = email; 
    }

    public String getTelefoneResponsavel() { 
    	return telefoneResponsavel; 
    }
    
    public void setTelefoneResponsavel(String telefoneResponsavel) { 
    	this.telefoneResponsavel = telefoneResponsavel; 
    }

    public Integer getIdade() { 
    	return idade; 
    }
    
    public void setIdade(Integer idade) { 
    	this.idade = idade; 
    }

    public String getNivelAtual() { 
    	return nivelAtual; 
    }
    
    public void setNivelAtual(String nivelAtual) { 
    	this.nivelAtual = nivelAtual; 
    }

    public int getProgressoNivel() { 
    	return progressoNivel; 
    }
    
    public void setProgressoNivel(int progressoNivel) { 
    	this.progressoNivel = progressoNivel; 
    }

    public int getPontosDiagnosticos() { 
    	return pontosDiagnosticos; 
    }
    
    public void setPontosDiagnosticos(int pontosDiagnosticos) { 
    	this.pontosDiagnosticos = pontosDiagnosticos; 
    }

    public int getPontosGamificados() { 
    	return pontosGamificados; 
    }
    
    public void setPontosGamificados(int pontosGamificados) { 
    	this.pontosGamificados = pontosGamificados; 
    }

    public int getAcertos() { 
    	return acertos; 
    }
    
    public void setAcertos(int acertos) { 
    	this.acertos = acertos; 
    }

    public int getTotalTentativas() { 
    	return totalTentativas; 
    }
    
    public void setTotalTentativas(int totalTentativas) { 
    	this.totalTentativas = totalTentativas; 
    }

    public double getTaxaAcerto() { 
    	return taxaAcerto; 
    }
    
    public void setTaxaAcerto(double taxaAcerto) { 
    	this.taxaAcerto = taxaAcerto; 
    }

    public boolean isFezDiagnostica() { 
    	return fezDiagnostica; 
    }
    
    public void setFezDiagnostica(boolean fezDiagnostica) { 
    	this.fezDiagnostica = fezDiagnostica; 
    }
}