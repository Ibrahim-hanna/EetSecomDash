package com.example.Springboot.config;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import java.io.IOException;

@Component
public class LoggingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        System.out.println("[FILTER] Requête : " + ((HttpServletRequest)request).getRequestURI());
        if (authentication != null) {
            System.out.println("[FILTER] Utilisateur courant : " + authentication.getName());
            System.out.println("[FILTER] Authorities : " + authentication.getAuthorities());
        } else {
            System.out.println("[FILTER] Aucun utilisateur authentifié !");
        }
        chain.doFilter(request, response);
    }
} 