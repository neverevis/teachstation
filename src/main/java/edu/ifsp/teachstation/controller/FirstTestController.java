package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.OpcaoQuestao;
import edu.ifsp.teachstation.model.Questao;
import edu.ifsp.teachstation.model.TentativaAtividade;
import edu.ifsp.teachstation.persistence.OpcaoQuestaoRepository;
import edu.ifsp.teachstation.persistence.QuestaoRepository;
import edu.ifsp.teachstation.persistence.TentativaAtividadeRepository;
import edu.ifsp.teachstation.service.NivelamentoService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/first-test")
public class FirstTestController {

    @Autowired
    private QuestaoRepository questaoRepository;

    @Autowired
    private OpcaoQuestaoRepository opcaoQuestaoRepository;

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

        if (indiceAtual >= questoesDiagnosticas.size()) {
            nivelamentoService.finalizarAvaliacao(alunoLogado);
            return "redirect:/studyarea";
        }

        Questao questaoAtual = questoesDiagnosticas.get(indiceAtual);

        model.addAttribute("questao", questaoAtual);
        model.addAttribute("numeroQuestao", indiceAtual + 1);
        model.addAttribute("totalQuestoes", questoesDiagnosticas.size());
        model.addAttribute("progressoPorcentagem", ((indiceAtual) * 100) / questoesDiagnosticas.size());

        return "first-test";
    }

    @PostMapping("/responder")
    public String responderQuestao(
            @RequestParam("questaoId") Integer questaoId,
            @RequestParam(value = "opcaoId", required = false) Integer opcaoId,
            HttpSession session,
            Model model) {

        Aluno alunoLogado = (Aluno) session.getAttribute("alunoLogado");
        
        if (alunoLogado == null) {
            return "redirect:/login";
        }

        Questao questao = questaoRepository.findById(questaoId).orElseThrow();

        OpcaoQuestao opcaoSelecionada = null;
        if (opcaoId != null) {
            opcaoSelecionada = opcaoQuestaoRepository.findById(opcaoId).orElse(null);
        }

        boolean acertou = false;
        int pontosObtidos = 0;

        if (opcaoSelecionada != null && Boolean.TRUE.equals(opcaoSelecionada.getCorreta())) {
            acertou = true;
            pontosObtidos = questao.getPontos();
        }

        // Salva a tentativa relacionando o aluno e a opção selecionada
        TentativaAtividade tentativa = new TentativaAtividade();
        tentativa.setAluno(alunoLogado);
        tentativa.setQuestao(questao);
        tentativa.setOpcaoSelecionada(opcaoSelecionada);
        tentativa.setDataTentativa(LocalDateTime.now());
        tentativa.setAcertou(acertou);
        tentativa.setPontosObtidos(pontosObtidos);
        tentativaRepository.save(tentativa);

        // Identifica a opção correta para exibição de feedback
        OpcaoQuestao opcaoCorreta = questao.getOpcaoCorreta();
        String textoGabarito = (opcaoCorreta != null) 
                ? (opcaoCorreta.getLetra() != null ? opcaoCorreta.getLetra() + ") " : "") + opcaoCorreta.getTexto() 
                : "Não informado";

        // Busca novamente as tentativas e total de questões para recalcular o progresso atual
        List<Questao> questoesDiagnosticas = questaoRepository.findQuestoesDiagnosticasByArea(1);
        List<TentativaAtividade> tentativasRealizadas = tentativaRepository.findByAlunoId(alunoLogado.getId());

        int totalQuestoes = questoesDiagnosticas.size();
        // Como acabou de salvar uma tentativa, o número da questão atual é igual à quantidade de tentativas salvas
        int numeroQuestaoAtual = tentativasRealizadas.size();
        int progressoPorcentagem = (numeroQuestaoAtual * 100) / totalQuestoes;

        model.addAttribute("questao", questao);
        model.addAttribute("numeroQuestao", numeroQuestaoAtual);
        model.addAttribute("totalQuestoes", totalQuestoes);
        model.addAttribute("progressoPorcentagem", progressoPorcentagem);
        model.addAttribute("acertou", acertou);
        model.addAttribute("gabarito", textoGabarito);
        model.addAttribute("respostaExibida", true);

        return "first-test";
    }
}