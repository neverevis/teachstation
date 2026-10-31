package edu.ifsp.teachstation.config;

import java.util.Map;
import java.util.regex.Pattern;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice(annotations = Controller.class)
public class NavegacaoAdvice {

    private static final Map<String, String> TELA_ANTERIOR = Map.ofEntries(
            Map.entry("/cadastros", "/dashboard"),
            Map.entry("/redefinir-senha", "/login"),
            Map.entry("/cadastro/aluno", "/cadastros"),
            Map.entry("/cadastro/professor", "/cadastros"),
            Map.entry("/aluno/listar", "/dashboard"),
            Map.entry("/aluno/novo", "/aluno/listar"),
            Map.entry("/aluno/salvar", "/aluno/listar"),
            Map.entry("/professor/listar", "/dashboard"),
            Map.entry("/professor/novo", "/professor/listar"),
            Map.entry("/professor/salvar", "/professor/listar"),
            Map.entry("/studyarea/portuguese", "/studyarea")
    );

    private static final Pattern FASE = Pattern.compile("^/studyarea/portuguese/level[1-8]$");
    private static final Pattern EDITAR_ALUNO = Pattern.compile("^/aluno/\\d+/editar$");
    private static final Pattern EDITAR_PROFESSOR = Pattern.compile("^/professor/\\d+/editar$");

    @ModelAttribute("urlVoltar")
    public String urlVoltar(HttpServletRequest request) {
        String caminho = request.getRequestURI().substring(request.getContextPath().length());
        if (FASE.matcher(caminho).matches()) {
            return "/studyarea/portuguese";
        }
        if (EDITAR_ALUNO.matcher(caminho).matches()) {
            return "/aluno/listar";
        }
        if (EDITAR_PROFESSOR.matcher(caminho).matches()) {
            return "/professor/listar";
        }
        return TELA_ANTERIOR.get(caminho);
    }
}
