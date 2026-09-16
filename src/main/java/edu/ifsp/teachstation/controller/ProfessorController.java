package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ProfessorController {

    @GetMapping("/cadastro/professor")
    public String cadastroProfessor() {
        return "cadastro-professor";
    }
}