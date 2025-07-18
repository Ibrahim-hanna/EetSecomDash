package com.example.Springboot.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.Springboot.service.WebSocketNotificationService;
import java.util.Map;
import java.util.HashMap;

@Controller
public class WebSocketTestController {
    
    @Autowired
    private WebSocketNotificationService webSocketNotificationService;
    
    /**
     * Endpoint pour tester les WebSockets
     */
    @GetMapping("/api/websocket/test")
    @ResponseBody
    public Map<String, Object> testWebSocket() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Test WebSocket réussi");
        response.put("timestamp", System.currentTimeMillis());
        
        // Envoyer une notification de test via WebSocket
        webSocketNotificationService.sendTestMessage();
        
        return response;
    }
    
    /**
     * Endpoint pour forcer une mise à jour de la liste des projets
     */
    @GetMapping("/api/websocket/notify-projets-update")
    @ResponseBody
    public Map<String, Object> notifyProjetsUpdate() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Notification de mise à jour des projets envoyée");
        response.put("timestamp", System.currentTimeMillis());
        
        // Envoyer une notification de mise à jour
        webSocketNotificationService.notifyProjetsListUpdate();
        
        return response;
    }
    
    /**
     * Gestionnaire de messages WebSocket pour les tests
     */
    @MessageMapping("/test")
    @SendTo("/topic/updates")
    public Map<String, Object> handleTestMessage(Map<String, Object> message) {
        Map<String, Object> response = new HashMap<>();
        response.put("type", "TEST_RESPONSE");
        response.put("originalMessage", message);
        response.put("serverTime", System.currentTimeMillis());
        response.put("message", "Message reçu et traité par le serveur");
        
        return response;
    }
} 