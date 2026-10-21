package edu.ifsp.teachstation.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import edu.ifsp.teachstation.model.Professor;
import edu.ifsp.teachstation.persistence.ProfessorRepository;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/professor")
public class ProfessorController {

    @Autowired
    private ProfessorRepository repo;

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
        Professor professor = new Professor();
        professor.setTipoUsuario("PROFESSOR");
        model.addAttribute("professor", professor);
        return "professor/editar";
    }

    @PostMapping("/salvar")
    public String salvar(@Valid @ModelAttribute("professor") Professor professor, BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        if (professor.getId() != null) {
            Professor existente = repo.findById(professor.getId()).orElse(null);
            if (existente != null) {
                if (professor.getSenha() == null || professor.getSenha().trim().isEmpty()) {
                    professor.setSenha(existente.getSenha());
                } else {
                    professor.setSenha(passwordEncoder.encode(professor.getSenha()));
                }
                if (professor.getDataCadastro() == null) {
                    professor.setDataCadastro(existente.getDataCadastro());
                }
            }
        } else {
            if (professor.getSenha() == null || professor.getSenha().trim().isEmpty()) {
                bindingResult.rejectValue("senha", "NotBlank", "A senha é obrigatória.");
            } else {
                professor.setSenha(passwordEncoder.encode(professor.getSenha()));
            }
            if (professor.getDataCadastro() == null) {
                professor.setDataCadastro(new Date());
            }
        }

        professor.setTipoUsuario("PROFESSOR");

        boolean hasOtherErrors = bindingResult.getFieldErrors().stream()
                .anyMatch(fe -> !(professor.getId() != null && fe.getField().equals("senha")));

        if (hasOtherErrors) {
            return "professor/editar";
        }

        repo.save(professor);
        redirectAttributes.addFlashAttribute("mensagemSucesso", "Professor salvo com sucesso!");
        return "redirect:/professor/listar";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Professor professor = repo.findById(id).orElse(null);
        if (professor == null) {
            return "redirect:/professor/listar";
        }
        professor.setSenha("");
        model.addAttribute("professor", professor);
        return "professor/editar";
    }

    @GetMapping("/listar")
    public String listar(@RequestParam(name = "busca", required = false) String busca, Model model) {
        List<Professor> professores;
        if (busca != null && !busca.trim().isEmpty()) {
            professores = repo.pesquisar(busca.trim());
        } else {
            professores = repo.findAll();
        }
        model.addAttribute("professores", professores);
        model.addAttribute("busca", busca);
        return "professor/listar";
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable(name = "id") Integer id, RedirectAttributes redirectAttributes) {
        repo.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        return "redirect:/professor/listar";
    }
}