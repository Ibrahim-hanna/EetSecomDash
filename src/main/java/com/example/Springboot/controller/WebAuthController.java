package com.example.Springboot.controller;

import com.example.Springboot.dto.RegisterRequest;
import com.example.Springboot.dto.LoginRequest;
import com.example.Springboot.model.Role;
import com.example.Springboot.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.User;
import java.util.Collections;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.core.context.SecurityContextImpl;
import jakarta.servlet.http.HttpServletRequest;
import com.example.Springboot.service.ProjetService;
import com.example.Springboot.dto.ProjetDTO;
import java.util.List;
import java.util.Optional;

@Controller
public class WebAuthController {
    @Autowired
    private AuthService authService;

    @Autowired
    private ProjetService projetService;

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        model.addAttribute("registerRequest", new RegisterRequest());
        model.addAttribute("roles", Role.values());
        return "register";
    }

    @PostMapping("/register")
    public String processRegister(@ModelAttribute RegisterRequest registerRequest, Model model) {
        var response = authService.register(registerRequest);
        if (response.getMessage() != null && response.getMessage().contains("existe déjà")) {
            model.addAttribute("error", response.getMessage());
            model.addAttribute("roles", Role.values());
            return "register";
        }
        model.addAttribute("success", "Inscription réussie ! Connectez-vous.");
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String showLoginForm(Model model) {
        model.addAttribute("loginRequest", new LoginRequest());
        return "login";
    }

    @PostMapping("/login")
    public String processLogin(@ModelAttribute LoginRequest loginRequest, Model model, RedirectAttributes redirectAttributes, HttpServletRequest request) {
        System.out.println("Tentative de connexion pour : " + loginRequest.getEmail());
        var response = authService.login(loginRequest);
        System.out.println("Réponse du service d'authentification : " + response.getMessage());
        if (response.getMessage() != null && response.getMessage().contains("incorrect")) {
            System.out.println("Echec de connexion pour : " + loginRequest.getEmail());
            model.addAttribute("error", response.getMessage());
            return "login";
        }
        var userOpt = authService.findUserByEmail(loginRequest.getEmail());
        if (userOpt.isPresent()) {
            var user = userOpt.get();
            UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities("ROLE_" + user.getRole().name())
                .build();
            SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(
                    userDetails,
                    user.getPassword(),
                    userDetails.getAuthorities()
                )
            );
            // Persistance du contexte de sécurité dans la session HTTP
            request.getSession().setAttribute(
                HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY,
                new SecurityContextImpl(SecurityContextHolder.getContext().getAuthentication())
            );
            System.out.println("Utilisateur authentifié dans la session : " + SecurityContextHolder.getContext().getAuthentication());
        } else {
            System.out.println("Utilisateur non trouvé en base après login : " + loginRequest.getEmail());
        }
        redirectAttributes.addFlashAttribute("success", "Connexion réussie !");
        System.out.println("Redirection vers /dashboard");
        return "redirect:/dashboard";
    }

    @GetMapping("/splash")
    public String showSplash() {
        return "splash";
    }

    @GetMapping("/")
    public String redirectToSplash() {
        return "redirect:/splash";
    }

    @GetMapping("/dashboard")
    public String showDashboard(@RequestParam(value = "projet", required = false) Integer projetIndex, Model model) {
        System.out.println("=== DEBUG DASHBOARD ===");
        
        // Récupère les projets depuis la base H2 (et non le JSON)
        List<ProjetDTO> projets = projetService.getAllProjets()
            .stream()
            .map(projetService::toDTO)
            .toList();
        
        System.out.println("Nombre de projets récupérés: " + projets.size());
        if (!projets.isEmpty()) {
            System.out.println("Premier projet: " + projets.get(0).getNumeroProjet() + " - " + projets.get(0).getClient());
        }
        
        int idx = (projetIndex != null && projetIndex >= 0 && projetIndex < projets.size()) ? projetIndex : 0;
        ProjetDTO projet = projets.isEmpty() ? null : projets.get(idx);
        
        System.out.println("Index sélectionné: " + idx);
        System.out.println("Projet sélectionné: " + (projet != null ? projet.getNumeroProjet() : "null"));
        
        model.addAttribute("projets", projets);
        model.addAttribute("selectedProjet", projet);
        model.addAttribute("selectedProjetIndex", idx);
        
        // Rôle utilisateur (pour le JS)
        var authentication = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userRole = "ANONYMOUS";
        String userName = "";
        if (authentication != null && authentication.isAuthenticated() && authentication.getAuthorities() != null && !authentication.getAuthorities().isEmpty()) {
            String authority = authentication.getAuthorities().iterator().next().getAuthority();
            userRole = authority.startsWith("ROLE_") ? authority.substring(5) : authority;
            String email = authentication.getName();
            // Cherche le User en base pour récupérer le vrai nom d'utilisateur
            Optional<com.example.Springboot.model.User> userOpt = authService.findUserByEmail(email);
            if (userOpt.isPresent()) {
                userName = userOpt.get().getUsername(); // ou getNomUtilisateur() selon ton modèle
            } else {
                userName = email; // fallback
            }
        }
        
        System.out.println("Rôle utilisateur: " + userRole);
        System.out.println("Nom utilisateur: " + userName);
        model.addAttribute("userRole", userRole);
        model.addAttribute("userName", userName);
        
        System.out.println("=== FIN DEBUG DASHBOARD ===");
        return "dashboard";
    }
} 