package edu.ifsp.teachstation.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import edu.ifsp.teachstation.model.Professor;
import edu.ifsp.teachstation.persistence.ProfessorRepository;
import jakarta.validation.Valid;

@Controller
public class ProfessorController {

    @Autowired
    private ProfessorRepository repo;

    @GetMapping("/cadastro/professor")
    public String cadastroProfessor() {
        return "cadastro-professor";
    }

    @GetMapping("/professor/novo")
    public String iniciar(Model model) {
        model.addAttribute("professor", new Professor());
        return "professor/editar";
    }
    
    @PostMapping("/professor/salvar")
    public String salvar(@Valid Professor professor, Errors errors) {
        if (errors.hasErrors()) {
            for (var e : errors.getAllErrors()) {
                System.out.println(e);
            }
            return "professor/editar";
        }
        
        System.out.println("ProfessorController.salvar()");
        repo.save(professor);
        return "redirect:/professor/" + professor.getId() + "/editar";
    }
    
    @GetMapping("/professor/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Professor professor = repo.findById(id).get();
        model.addAttribute("professor", professor);
        return "professor/editar";
    }
    
    @GetMapping("/professor/listar")
    public String listar(Model model) {
        Iterable<Professor> professores = repo.findAll();
        model.addAttribute("professores", professores);
        return "professor/listar";
    }
    
    @PostMapping("/professor/{id}/excluir")
    public String excluir(
            @PathVariable(name = "id") Integer id,
            RedirectAttributes redirectAttributes
            ) {
        
        repo.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        
        return "redirect:/professor/listar";
    }
}