// Script pour le rechargement automatique et les notifications WebSocket
class AutoReloadManager {
    constructor() {
        this.stompClient = null;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
        this.reconnectDelay = 2000;
        this.isConnected = false;
        this.updateCallbacks = new Map();
        
        this.init();
    }
    
    init() {
        this.setupLiveReload();
        this.setupWebSocket();
        this.setupPeriodicRefresh();
    }
    
    // Configuration du rechargement automatique avec LiveReload
    setupLiveReload() {
        // Vérifier si LiveReload est disponible (via Spring Boot DevTools)
        if (typeof window.LiveReload !== 'undefined') {
            console.log('LiveReload activé - Les modifications seront rechargées automatiquement');
        } else {
            console.log('LiveReload non disponible - Utilisation du rechargement périodique');
        }
    }
    
    // Configuration WebSocket pour les mises à jour en temps réel
    setupWebSocket() {
        try {
            // Charger SockJS et STOMP
            if (typeof SockJS !== 'undefined' && typeof Stomp !== 'undefined') {
                this.connectWebSocket();
            } else {
                console.log('SockJS/STOMP non disponibles - Chargement des scripts...');
                this.loadWebSocketScripts();
            }
        } catch (error) {
            console.error('Erreur lors de la configuration WebSocket:', error);
        }
    }
    
    loadWebSocketScripts() {
        // Charger SockJS
        const sockjsScript = document.createElement('script');
        sockjsScript.src = 'https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js';
        sockjsScript.onload = () => {
            // Charger STOMP
            const stompScript = document.createElement('script');
            stompScript.src = 'https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js';
            stompScript.onload = () => {
                this.connectWebSocket();
            };
            document.head.appendChild(stompScript);
        };
        document.head.appendChild(sockjsScript);
    }
    
    connectWebSocket() {
        try {
            const socket = new SockJS('/ws');
            this.stompClient = Stomp.over(socket);
            
            this.stompClient.connect({}, 
                (frame) => {
                    console.log('Connecté au WebSocket:', frame);
                    this.isConnected = true;
                    this.reconnectAttempts = 0;
                    this.subscribeToUpdates();
                },
                (error) => {
                    console.error('Erreur de connexion WebSocket:', error);
                    this.isConnected = false;
                    this.scheduleReconnect();
                }
            );
        } catch (error) {
            console.error('Erreur lors de la connexion WebSocket:', error);
        }
    }
    
    subscribeToUpdates() {
        if (!this.stompClient || !this.isConnected) return;
        
        // S'abonner aux mises à jour générales
        this.stompClient.subscribe('/topic/updates', (message) => {
            try {
                const update = JSON.parse(message.body);
                this.handleUpdate(update);
            } catch (error) {
                console.error('Erreur lors du traitement du message WebSocket:', error);
            }
        });
        
        // S'abonner aux mises à jour des projets
        this.stompClient.subscribe('/topic/projets', (message) => {
            try {
                const data = JSON.parse(message.body);
                this.handleProjetUpdate(data);
            } catch (error) {
                console.error('Erreur lors du traitement de la mise à jour projet:', error);
            }
        });
    }
    
    handleUpdate(update) {
        console.log('Mise à jour reçue:', update);
        
        switch (update.type) {
            case 'PROJET_UPDATE':
                this.handleProjetUpdate(update.data);
                break;
            case 'PROJETS_LIST_UPDATE':
                this.refreshProjetsList();
                break;
            case 'TEST':
                console.log('Test WebSocket reçu:', update.data);
                break;
            default:
                console.log('Type de mise à jour non géré:', update.type);
        }
        
        // Notifier les callbacks enregistrés
        if (this.updateCallbacks.has(update.type)) {
            this.updateCallbacks.get(update.type).forEach(callback => {
                try {
                    callback(update.data);
                } catch (error) {
                    console.error('Erreur dans le callback:', error);
                }
            });
        }
    }
    
    handleProjetUpdate(data) {
        console.log('Mise à jour projet:', data);
        
        // Recharger la liste des projets si nécessaire
        if (window.location.pathname.includes('/dashboard') || 
            window.location.pathname.includes('/projets')) {
            this.refreshProjetsList();
        }
        
        // Afficher une notification
        this.showNotification(`Projet ${data.action.toLowerCase()}`);
    }
    
    refreshProjetsList() {
        // Recharger la page ou mettre à jour le contenu
        if (typeof window.refreshProjetsData === 'function') {
            window.refreshProjetsData();
        } else {
            // Fallback: recharger la page
            setTimeout(() => {
                window.location.reload();
            }, 1000);
        }
    }
    
    showNotification(message) {
        // Créer une notification toast
        const toast = document.createElement('div');
        toast.className = 'toast-notification';
        toast.innerHTML = `
            <div class="toast-content">
                <span>${message}</span>
                <button onclick="this.parentElement.parentElement.remove()">&times;</button>
            </div>
        `;
        
        // Styles pour la notification
        toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #28a745;
            color: white;
            padding: 12px 20px;
            border-radius: 4px;
            z-index: 9999;
            animation: slideIn 0.3s ease;
        `;
        
        document.body.appendChild(toast);
        
        // Supprimer automatiquement après 3 secondes
        setTimeout(() => {
            if (toast.parentElement) {
                toast.remove();
            }
        }, 3000);
    }
    
    scheduleReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            console.log(`Tentative de reconnexion ${this.reconnectAttempts}/${this.maxReconnectAttempts} dans ${this.reconnectDelay}ms`);
            
            setTimeout(() => {
                this.connectWebSocket();
            }, this.reconnectDelay);
        } else {
            console.error('Nombre maximum de tentatives de reconnexion atteint');
        }
    }
    
    // Configuration du rechargement périodique (fallback)
    setupPeriodicRefresh() {
        // Recharger la page toutes les 30 secondes si pas de WebSocket
        setInterval(() => {
            if (!this.isConnected) {
                console.log('Rechargement périodique - WebSocket non connecté');
                window.location.reload();
            }
        }, 30000);
    }
    
    // API publique pour enregistrer des callbacks
    onUpdate(type, callback) {
        if (!this.updateCallbacks.has(type)) {
            this.updateCallbacks.set(type, []);
        }
        this.updateCallbacks.get(type).push(callback);
    }
    
    // Envoyer un message de test
    sendTestMessage() {
        if (this.stompClient && this.isConnected) {
            this.stompClient.send("/app/test", {}, JSON.stringify({message: "Test client"}));
        }
    }
    
    // Déconnexion
    disconnect() {
        if (this.stompClient) {
            this.stompClient.disconnect();
        }
    }
}

// Initialiser le gestionnaire de rechargement automatique
document.addEventListener('DOMContentLoaded', () => {
    window.autoReloadManager = new AutoReloadManager();
    
    // Exposer des fonctions globales pour les tests
    window.testWebSocket = () => {
        if (window.autoReloadManager) {
            window.autoReloadManager.sendTestMessage();
        }
    };
    
    window.disconnectWebSocket = () => {
        if (window.autoReloadManager) {
            window.autoReloadManager.disconnect();
        }
    };
});

// Styles CSS pour les animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    .toast-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    
    .toast-content button {
        background: none;
        border: none;
        color: white;
        font-size: 18px;
        cursor: pointer;
        margin-left: 10px;
    }
`;
document.head.appendChild(style); 