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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.persistence.AlunoRepository;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/aluno")
public class AlunoController {

    @Autowired
    private AlunoRepository repo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        dateFormat.setLenient(false);
        binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
    }

    @GetMapping("/novo")
    public String iniciar(Model model) {
        Aluno aluno = new Aluno();
        aluno.setTipoUsuario("ALUNO");
        aluno.setNivelAtual("INICIANTE");
        model.addAttribute("aluno", aluno);
        return "aluno/editar";
    }

    @PostMapping("/salvar")
    public String salvar(
            @Valid @ModelAttribute("aluno") Aluno aluno,
            BindingResult errors,
            Model model,
            RedirectAttributes redirectAttributes) {

        String senhaInformada = aluno.getSenha();

        if (aluno.getId() != null) {
            Aluno existente = repo.findById(aluno.getId()).orElse(null);
            if (existente != null) {
                if (senhaInformada == null || senhaInformada.trim().isEmpty()) {
                    aluno.setSenha(existente.getSenha());
                } else {
                    aluno.setSenha(passwordEncoder.encode(senhaInformada));
                }
                if (aluno.getDataCadastro() == null) {
                    aluno.setDataCadastro(existente.getDataCadastro());
                }
                if (aluno.getNivelAtual() == null || aluno.getNivelAtual().trim().isEmpty()) {
                    aluno.setNivelAtual(existente.getNivelAtual());
                }
            }
        } else {
            if (senhaInformada == null || senhaInformada.trim().isEmpty()) {
                if (!errors.hasFieldErrors("senha")) {
                    errors.rejectValue("senha", "NotBlank", "A senha é obrigatória.");
                }
            } else {
                aluno.setSenha(passwordEncoder.encode(senhaInformada));
            }
            if (aluno.getDataCadastro() == null) {
                aluno.setDataCadastro(new Date());
            }
        }

        if (aluno.getNivelAtual() != null && aluno.getNivelAtual().trim().isEmpty()) {
            aluno.setNivelAtual(null);
        }

        aluno.setTipoUsuario("ALUNO");

        boolean possuiErros = errors.getFieldErrors().stream()
                .anyMatch(fe -> !fe.getField().equals("tipoUsuario")
                        && !(aluno.getId() != null && fe.getField().equals("senha")));

        if (possuiErros) {
            for (var e : errors.getAllErrors()) {
                System.out.println(e);
            }
            aluno.setSenha("");
            return "aluno/editar";
        }

        try {
            System.out.println("AlunoController.salvar()");
            repo.save(aluno);
            redirectAttributes.addFlashAttribute("mensagemSucesso", "Aluno salvo com sucesso!");
            redirectAttributes.addFlashAttribute("mensagem", "Aluno salvo com sucesso!");
            redirectAttributes.addFlashAttribute("tipoMensagem", "sucesso");
            return "redirect:/aluno/listar";
        } catch (DataAccessException e) {
            aluno.setSenha("");
            model.addAttribute("mensagem", "Não foi possível salvar o aluno. Verifique se o RA ou e-mail já estão cadastrados.");
            model.addAttribute("tipoMensagem", "erro");
            return "aluno/editar";
        }
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Aluno aluno = repo.findById(id).orElse(null);
        if (aluno == null) {
            return "redirect:/aluno/listar";
        }
        aluno.setSenha("");
        model.addAttribute("aluno", aluno);
        return "aluno/editar";
    }

    @GetMapping("/listar")
    public String listar(@RequestParam(name = "busca", required = false) String busca, Model model) {
        List<Aluno> alunos;
        if (busca != null && !busca.trim().isEmpty()) {
            alunos = repo.pesquisar(busca.trim());
        } else {
            alunos = repo.findAll();
        }
        model.addAttribute("alunos", alunos);
        model.addAttribute("busca", busca);
        return "aluno/listar";
    }

    @PostMapping("/{id}/excluir")
    public String excluir(
            @PathVariable(name = "id") Integer id,
            RedirectAttributes redirectAttributes) {
        repo.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        redirectAttributes.addFlashAttribute("mensagem", "Aluno ID " + id + " excluído com sucesso!");
        redirectAttributes.addFlashAttribute("tipoMensagem", "sucesso");
        return "redirect:/aluno/listar";
    }
}
