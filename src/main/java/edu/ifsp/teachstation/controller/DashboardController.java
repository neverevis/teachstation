package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.service.DashboardService;
import edu.ifsp.teachstation.service.dto.AlunoProgresso;
import edu.ifsp.teachstation.service.dto.NivelContagem;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Comparator;
import java.util.List;

@Controller
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model, HttpSession session) {

        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
        if (usuarioLogado == null) {
            return "redirect:/login";
        }

        String perfil = usuarioLogado.getTipoUsuario().toLowerCase();

        // ---- dados que já existiam ----
        model.addAttribute("perfil", perfil);
        model.addAttribute("resumo", dashboardService.montarResumo());
        List<AlunoProgresso> alunos = dashboardService.montarListaAlunos();
        model.addAttribute("alunos", alunos);
        model.addAttribute("distribuicaoNiveis", dashboardService.montarDistribuicaoNiveis());
        model.addAttribute("avaliacoes", dashboardService.ultimasAvaliacoes());

        // ---- dados para os gráficos ----

        // Top 5 alunos por acertos (para o gráfico de barras horizontais)
        List<AlunoProgresso> topAlunos = alunos.stream()
                .sorted(Comparator.comparingInt(AlunoProgresso::getAcertos).reversed())
                .limit(5)
                .toList();
        model.addAttribute("topAlunos", topAlunos);

        // Distribuição como lista (só texto e número), para o JS ler fácil
        List<NivelContagem> dist = dashboardService.montarDistribuicaoNiveis();
        model.addAttribute("chartLabels", dist.stream().map(NivelContagem::getNivel).toList());
        model.addAttribute("chartValores", dist.stream().map(NivelContagem::getQuantidade).toList());

        // Nome do usuário
        model.addAttribute("nomeUsuario",
                usuarioLogado.getNomeSocial() != null && !usuarioLogado.getNomeSocial().isBlank()
                        ? usuarioLogado.getNomeSocial()
                        : usuarioLogado.getNomeCompleto());

        return "dashboard";
    }
}