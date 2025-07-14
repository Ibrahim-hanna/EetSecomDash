package com.example.Springboot.dto;

import com.example.Springboot.model.Role;

public class AuthResponse {
    
    private String token;
    private String email;
    private Role role;
    private String message;
    
    // Constructeurs
    public AuthResponse() {}
    
    public AuthResponse(String token, String email, Role role) {
        this.token = token;
        this.email = email;
        this.role = role;
    }
    
    public AuthResponse(String message) {
        this.message = message;
    }
    
    // Getters et Setters
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public Role getRole() {
        return role;
    }
    
    public void setRole(Role role) {
        this.role = role;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
} 