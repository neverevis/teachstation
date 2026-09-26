package edu.ifsp.teachstation.service;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.AvaliacaoDiagnostica;
import edu.ifsp.teachstation.model.Questao;
import edu.ifsp.teachstation.model.TentativaAtividade;
import edu.ifsp.teachstation.persistence.AlunoRepository;
import edu.ifsp.teachstation.persistence.AvaliacaoDiagnosticaRepository;
import edu.ifsp.teachstation.persistence.TentativaAtividadeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Service
public class NivelamentoService {

    @Autowired
    private TentativaAtividadeRepository tentativaRepository;

    @Autowired
    private AvaliacaoDiagnosticaRepository avaliacaoRepository;

    @Autowired
    private AlunoRepository alunoRepository;

    // Calcula o nível do aluno com base na pontuação na avaliação diagnóstica
    public String calcularNivel(int pontuacaoTotal) {
        if (pontuacaoTotal <= 90) {
            return "INICIANTE";
        } else if (pontuacaoTotal <= 170) {
            return "INTERMEDIARIO";
        } else {
            return "AVANCADO";
        }
    }

    // Finaliza a avaliação do aluno
    public void finalizarAvaliacao(Aluno aluno) {
        List<TentativaAtividade> tentativas = tentativaRepository.findByAlunoId(aluno.getId());
        
        int totalPontos = tentativas.stream()
                .mapToInt(TentativaAtividade::getPontosObtidos)
                .sum();

        String nivelClassificado = calcularNivel(totalPontos);

        // Salva histórico da Avaliação Diagnóstica
        AvaliacaoDiagnostica avaliacao = new AvaliacaoDiagnostica();
        avaliacao.setAluno(aluno);
        avaliacao.setDataAvaliacao(LocalDateTime.now());
        avaliacao.setNotaFinal((float) totalPontos);
        avaliacao.setNivelClassificado(nivelClassificado);
        avaliacaoRepository.save(avaliacao);

        // Atualiza nivel_atual no perfil do aluno
        aluno.setNivelAtual(nivelClassificado);
        alunoRepository.save(aluno);
    }
}
