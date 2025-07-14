package com.example.Springboot.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/employe")
@CrossOrigin(origins = "*")
public class EmployeController {
    
    @GetMapping("/dashboard")
    public ResponseEntity<String> getEmployeDashboard() {
        return ResponseEntity.ok("Dashboard Employé - Accès autorisé");
    }
    
    @GetMapping("/tasks")
    public ResponseEntity<String> getTasks() {
        return ResponseEntity.ok("Tâches de l'employé - Accès employé");
    }
} 