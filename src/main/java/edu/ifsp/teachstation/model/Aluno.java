package edu.ifsp.teachstation.model;

import java.time.Instant;
import java.time.LocalDate;
import java.time.Period;
import java.time.ZoneId;

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

    // calcula a idade a partir da data de nascimento (o banco pode devolver java.sql.Date, por isso o getTime)
    public Integer getIdade() {
        if (getDataNascimento() == null) {
            return null;
        }
        LocalDate nascimento = Instant.ofEpochMilli(getDataNascimento().getTime())
                .atZone(ZoneId.systemDefault())
                .toLocalDate();
        return Period.between(nascimento, LocalDate.now()).getYears();
    }

    // largura da barra de progresso de acordo com o nivel
    public int getProgressoNivel() {
        if (nivelAtual == null) {
            return 0;
        }
        switch (nivelAtual) {
            case "INICIANTE": return 33;
            case "INTERMEDIARIO": return 66;
            case "AVANCADO": return 100;
            default: return 0;
        }
    }
}
