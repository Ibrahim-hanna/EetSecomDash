package com.example.Springboot.service;

import com.example.Springboot.dto.AuthResponse;
import com.example.Springboot.dto.LoginRequest;
import com.example.Springboot.dto.RegisterRequest;
import com.example.Springboot.model.Role;
import com.example.Springboot.model.User;
import com.example.Springboot.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Optional;

@Service
public class AuthService implements UserDetailsService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtService jwtService;
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    public AuthResponse register(RegisterRequest request) {
        // Vérifier si l'email existe déjà
        if (userRepository.existsByEmail(request.getEmail())) {
            return new AuthResponse("L'email existe déjà");
        }
        
        // Créer un nouvel utilisateur
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole());
        
        userRepository.save(user);
        
        // Générer le token JWT
        String token = jwtService.generateToken(loadUserByUsername(user.getEmail()));
        
        return new AuthResponse(token, user.getEmail(), user.getRole());
    }
    
    public AuthResponse login(LoginRequest request) {
        try {
            // Authentifier l'utilisateur
            authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );
            
            // Récupérer l'utilisateur
            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé"));
            
            // Générer le token JWT
            String token = jwtService.generateToken(loadUserByUsername(user.getEmail()));
            
            return new AuthResponse(token, user.getEmail(), user.getRole());
            
        } catch (Exception e) {
            return new AuthResponse("Email ou mot de passe incorrect");
        }
    }
    
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé avec l'email: " + email));
        
        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities("ROLE_" + user.getRole().name())
                .build();
    }

    public Optional<User> findUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }
} 