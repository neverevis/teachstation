package edu.ifsp.teachstation.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.persistence.AlunoRepository;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/aluno")
public class AlunoController {
    
    @Autowired
    private AlunoRepository repo;
    
    @GetMapping("/novo")
    public String iniciar(Model model) {
        model.addAttribute("aluno", new Aluno());
        return "aluno/editar";
    }
    
    @PostMapping("/salvar")
    public String salvar(@Valid Aluno aluno, Errors errors) {
        if (errors.hasErrors()) {
            for (var e : errors.getAllErrors()) {
                System.out.println(e);
            }
            return "aluno/editar";
        }
        
        System.out.println("AlunoController.salvar()");
        repo.save(aluno);
        return "redirect:/aluno/" + aluno.getId() + "/editar";
    }
    
    @GetMapping("/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Aluno aluno = repo.findById(id).get();
        model.addAttribute("aluno", aluno);
        return "aluno/editar";
    }
    
    @GetMapping("/listar")
    public String listar(Model model) {
        Iterable<Aluno> alunos = repo.findAll();
        model.addAttribute("alunos", alunos);
        return "aluno/listar";
    }
    
    @PostMapping("/{id}/excluir")
    public String excluir(
            @PathVariable(name = "id") Integer id,
            RedirectAttributes redirectAttributes
            ) {
        
        repo.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        
        return "redirect:/aluno/listar";
    }
}
