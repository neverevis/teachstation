package edu.ifsp.teachstation.service;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.AvaliacaoDiagnostica;
import edu.ifsp.teachstation.model.OpcaoQuestao;
import edu.ifsp.teachstation.model.Questao;
import edu.ifsp.teachstation.model.TentativaAtividade;
import edu.ifsp.teachstation.persistence.AlunoRepository;
import edu.ifsp.teachstation.persistence.AvaliacaoDiagnosticaRepository;
import edu.ifsp.teachstation.persistence.OpcaoQuestaoRepository;
import edu.ifsp.teachstation.persistence.QuestaoRepository;
import edu.ifsp.teachstation.persistence.TentativaAtividadeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class NivelamentoService {

    @Autowired
    private TentativaAtividadeRepository tentativaRepository;

    @Autowired
    private AvaliacaoDiagnosticaRepository avaliacaoRepository;

    @Autowired
    private AlunoRepository alunoRepository;

    @Autowired
    private QuestaoRepository questaoRepository;

    @Autowired
    private OpcaoQuestaoRepository opcaoQuestaoRepository;

    // Registrar resposta do aluno e retornar a tentativa gravada
    public TentativaAtividade registrarResposta(Aluno aluno, Integer questaoId, Integer opcaoId) {
        Questao questao = questaoRepository.findById(questaoId).orElseThrow();

        OpcaoQuestao opcaoSelecionada = null;
        if (opcaoId != null) {
            opcaoSelecionada = opcaoQuestaoRepository.findById(opcaoId).orElse(null);
        }

        boolean acertou = false;
        int pontosObtidos = 0;

        if (opcaoSelecionada != null) {
            if (Boolean.TRUE.equals(opcaoSelecionada.getCorreta())) {
                acertou = true;
                pontosObtidos = questao.getPontos();
            }
        }

        TentativaAtividade tentativa = new TentativaAtividade();
        tentativa.setAluno(aluno);
        tentativa.setQuestao(questao);
        tentativa.setOpcaoSelecionada(opcaoSelecionada);
        tentativa.setDataTentativa(LocalDateTime.now());
        tentativa.setAcertou(acertou);
        tentativa.setPontosObtidos(pontosObtidos);

        return tentativaRepository.save(tentativa);
    }

    // Calcular nível conforme a pontuação
    public String calcularNivel(int pontuacaoTotal) {
        if (pontuacaoTotal <= 90) {
            return "INICIANTE";
        } else if (pontuacaoTotal <= 170) {
            return "INTERMEDIARIO";
        } else {
            return "AVANCADO";
        }
    }

    // Finalizar a avaliação do aluno no banco
    public void finalizarAvaliacao(Aluno aluno) {
        List<TentativaAtividade> tentativas = tentativaRepository.findByAlunoId(aluno.getId());
        
        int totalPontos = 0;
        for (TentativaAtividade tentativa : tentativas) {
            if (tentativa.getPontosObtidos() != null) {
                totalPontos = totalPontos + tentativa.getPontosObtidos();
            }
        }

        String nivelClassificado = calcularNivel(totalPontos);

        AvaliacaoDiagnostica avaliacao = new AvaliacaoDiagnostica();
        avaliacao.setAluno(aluno);
        avaliacao.setDataAvaliacao(LocalDateTime.now());
        avaliacao.setNotaFinal((float) totalPontos);
        avaliacao.setNivelClassificado(nivelClassificado);
        avaliacaoRepository.save(avaliacao);

        aluno.setNivelAtual(nivelClassificado);
        alunoRepository.save(aluno);
    }
}