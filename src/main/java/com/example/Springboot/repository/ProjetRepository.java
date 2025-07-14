package com.example.Springboot.repository;

import com.example.Springboot.model.Projet;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ProjetRepository extends JpaRepository<Projet, Long> {
    Optional<Projet> findByNumeroProjet(String numeroProjet);
} 