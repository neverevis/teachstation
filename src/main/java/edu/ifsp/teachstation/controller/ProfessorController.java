package edu.ifsp.teachstation.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.dao.DataAccessException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import edu.ifsp.teachstation.model.Professor;
import edu.ifsp.teachstation.persistence.ProfessorRepository;
import jakarta.validation.Valid;

@Controller
public class ProfessorController {

    private final ProfessorRepository professorRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public ProfessorController(ProfessorRepository professorRepository, PasswordEncoder passwordEncoder) {
        this.professorRepository = professorRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        dateFormat.setLenient(false);
        binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
    }

    @GetMapping("/professor/novo")
    public String iniciar(Model model) {
        Professor professor = new Professor();
        professor.setTipoUsuario("PROFESSOR");
        model.addAttribute("professor", professor);
        return "professor/editar";
    }

    @PostMapping("/professor/salvar")
    public String salvar(
            @Valid @ModelAttribute("professor") Professor professor,
            BindingResult errors,
            Model model,
            RedirectAttributes redirectAttributes) {

        String senhaInformada = professor.getSenha();

        if (professor.getId() != null) {
            Professor existente = professorRepository.findById(professor.getId()).orElse(null);
            if (existente != null) {
                if (senhaInformada == null || senhaInformada.trim().isEmpty()) {
                    professor.setSenha(existente.getSenha());
                } else {
                    professor.setSenha(passwordEncoder.encode(senhaInformada));
                }
                if (professor.getDataCadastro() == null) {
                    professor.setDataCadastro(existente.getDataCadastro());
                }
            }
        } else {
            if (senhaInformada == null || senhaInformada.trim().isEmpty()) {
                if (!errors.hasFieldErrors("senha")) {
                    errors.rejectValue("senha", "NotBlank", "A senha é obrigatória.");
                }
            } else {
                professor.setSenha(passwordEncoder.encode(senhaInformada));
            }
            if (professor.getDataCadastro() == null) {
                professor.setDataCadastro(new Date());
            }
        }

        professor.setTipoUsuario("PROFESSOR");

        boolean possuiErros = errors.getFieldErrors().stream()
                .anyMatch(fe -> !fe.getField().equals("tipoUsuario")
                        && !(professor.getId() != null && fe.getField().equals("senha")));

        if (possuiErros) {
            for (var e : errors.getAllErrors()) {
                System.out.println(e);
            }
            professor.setSenha("");
            return "professor/editar";
        }

        try {
            System.out.println("ProfessorController.salvar()");
            professorRepository.save(professor);
            redirectAttributes.addFlashAttribute("mensagemSucesso", "Professor salvo com sucesso!");
            redirectAttributes.addFlashAttribute("mensagem", "Professor salvo com sucesso!");
            redirectAttributes.addFlashAttribute("tipoMensagem", "sucesso");
            return "redirect:/professor/listar";
        } catch (DataAccessException e) {
            professor.setSenha("");
            model.addAttribute("mensagem", "Não foi possível salvar o professor. Verifique se o prontuário ou e-mail já estão cadastrados.");
            model.addAttribute("tipoMensagem", "erro");
            return "professor/editar";
        }
    }

    @GetMapping("/professor/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Professor professor = professorRepository.findById(id).orElse(null);
        if (professor == null) {
            return "redirect:/professor/listar";
        }
        professor.setSenha("");
        model.addAttribute("professor", professor);
        return "professor/editar";
    }

    @GetMapping("/professor/listar")
    public String listar(@RequestParam(name = "busca", required = false) String busca, Model model) {
        List<Professor> professores;
        if (busca != null && !busca.trim().isEmpty()) {
            professores = professorRepository.pesquisar(busca.trim());
        } else {
            professores = professorRepository.findAll();
        }
        model.addAttribute("professores", professores);
        model.addAttribute("busca", busca);
        return "professor/listar";
    }

    @PostMapping("/professor/{id}/excluir")
    public String excluir(
            @PathVariable(name = "id") Integer id,
            RedirectAttributes redirectAttributes) {
        professorRepository.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        redirectAttributes.addFlashAttribute("mensagem", "Professor ID " + id + " excluído com sucesso!");
        redirectAttributes.addFlashAttribute("tipoMensagem", "sucesso");
        return "redirect:/professor/listar";
    }

    @GetMapping("/cadastro/professor")
    public String cadastroProfessor(
            @RequestParam(value = "erro", required = false) String erro,
            @RequestParam(value = "sucesso", required = false) String sucesso,
            Model model) {

        if (erro != null) {
            if (erro.equals("senha")) {
                model.addAttribute("mensagem", "As senhas não coincidem.");
            } else {
                model.addAttribute(
                    "mensagem",
                    "Não foi possível cadastrar o professor. Verifique os dados."
                );
            }

            model.addAttribute("tipoMensagem", "erro");
        }

        if (sucesso != null) {
            model.addAttribute(
                "mensagem",
                "Professor cadastrado com sucesso!"
            );

            model.addAttribute("tipoMensagem", "sucesso");
        }

        return "cadastro-professor";
    }

    @PostMapping("/cadastro/professor")
    public String cadastrarProfessor(
            @RequestParam("nome") String nome,
            @RequestParam("prontuario") String prontuario,
            @RequestParam("data-nascimento") String dataNascimento,
            @RequestParam("email") String email,
            @RequestParam("telefone") String telefone,
            @RequestParam(value = "area-atuacao", required = false) String areaAtuacao,
            @RequestParam("genero") String genero,
            @RequestParam("nome-social") String nomeSocial,
            @RequestParam("senha") String senha,
            @RequestParam("confirmar-senha") String confirmarSenha
    ) {

        if (!senha.equals(confirmarSenha)) {
            return "redirect:/cadastro/professor?erro=senha";
        }

        Professor professor = new Professor();

        professor.setNomeCompleto(nome);
        professor.setProntuario(prontuario);
        professor.setDataNascimento(java.sql.Date.valueOf(dataNascimento));
        professor.setEmail(email);
        professor.setTelefone(telefone);
        professor.setAreaAtuacao(areaAtuacao);
        professor.setGenero(genero);
        professor.setNomeSocial(nomeSocial);
        professor.setSenha(passwordEncoder.encode(senha));

        professor.setTipoUsuario("PROFESSOR");
        professor.setDataCadastro(new java.util.Date());

        try {
            professorRepository.save(professor);
            return "redirect:/cadastro/professor?sucesso";
        } catch (DataAccessException e) {
            return "redirect:/cadastro/professor?erro=cadastro";
        }
    }
}
