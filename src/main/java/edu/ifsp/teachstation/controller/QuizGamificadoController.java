package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.service.QuizGamificadoService;
import edu.ifsp.teachstation.service.QuizGamificadoService.FaseDto;
import edu.ifsp.teachstation.service.QuizGamificadoService.QuizException;
import edu.ifsp.teachstation.service.QuizGamificadoService.RespostaDto;
import edu.ifsp.teachstation.service.QuizGamificadoService.ResultadoDto;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import java.util.List;
import java.util.Map;

/**
 * API JSON dos questionários gamificados. A página (quiz-gamificado.html) usa
 * estes endpoints com fetch, sem recarregar. Apenas alunos logados respondem.
 */
@RestController
@RequestMapping("/studyarea/portuguese/quiz/api")
public class QuizGamificadoController {

    private static final Logger log = LoggerFactory.getLogger(QuizGamificadoController.class);

    @Autowired
    private QuizGamificadoService quizService;

    // Questões da fase (sem gabarito) e o estado do aluno na rodada atual

    @GetMapping("/fases")
    public List<Integer> listarFases() {
        return quizService.listarFasesDisponiveis();
    }

    @GetMapping("/fases/{fase}")
    public FaseDto obterFase(@PathVariable("fase") int fase,
                             @RequestParam(value = "nova", defaultValue = "false") boolean nova,
                             HttpSession session) {
        return quizService.obterFase(alunoLogado(session), fase, nova);
    }

    // Valida a resposta de uma questão e registra a tentativa
    @PostMapping("/questoes/{questaoId}/resposta")
    public RespostaDto responder(@PathVariable("questaoId") Integer questaoId,
                                 @RequestBody Map<String, Object> resposta,
                                 HttpSession session) {
        return quizService.responder(alunoLogado(session), questaoId, resposta);
    }

    // Resultado final da fase (só depois de todas as questões resolvidas)
    @GetMapping("/fases/{fase}/resultado")
    public ResultadoDto obterResultado(@PathVariable("fase") int fase, HttpSession session) {
        return quizService.obterResultado(alunoLogado(session), fase);
    }

    @ExceptionHandler(QuizException.class)
    public ResponseEntity<Map<String, String>> tratarErro(QuizException e) {
        return ResponseEntity.status(e.getStatus()).body(Map.of("erro", e.getMessage()));
    }

    // JSON malformado, que não é um objeto, ou número de fase inválido na URL
    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<Map<String, String>> tratarRequisicaoInvalida(Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("erro", "Resposta inválida."));
    }

    // Qualquer falha inesperada volta como JSON, para o frontend exibir uma mensagem clara
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> tratarFalha(RuntimeException e) {
        log.error("Falha no questionário gamificado", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("erro", "Não foi possível concluir a ação. Tente novamente."));
    }

    private Aluno alunoLogado(HttpSession session) {
        Aluno aluno = (Aluno) session.getAttribute("alunoLogado");
        if (aluno == null) {
            throw new QuizException(HttpStatus.FORBIDDEN, "Apenas alunos podem responder aos questionários.");
        }
        return aluno;
    }
}
