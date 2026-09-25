package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.persistence.AlunoRepository;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.sql.Date;

@Controller
public class SignUpController {

    private final AlunoRepository alunoRepository;

    public SignUpController(AlunoRepository alunoRepository) {
        this.alunoRepository = alunoRepository;
    }

    @GetMapping("/cadastro/aluno")
    public String signup() {
        return "cadastro-aluno";
    }

    @PostMapping("/signup")
    public String cadastrarAluno(
            @RequestParam("nome") String nome,
            @RequestParam("ra") String ra,
            @RequestParam("data-nascimento") String dataNascimento,
            @RequestParam("email") String email,
            @RequestParam("telefone-responsavel") String telefoneResponsavel,
            @RequestParam("genero") String genero,
            @RequestParam("nome-social") String nomeSocial,
            @RequestParam("senha") String senha,
            @RequestParam("confirmar-senha") String confirmarSenha
    ) {

        if (!senha.equals(confirmarSenha)) {
            return "redirect:/cadastro/aluno";
        }

        Aluno aluno = new Aluno();

        aluno.setNomeCompleto(nome);
        aluno.setRa(ra);
        aluno.setDataNascimento(Date.valueOf(dataNascimento));
        aluno.setEmail(email);
        aluno.setTelefoneResponsavel(telefoneResponsavel);
        aluno.setGenero(genero);
        aluno.setNomeSocial(nomeSocial);
        aluno.setSenha(senha);

        aluno.setTipoUsuario("ALUNO");
        aluno.setDataCadastro(new java.util.Date());

        alunoRepository.save(aluno);

        return "redirect:/cadastro/aluno";
    }
}