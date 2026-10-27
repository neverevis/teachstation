package edu.ifsp.teachstation.config;

import java.util.Map;
import java.util.regex.Pattern;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;


@ControllerAdvice(annotations = Controller.class)
public class NavegacaoAdvice {

    private static final Map<String, String> TELA_ANTERIOR = Map.of(
            "/cadastros", "/dashboard",
            "/cadastro/aluno", "/cadastros",
            "/cadastro/professor", "/cadastros",
            "/studyarea/portuguese", "/studyarea"
    );

    private static final Pattern FASE = Pattern.compile("^/studyarea/portuguese/level[1-8]$");

    @ModelAttribute("urlVoltar")
    public String urlVoltar(HttpServletRequest request) {
        String caminho = request.getRequestURI().substring(request.getContextPath().length());
        if (FASE.matcher(caminho).matches()) {
            return "/studyarea/portuguese";
        }
        return TELA_ANTERIOR.get(caminho);
    }
}
