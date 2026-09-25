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

import edu.ifsp.teachstation.model.Secretaria;
import edu.ifsp.teachstation.persistence.SecretariaRepository;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/secretaria")
public class SecretariaController {
    
    @Autowired
    private SecretariaRepository repo;
    
    @GetMapping("/novo")
    public String iniciar(Model model) {
        model.addAttribute("secretaria", new Secretaria());
        return "secretaria/editar";
    }
    
    @PostMapping("/salvar")
    public String salvar(@Valid Secretaria secretaria, Errors errors) {
        if (errors.hasErrors()) {
            for (var e : errors.getAllErrors()) {
                System.out.println(e);
            }
            return "secretaria/editar";
        }
        
        System.out.println("SecretariaController.salvar()");
        repo.save(secretaria);
        return "redirect:/secretaria/" + secretaria.getId() + "/editar";
    }
    
    @GetMapping("/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Secretaria secretaria = repo.findById(id).get();
        model.addAttribute("secretaria", secretaria);
        return "secretaria/editar";
    }
    
    @GetMapping("/listar")
    public String listar(Model model) {
        Iterable<Secretaria> secretarias = repo.findAll();
        model.addAttribute("secretarias", secretarias);
        return "secretaria/listar";
    }
    
    @PostMapping("/{id}/excluir")
    public String excluir(
            @PathVariable(name = "id") Integer id,
            RedirectAttributes redirectAttributes
            ) {
        
        repo.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        
        return "redirect:/secretaria/listar";
    }
}
