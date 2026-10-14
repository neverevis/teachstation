package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.OpcaoQuestao;
import edu.ifsp.teachstation.model.Questao;
import edu.ifsp.teachstation.model.TentativaAtividade;
import edu.ifsp.teachstation.persistence.QuestaoRepository;
import edu.ifsp.teachstation.persistence.TentativaAtividadeRepository;
import edu.ifsp.teachstation.service.NivelamentoService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/first-test")
public class FirstTestController {

    @Autowired
    private QuestaoRepository questaoRepository;

    @Autowired
    private TentativaAtividadeRepository tentativaRepository;

    @Autowired
    private NivelamentoService nivelamentoService;

    @GetMapping
    public String exibirQuestaoAtual(HttpSession session, Model model) {
        Aluno alunoLogado = (Aluno) session.getAttribute("alunoLogado");
        
        if (alunoLogado == null) {
            return "redirect:/login";
        }

        List<Questao> questoesDiagnosticas = questaoRepository.findQuestoesDiagnosticasByArea(1);
        List<TentativaAtividade> tentativasRealizadas = tentativaRepository.findByAlunoId(alunoLogado.getId());

        int indiceAtual = tentativasRealizadas.size();

        if (indiceAtual >= questoesDiagnosticas.size()) 
        {
            nivelamentoService.finalizarAvaliacao(alunoLogado);
            return "redirect:/studyarea";
        }

        Questao questaoAtual = questoesDiagnosticas.get(indiceAtual);

        model.addAttribute("questao", questaoAtual);
        model.addAttribute("numeroQuestao", indiceAtual + 1);
        model.addAttribute("totalQuestoes", questoesDiagnosticas.size());
        model.addAttribute("progressoPorcentagem", (indiceAtual * 100) / questoesDiagnosticas.size());

        return "first-test";
    }

    @PostMapping("/responder")
    public String responderQuestao(
            @RequestParam("questaoId") Integer questaoId,
            @RequestParam(value = "opcaoId", required = false) Integer opcaoId,
            HttpSession session,
            Model model) {

        Aluno alunoLogado = (Aluno) session.getAttribute("alunoLogado");

        // Delegamos a validação e o salvamento ao Service
        TentativaAtividade tentativa = nivelamentoService.registrarResposta(alunoLogado, questaoId, opcaoId);
        Questao questao = tentativa.getQuestao();

        // Montagem do gabarito para a tela
        OpcaoQuestao opcaoCorreta = questao.getOpcaoCorreta();
        String textoGabarito = "Não informado";

        if (opcaoCorreta != null) {
            if (opcaoCorreta.getLetra() != null) {
                textoGabarito = opcaoCorreta.getLetra() + ") " + opcaoCorreta.getTexto();
            } else {
                textoGabarito = opcaoCorreta.getTexto();
            }
        }

        // Atualização dos dados do progresso para a View
        List<Questao> questoesDiagnosticas = questaoRepository.findQuestoesDiagnosticasByArea(1);
        List<TentativaAtividade> tentativasRealizadas = tentativaRepository.findByAlunoId(alunoLogado.getId());

        int totalQuestoes = questoesDiagnosticas.size();
        int numeroQuestaoAtual = tentativasRealizadas.size();

        model.addAttribute("questao", questao);
        model.addAttribute("numeroQuestao", numeroQuestaoAtual);
        model.addAttribute("totalQuestoes", totalQuestoes);
        model.addAttribute("progressoPorcentagem", (numeroQuestaoAtual * 100) / totalQuestoes);
        model.addAttribute("acertou", tentativa.getAcertou());
        model.addAttribute("gabarito", textoGabarito);
        model.addAttribute("respostaExibida", true);

        return "first-test";
    }
}