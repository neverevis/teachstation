package edu.ifsp.teachstation.service;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.AvaliacaoDiagnostica;
import edu.ifsp.teachstation.persistence.*;
import edu.ifsp.teachstation.service.dto.AlunoProgresso;
import edu.ifsp.teachstation.service.dto.DashboardResumo;
import edu.ifsp.teachstation.service.dto.NivelContagem;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Concentra as consultas e cálculos do dashboard.
 * O controller só chama este service e joga o resultado no template.
 */
@Service
public class DashboardService {

    private final AlunoRepository alunoRepository;
    private final ProfessorRepository professorRepository;
    private final QuestaoRepository questaoRepository;
    private final QuestaoGamificadaRepository questaoGamificadaRepository;
    private final TentativaAtividadeRepository tentativaAtividadeRepository;
    private final TentativaGamificadaRepository tentativaGamificadaRepository;
    private final AvaliacaoDiagnosticaRepository avaliacaoRepository;

    public DashboardService(AlunoRepository alunoRepository,
                            ProfessorRepository professorRepository,
                            QuestaoRepository questaoRepository,
                            QuestaoGamificadaRepository questaoGamificadaRepository,
                            TentativaAtividadeRepository tentativaAtividadeRepository,
                            TentativaGamificadaRepository tentativaGamificadaRepository,
                            AvaliacaoDiagnosticaRepository avaliacaoRepository) {
        this.alunoRepository = alunoRepository;
        this.professorRepository = professorRepository;
        this.questaoRepository = questaoRepository;
        this.questaoGamificadaRepository = questaoGamificadaRepository;
        this.tentativaAtividadeRepository = tentativaAtividadeRepository;
        this.tentativaGamificadaRepository = tentativaGamificadaRepository;
        this.avaliacaoRepository = avaliacaoRepository;
    }

    /**
     * Monta os cards do topo (números gerais).
     */
    public DashboardResumo montarResumo() {
        DashboardResumo r = new DashboardResumo();

        r.setTotalAlunos(alunoRepository.count());
        r.setTotalProfessores(professorRepository.count());
        r.setTotalQuestoes(questaoRepository.count());
        r.setTotalQuestoesGamificadas(questaoGamificadaRepository.count());
        r.setAvaliacoesRealizadas(avaliacaoRepository.count());

        long tentativasDiag = tentativaAtividadeRepository.countTentativasDiagnosticas();
        long acertosDiag = tentativaAtividadeRepository.countAcertosDiagnosticos();
        r.setTentativasDiagnosticas(tentativasDiag);
        r.setTaxaAcertoDiagnostica(calcularPorcentagem(acertosDiag, tentativasDiag));

        long tentativasGam = tentativaGamificadaRepository.countTentativasGamificadas();
        long acertosGam = tentativaGamificadaRepository.countAcertosGamificados();
        r.setTentativasGamificadas(tentativasGam);
        r.setTaxaAcertoGamificada(calcularPorcentagem(acertosGam, tentativasGam));

        r.setMediaNotaDiagnostica(avaliacaoRepository.calcularMediaNotas());

        return r;
    }

    /**
     * Lista de alunos com o progresso (para a tabela).
     */
    public List<AlunoProgresso> montarListaAlunos() {
        return montarListaAlunos(null);
    }

    public List<AlunoProgresso> montarListaAlunos(String busca) {
        List<Aluno> alunos = (busca != null && !busca.trim().isEmpty())
                ? alunoRepository.pesquisar(busca.trim())
                : alunoRepository.findAll();
        List<AlunoProgresso> resultado = new ArrayList<>();

        for (Aluno aluno : alunos) {
            AlunoProgresso ap = new AlunoProgresso();

            ap.setId(aluno.getId());
            ap.setRa(aluno.getRa());
            // usa nome social quando existir
            String nome = (aluno.getNomeSocial() != null && !aluno.getNomeSocial().isBlank())
                    ? aluno.getNomeSocial() : aluno.getNomeCompleto();
            ap.setNome(nome);
            ap.setEmail(aluno.getEmail());
            ap.setTelefoneResponsavel(aluno.getTelefoneResponsavel());
            ap.setIdade(aluno.getIdade());
            ap.setNivelAtual(aluno.getNivelAtual());
            ap.setProgressoNivel(aluno.getProgressoNivel());

            // Tentativas diagnósticas
            int acertosDiag = tentativaAtividadeRepository.countAcertosByAluno(aluno.getId());
            int tentativasDiag = (int) tentativaAtividadeRepository.countByAlunoId(aluno.getId());
            int pontosDiag = tentativaAtividadeRepository.sumPontosByAlunoId(aluno.getId());

            // Tentativas gamificadas
            int acertosGam = tentativaGamificadaRepository.countAcertosByAluno(aluno.getId());
            int tentativasGam = (int) tentativaGamificadaRepository.countByAlunoId(aluno.getId());
            int pontosGam = tentativaGamificadaRepository.sumPontosByAluno(aluno.getId());

            ap.setPontosDiagnosticos(pontosDiag);
            ap.setPontosGamificados(pontosGam);
            ap.setAcertos(acertosDiag + acertosGam);
            ap.setTotalTentativas(tentativasDiag + tentativasGam);
            ap.setTaxaAcerto(calcularPorcentagem(acertosDiag + acertosGam, tentativasDiag + tentativasGam));

            // Marca se o aluno já tem avaliação diagnóstica registrada
            ap.setFezDiagnostica(avaliacaoRepository.existsByAlunoId(aluno.getId()));

            resultado.add(ap);
        }

        return resultado;
    }

    /**
     * Conta quantos alunos existem em cada nível.
     * Usado no gráfico de barras.
     */
    public List<NivelContagem> montarDistribuicaoNiveis() {
        List<Aluno> alunos = alunoRepository.findAll();

        long iniciante = 0, intermediario = 0, avancado = 0, semNivel = 0;

        for (Aluno a : alunos) {
            String nivel = a.getNivelAtual();
            if ("INICIANTE".equals(nivel)) iniciante++;
            else if ("INTERMEDIARIO".equals(nivel)) intermediario++;
            else if ("AVANCADO".equals(nivel)) avancado++;
            else semNivel++;
        }

        long total = alunos.size();

        List<NivelContagem> lista = new ArrayList<>();
        lista.add(new NivelContagem("Iniciante", iniciante, calcularPorcentagem(iniciante, total)));
        lista.add(new NivelContagem("Intermediário", intermediario, calcularPorcentagem(intermediario, total)));
        lista.add(new NivelContagem("Avançado", avancado, calcularPorcentagem(avancado, total)));
        lista.add(new NivelContagem("Sem nível", semNivel, calcularPorcentagem(semNivel, total)));
        return lista;
    }

    /**
     * Lista as últimas avaliações diagnósticas para a secretaria/professor
     * acompanharem quem já foi classificado.
     */
    public List<AvaliacaoDiagnostica> ultimasAvaliacoes() {
        List<AvaliacaoDiagnostica> todas = avaliacaoRepository.findAll();
        // ordena da mais recente para a mais antiga (pelo id, que é sequencial)
        todas.sort((a, b) -> b.getId().compareTo(a.getId()));
        // devolve no máximo 5
        return todas.size() > 5 ? todas.subList(0, 5) : todas;
    }

    // Evita divisão por zero e devolve um valor entre 0 e 100
    private double calcularPorcentagem(long parte, long total) {
        if (total == 0) return 0;
        return Math.round((parte * 100.0 / total) * 10.0) / 10.0; // 1 casa decimal
    }
}
