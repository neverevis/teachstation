package edu.ifsp.teachstation.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http) throws Exception {

        http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/",
                    "/login",
                    "/redefinir-senha",
                    "/redefinir-senha/**",
                    "/css/**",
                    "/js/**",
                    "/images/**",
                    "/webjars/**").permitAll()

                .requestMatchers(
                    "/cadastro-aluno/**",
                    "/cadastro-professor/**",
                    "/cadastro/aluno/**",
                    "/cadastro/professor/**",
                    "/signup/**",
                    "/professor/**").hasAuthority("ROLE_SECRETARIA")

                .requestMatchers("/dashboard", "/aluno/**")
                    .hasAnyAuthority("ROLE_PROFESSOR", "ROLE_SECRETARIA")

                .requestMatchers(
                    "/first-test/**",
                    "/studyarea/**").hasAnyAuthority("ROLE_ALUNO", "ROLE_PROFESSOR", "ROLE_SECRETARIA")

                .anyRequest().hasAnyAuthority("ROLE_PROFESSOR", "ROLE_SECRETARIA")
            )
            .formLogin(form -> form
                .loginPage("/login")
                .disable()
            )
            .httpBasic(basic -> basic.disable())
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .invalidateHttpSession(true)
                .clearAuthentication(true)
                .permitAll()
            );

        return http.build();
    }
}
