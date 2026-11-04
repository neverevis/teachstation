package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.service.DashboardService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class ProgressoAlunoController {

    private final DashboardService dashboardService;

    public ProgressoAlunoController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    // tela de progresso de um aluno especifico (acesso liberado so para professor e secretaria no SecurityConfig)
    @GetMapping("/dashboard/aluno/{id}")
    public String progresso(@PathVariable Integer id, Model model) {
        Aluno aluno = dashboardService.buscarAluno(id);
        if (aluno == null) {
            return "redirect:/dashboard";
        }

        model.addAttribute("progresso", dashboardService.montarProgresso(aluno));
        model.addAttribute("avaliacao", dashboardService.buscarAvaliacao(id).orElse(null));
        model.addAttribute("tentativasDiagnosticas", dashboardService.historicoDiagnostico(id));
        model.addAttribute("tentativasGamificadas", dashboardService.historicoGamificado(id));

        return "progresso-aluno";
    }
}
