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

import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.persistence.UserRepository;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/usuario")
public class UsuarioController {
    
    @Autowired
    private UserRepository repo;
    
    @GetMapping("/novo")
    public String iniciar(Model model) {
        model.addAttribute("usuario", new Usuario());
        return "usuario/editar";
    }
    
    @PostMapping("/salvar")
    public String salvar(@Valid Usuario usuario, Errors errors) {
        if (errors.hasErrors()) {
            for (var e : errors.getAllErrors()) {
                System.out.println(e);
            }
            return "usuario/editar";
        }
        
        System.out.println("UsuarioController.salvar()");
        repo.save(usuario);
        return "redirect:/usuario/" + usuario.getId() + "/editar";
    }
    
    @GetMapping("/{id}/editar")
    public String editar(@PathVariable(name = "id") Integer id, Model model) {
        Usuario usuario = repo.findById(id).get();
        model.addAttribute("usuario", usuario);
        return "usuario/editar";
    }
    
    @GetMapping("/listar")
    public String listar(Model model) {
        Iterable<Usuario> usuarios = repo.findAll();
        model.addAttribute("usuarios", usuarios);
        return "usuario/listar";
    }
    
    @PostMapping("/{id}/excluir")
    public String excluir(
            @PathVariable(name = "id") Integer id,
            RedirectAttributes redirectAttributes
            ) {
        
        repo.deleteById(id);
        redirectAttributes.addFlashAttribute("deleteOk", id);
        
        return "redirect:/usuario/listar";
    }
}
