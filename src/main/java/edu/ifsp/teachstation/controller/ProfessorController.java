package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Professor;
import edu.ifsp.teachstation.persistence.ProfessorRepository;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.sql.Date;

@Controller
public class ProfessorController {

    private final ProfessorRepository professorRepository;

    public ProfessorController(ProfessorRepository professorRepository) {
        this.professorRepository = professorRepository;
    }

    @GetMapping("/cadastro/professor")
    public String cadastroProfessor() {
        return "cadastro-professor";
    }

    @PostMapping("/cadastro/professor")
    public String cadastrarProfessor(
            @RequestParam("nome") String nome,
            @RequestParam("prontuario") String prontuario,
            @RequestParam("data-nascimento") String dataNascimento,
            @RequestParam("email") String email,
            @RequestParam("telefone") String telefone,
            @RequestParam("genero") String genero,
            @RequestParam("nome-social") String nomeSocial,
            @RequestParam("senha") String senha,
            @RequestParam("confirmar-senha") String confirmarSenha
    ) {

        if (!senha.equals(confirmarSenha)) {
            return "redirect:/cadastro/professor";
        }

        Professor professor = new Professor();

        professor.setNomeCompleto(nome);
        professor.setProntuario(prontuario);
        professor.setDataNascimento(Date.valueOf(dataNascimento));
        professor.setEmail(email);
        professor.setTelefone(telefone);
        professor.setGenero(genero);
        professor.setNomeSocial(nomeSocial);
        professor.setSenha(senha);

        professor.setTipoUsuario("PROFESSOR");
        professor.setDataCadastro(new java.util.Date());

        professorRepository.save(professor);

        return "redirect:/cadastro/professor";
    }
}