package com.example.Springboot.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.HashMap;

@Service
public class WebSocketNotificationService {
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    /**
     * Envoie une notification de mise à jour à tous les clients connectés
     */
    public void notifyUpdate(String type, Object data) {
        try {
            Map<String, Object> message = new HashMap<>();
            message.put("type", type);
            message.put("data", data);
            message.put("timestamp", System.currentTimeMillis());
            
            messagingTemplate.convertAndSend("/topic/updates", message);
            System.out.println("DEBUG - WebSocket: Notification envoyée - Type: " + type);
        } catch (Exception e) {
            System.err.println("Erreur lors de l'envoi de la notification WebSocket: " + e.getMessage());
        }
    }
    
    /**
     * Notifie la mise à jour d'un projet spécifique
     */
    public void notifyProjetUpdate(Long projetId, String action) {
        Map<String, Object> data = new HashMap<>();
        data.put("projetId", projetId);
        data.put("action", action);
        notifyUpdate("PROJET_UPDATE", data);
    }
    
    /**
     * Notifie la création d'un nouveau projet
     */
    public void notifyProjetCreated(Long projetId) {
        notifyProjetUpdate(projetId, "CREATED");
    }
    
    /**
     * Notifie la modification d'un projet
     */
    public void notifyProjetModified(Long projetId) {
        notifyProjetUpdate(projetId, "MODIFIED");
    }
    
    /**
     * Notifie la suppression d'un projet
     */
    public void notifyProjetDeleted(Long projetId) {
        notifyProjetUpdate(projetId, "DELETED");
    }
    
    /**
     * Notifie une mise à jour de la liste des projets
     */
    public void notifyProjetsListUpdate() {
        notifyUpdate("PROJETS_LIST_UPDATE", null);
    }
    
    /**
     * Envoie un message de test pour vérifier la connexion WebSocket
     */
    public void sendTestMessage() {
        Map<String, Object> data = new HashMap<>();
        data.put("message", "Test de connexion WebSocket");
        data.put("serverTime", System.currentTimeMillis());
        notifyUpdate("TEST", data);
    }
} 