package edu.ifsp.teachstation.model;

import jakarta.persistence.Entity;
import jakarta.validation.constraints.NotBlank;

@Entity
public class Aluno extends Usuario {

    @NotBlank
    private String ra;

    private String telefoneResponsavel;

    private String nivelAtual;

    public String getRa() { return ra; }
    public void setRa(String ra) { this.ra = ra; }

    public String getTelefoneResponsavel() { return telefoneResponsavel; }
    public void setTelefoneResponsavel(String telefoneResponsavel) { this.telefoneResponsavel = telefoneResponsavel; }

    public String getNivelAtual() { return nivelAtual; }
    public void setNivelAtual(String nivelAtual) { this.nivelAtual = nivelAtual; }
}
