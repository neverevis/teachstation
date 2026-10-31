package edu.ifsp.teachstation.service;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.QuestaoGamificada;
import edu.ifsp.teachstation.model.TentativaGamificada;
import edu.ifsp.teachstation.persistence.QuestaoGamificadaRepository;
import edu.ifsp.teachstation.persistence.TentativaGamificadaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.json.JsonMapper;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class QuizGamificadoService {

    public static final String ASSOCIACAO = "ASSOCIACAO";
    public static final String PREENCHIMENTO = "PREENCHIMENTO";
    public static final String MULTIPLA_ESCOLHA = "MULTIPLA_ESCOLHA";

    // Associação e múltipla escolha valem uma única tentativa (a resposta trava ao confirmar);
    // o preenchimento permite corrigir as lacunas e tentar de novo
    private static final int TENTATIVAS_UMA = 1;
    private static final int TENTATIVAS_PREENCHIMENTO = 3;

    // O mapa do overworld tem 8 fases; questões em fases acima disso ficam guardadas, sem acesso
    public static final int ULTIMA_FASE_DO_MAPA = 8;

    private static final Pattern LACUNA = Pattern.compile("\\{(\\d+)\\}");

    @Autowired
    private QuestaoGamificadaRepository questaoRepository;

    @Autowired
    private TentativaGamificadaRepository tentativaRepository;

    private final JsonMapper json = JsonMapper.builder().build();

    // ---------- Objetos devolvidos ao frontend ----------

    public record EstadoDto(int tentativasUsadas, int tentativasMax, boolean resolvida, boolean acertou,
                            int pontosObtidos, Map<String, Object> ultimaResposta,
                            Map<String, Boolean> detalhes, Map<String, Object> gabarito, String explicacao) {
    }

    public record QuestaoDto(Integer id, String tipo, Integer ordem, String enunciado, String textoApoio,
                             Integer pontos, Map<String, Object> conteudo, EstadoDto estado) {
    }

    public record FaseDto(int fase, int rodada, int total, int pontosMaximos, boolean concluida,
                          List<QuestaoDto> questoes) {
    }

    public record RespostaDto(EstadoDto estado, boolean faseConcluida) {
    }

    public record ItemResultadoDto(int ordem, String tipo, String enunciado, boolean acertou,
                                   int pontosObtidos, int pontosMaximos) {
    }

    // proximaFase é null quando não há outra fase depois desta
    public record ResultadoDto(int fase, int rodada, int totalQuestoes, int acertos, int pontos,
                               int pontosMaximos, List<ItemResultadoDto> itens, Integer proximaFase) {
    }

    // resultado interno da correção de uma resposta
    private record Avaliacao(boolean acertou, Map<String, Boolean> detalhes, Map<String, Object> normalizada) {
    }

    // erro de regra de negócio com o status HTTP correspondente
    public static class QuizException extends RuntimeException {
        private final HttpStatus status;

        public QuizException(HttpStatus status, String mensagem) {
            super(mensagem);
            this.status = status;
        }

        public HttpStatus getStatus() {
            return status;
        }
    }

    // ---------- Operações públicas ----------

    // carrega a fase com o estado do aluno. Com nova=true e a rodada concluída, devolve uma rodada em branco.
    @Transactional(readOnly = true)
    public FaseDto obterFase(Aluno aluno, int fase, boolean nova) {
        List<QuestaoGamificada> questoes = questoesDaFase(fase);
        exigirFaseLiberada(aluno, fase);
        int ultima = tentativaRepository.findUltimaRodada(aluno.getId(), fase);

        int rodada = Math.max(ultima, 1);
        List<TentativaGamificada> tentativas = ultima == 0 ? List.of() : buscarTentativas(aluno, ultima, fase);

        if (nova && ultima > 0 && rodadaConcluida(questoes, tentativas)) {
            rodada = ultima + 1;
            tentativas = List.of();
        }

        return montarFase(fase, rodada, questoes, tentativas);
    }

    // valida a resposta no servidor, grava a tentativa e devolve o novo estado da questão
    @Transactional
    public RespostaDto responder(Aluno aluno, Integer questaoId, Map<String, Object> resposta) {
        QuestaoGamificada questao = questaoRepository.findById(questaoId)
                .orElseThrow(() -> new QuizException(HttpStatus.NOT_FOUND, "Questão não encontrada."));
        if (resposta == null) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Resposta inválida.");
        }

        int fase = questao.getFase();
        List<QuestaoGamificada> questoes = questoesDaFase(fase);
        exigirFaseLiberada(aluno, fase);
        int ultima = tentativaRepository.findUltimaRodada(aluno.getId(), fase);
        List<TentativaGamificada> daUltima = ultima == 0 ? List.of() : buscarTentativas(aluno, ultima, fase);

        // se a última rodada já terminou, a nova resposta inicia a rodada seguinte
        int rodada = 1;
        List<TentativaGamificada> tentativas = List.of();
        if (ultima > 0) {
            if (rodadaConcluida(questoes, daUltima)) {
                rodada = ultima + 1;
            } else {
                rodada = ultima;
                tentativas = daUltima;
            }
        }

        List<TentativaGamificada> daQuestao = tentativasDaQuestao(tentativas, questao.getId());
        if (estadoDe(questao, daQuestao).resolvida()) {
            throw new QuizException(HttpStatus.CONFLICT, "Esta questão já foi resolvida.");
        }

        Avaliacao avaliacao = avaliar(questao, resposta);

        TentativaGamificada tentativa = new TentativaGamificada();
        tentativa.setAluno(aluno);
        tentativa.setQuestaoGamificada(questao);
        tentativa.setRodada(rodada);
        tentativa.setNumeroTentativa(daQuestao.size() + 1);
        tentativa.setRespostaJson(json.writeValueAsString(avaliacao.normalizada()));
        tentativa.setAcertou(avaliacao.acertou());
        tentativa.setPontosObtidos(avaliacao.acertou() ? questao.getPontos() : 0);
        tentativa.setDataTentativa(LocalDateTime.now());

        try {
            tentativaRepository.saveAndFlush(tentativa);
        } catch (DataIntegrityViolationException e) {
            throw new QuizException(HttpStatus.CONFLICT, "Esta resposta já foi registrada. Atualize a página.");
        }

        List<TentativaGamificada> todas = new ArrayList<>(tentativas);
        todas.add(tentativa);

        return new RespostaDto(estadoDe(questao, tentativasDaQuestao(todas, questao.getId())),
                rodadaConcluida(questoes, todas));
    }

    @Transactional(readOnly = true)
    public List<Integer> listarFasesLiberadas(Aluno aluno) {
        List<Integer> existentes = fasesDoMapa();
        List<Integer> liberadas = new ArrayList<>();

        for (int i = 0; i < existentes.size(); i++) {
            if (i > 0 && !faseConcluida(aluno, existentes.get(i - 1))) {
                break;
            }
            liberadas.add(existentes.get(i));
        }
        return liberadas;
    }

    @Transactional(readOnly = true)
    public ResultadoDto obterResultado(Aluno aluno, int fase) {
        List<QuestaoGamificada> questoes = questoesDaFase(fase);
        exigirFaseLiberada(aluno, fase);
        int ultima = tentativaRepository.findUltimaRodada(aluno.getId(), fase);
        List<TentativaGamificada> tentativas = ultima == 0 ? List.of() : buscarTentativas(aluno, ultima, fase);

        if (ultima == 0 || !rodadaConcluida(questoes, tentativas)) {
            throw new QuizException(HttpStatus.CONFLICT, "Ainda há questões sem resolver.");
        }

        List<ItemResultadoDto> itens = new ArrayList<>();
        int acertos = 0;
        int pontos = 0;
        int pontosMaximos = 0;

        for (QuestaoGamificada questao : questoes) {
            EstadoDto estado = estadoDe(questao, tentativasDaQuestao(tentativas, questao.getId()));
            itens.add(new ItemResultadoDto(questao.getOrdem(), questao.getTipo(), questao.getEnunciado(),
                    estado.acertou(), estado.pontosObtidos(), questao.getPontos()));
            if (estado.acertou()) {
                acertos++;
            }
            pontos += estado.pontosObtidos();
            pontosMaximos += questao.getPontos();
        }

        List<Integer> existentes = fasesDoMapa();
        Integer proximaFase = existentes.contains(fase + 1) ? fase + 1 : null;

        return new ResultadoDto(fase, ultima, questoes.size(), acertos, pontos, pontosMaximos, itens, proximaFase);
    }


    private FaseDto montarFase(int fase, int rodada, List<QuestaoGamificada> questoes,
                               List<TentativaGamificada> tentativas) {
        List<QuestaoDto> lista = new ArrayList<>();
        int pontosMaximos = 0;

        for (QuestaoGamificada questao : questoes) {
            EstadoDto estado = estadoDe(questao, tentativasDaQuestao(tentativas, questao.getId()));
            lista.add(new QuestaoDto(questao.getId(), questao.getTipo(), questao.getOrdem(),
                    questao.getEnunciado(), questao.getTextoApoio(), questao.getPontos(),
                    lerMapa(questao.getConteudoJson()), estado));
            pontosMaximos += questao.getPontos();
        }

        return new FaseDto(fase, rodada, questoes.size(), pontosMaximos,
                rodadaConcluida(questoes, tentativas), lista);
    }

    private EstadoDto estadoDe(QuestaoGamificada questao, List<TentativaGamificada> tentativas) {
        int usadas = tentativas.size();
        int max = tentativasMax(questao.getTipo());
        boolean acertou = false;
        int pontos = 0;

        for (TentativaGamificada tentativa : tentativas) {
            if (Boolean.TRUE.equals(tentativa.getAcertou())) {
                acertou = true;
                pontos = tentativa.getPontosObtidos();
            }
        }

        boolean resolvida = acertou || usadas >= max;

        Map<String, Object> ultimaResposta = null;
        Map<String, Boolean> detalhes = null;
        if (usadas > 0) {
            ultimaResposta = lerMapa(tentativas.get(usadas - 1).getRespostaJson());
            detalhes = avaliar(questao, ultimaResposta).detalhes();
        }

        Map<String, Object> gabarito = resolvida ? lerMapa(questao.getGabaritoJson()) : null;
        String explicacao = resolvida ? questao.getExplicacao() : null;

        return new EstadoDto(usadas, max, resolvida, acertou, pontos, ultimaResposta, detalhes, gabarito, explicacao);
    }

    private boolean rodadaConcluida(List<QuestaoGamificada> questoes, List<TentativaGamificada> tentativas) {
        for (QuestaoGamificada questao : questoes) {
            if (!estadoDe(questao, tentativasDaQuestao(tentativas, questao.getId())).resolvida()) {
                return false;
            }
        }
        return !questoes.isEmpty();
    }

    private List<TentativaGamificada> tentativasDaQuestao(List<TentativaGamificada> tentativas, Integer questaoId) {
        List<TentativaGamificada> resultado = new ArrayList<>();
        for (TentativaGamificada tentativa : tentativas) {
            if (Objects.equals(tentativa.getQuestaoGamificada().getId(), questaoId)) {
                resultado.add(tentativa);
            }
        }
        return resultado;
    }

    private List<TentativaGamificada> buscarTentativas(Aluno aluno, int rodada, int fase) {
        return tentativaRepository.findByAlunoIdAndRodadaAndQuestaoGamificadaFaseOrderByIdAsc(
                aluno.getId(), rodada, fase);
    }

    private List<Integer> fasesDoMapa() {
        List<Integer> fases = new ArrayList<>();
        for (Integer fase : questaoRepository.findFasesDisponiveis()) {
            if (fase != null && fase >= 1 && fase <= ULTIMA_FASE_DO_MAPA) {
                fases.add(fase);
            }
        }
        return fases;
    }

    private boolean faseConcluida(Aluno aluno, int fase) {
        int ultima = tentativaRepository.findUltimaRodada(aluno.getId(), fase);
        if (ultima == 0) {
            return false;
        }
        if (ultima > 1) {
            return true;
        }
        return rodadaConcluida(questaoRepository.findByFaseOrderByOrdemAsc(fase), buscarTentativas(aluno, 1, fase));
    }

    private void exigirFaseLiberada(Aluno aluno, int fase) {
        if (!listarFasesLiberadas(aluno).contains(fase)) {
            throw new QuizException(HttpStatus.FORBIDDEN,
                    "Fase bloqueada. Conclua a fase anterior para liberar esta.");
        }
    }

    private List<QuestaoGamificada> questoesDaFase(int fase) {
        List<QuestaoGamificada> questoes = questaoRepository.findByFaseOrderByOrdemAsc(fase);
        if (questoes.isEmpty()) {
            throw new QuizException(HttpStatus.NOT_FOUND, "Fase não encontrada.");
        }
        return questoes;
    }

    private int tentativasMax(String tipo) {
        return PREENCHIMENTO.equals(tipo) ? TENTATIVAS_PREENCHIMENTO : TENTATIVAS_UMA;
    }


    private Avaliacao avaliar(QuestaoGamificada questao, Map<String, Object> resposta) {
        Map<String, Object> conteudo = lerMapa(questao.getConteudoJson());
        Map<String, Object> gabarito = lerMapa(questao.getGabaritoJson());

        return switch (questao.getTipo()) {
            case ASSOCIACAO -> avaliarAssociacao(conteudo, gabarito, resposta);
            case PREENCHIMENTO -> avaliarPreenchimento(conteudo, gabarito, resposta);
            case MULTIPLA_ESCOLHA -> avaliarMultiplaEscolha(conteudo, gabarito, resposta);
            default -> throw new IllegalStateException("Tipo de questão desconhecido: " + questao.getTipo());
        };
    }

    private Avaliacao avaliarAssociacao(Map<String, Object> conteudo, Map<String, Object> gabarito,
                                        Map<String, Object> resposta) {
        Set<String> frases = ids(conteudo.get("esquerda"));
        Set<String> palavras = ids(conteudo.get("direita"));
        Map<String, String> pares = textoPorTexto(resposta.get("pares"));

        if (!pares.keySet().equals(frases)) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Conecte todas as frases antes de confirmar.");
        }
        if (!palavras.containsAll(pares.values())) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Palavra inválida na resposta.");
        }
        if (new HashSet<>(pares.values()).size() != pares.size()) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Cada palavra só pode ser ligada a uma frase.");
        }

        Map<String, Boolean> detalhes = new LinkedHashMap<>();
        boolean acertou = true;
        for (String frase : frases) {
            boolean correta = Objects.equals(gabarito.get(frase), pares.get(frase));
            detalhes.put(frase, correta);
            acertou = acertou && correta;
        }

        Map<String, Object> normalizada = new LinkedHashMap<>();
        normalizada.put("pares", new LinkedHashMap<String, Object>(pares));
        return new Avaliacao(acertou, detalhes, normalizada);
    }

    private Avaliacao avaliarPreenchimento(Map<String, Object> conteudo, Map<String, Object> gabarito,
                                           Map<String, Object> resposta) {
        Set<String> lacunas = new LinkedHashSet<>();
        Matcher matcher = LACUNA.matcher(String.valueOf(conteudo.get("frase")));
        while (matcher.find()) {
            lacunas.add(matcher.group(1));
        }

        Set<String> opcoes = ids(conteudo.get("opcoes"));
        Map<String, String> preenchidas = textoPorTexto(resposta.get("lacunas"));

        if (!preenchidas.keySet().equals(lacunas)) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Preencha todas as lacunas antes de confirmar.");
        }
        if (!opcoes.containsAll(preenchidas.values())) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Verbo inválido na resposta.");
        }
        if (new HashSet<>(preenchidas.values()).size() != preenchidas.size()) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Cada verbo só pode ser usado uma vez.");
        }

        Map<String, Boolean> detalhes = new LinkedHashMap<>();
        boolean acertou = true;
        for (String lacuna : lacunas) {
            boolean correta = Objects.equals(gabarito.get(lacuna), preenchidas.get(lacuna));
            detalhes.put(lacuna, correta);
            acertou = acertou && correta;
        }

        Map<String, Object> normalizada = new LinkedHashMap<>();
        normalizada.put("lacunas", new LinkedHashMap<String, Object>(preenchidas));
        return new Avaliacao(acertou, detalhes, normalizada);
    }

    private Avaliacao avaliarMultiplaEscolha(Map<String, Object> conteudo, Map<String, Object> gabarito,
                                             Map<String, Object> resposta) {
        Set<String> opcoes = ids(conteudo.get("opcoes"));
        Object escolhida = resposta.get("opcao");

        if (!(escolhida instanceof String opcao) || !opcoes.contains(opcao)) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Alternativa inválida.");
        }

        boolean acertou = Objects.equals(gabarito.get("correta"), opcao);

        Map<String, Boolean> detalhes = new LinkedHashMap<>();
        detalhes.put(opcao, acertou);

        Map<String, Object> normalizada = new LinkedHashMap<>();
        normalizada.put("opcao", opcao);
        return new Avaliacao(acertou, detalhes, normalizada);
    }


    private Map<String, Object> lerMapa(String texto) {
        return json.readValue(texto, new TypeReference<Map<String, Object>>() {
        });
    }

    private Set<String> ids(Object lista) {
        Set<String> resultado = new LinkedHashSet<>();
        if (lista instanceof List<?> itens) {
            for (Object item : itens) {
                if (item instanceof Map<?, ?> mapa) {
                    resultado.add(String.valueOf(mapa.get("id")));
                }
            }
        }
        return resultado;
    }


    private Map<String, String> textoPorTexto(Object valor) {
        if (!(valor instanceof Map<?, ?> mapa)) {
            throw new QuizException(HttpStatus.BAD_REQUEST, "Resposta inválida.");
        }
        Map<String, String> resultado = new LinkedHashMap<>();
        for (Map.Entry<?, ?> entrada : mapa.entrySet()) {
            if (!(entrada.getKey() instanceof String chave) || !(entrada.getValue() instanceof String conteudo)) {
                throw new QuizException(HttpStatus.BAD_REQUEST, "Resposta inválida.");
            }
            resultado.put(chave, conteudo);
        }
        return resultado;
    }
}