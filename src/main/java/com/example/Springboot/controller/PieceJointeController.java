package com.example.Springboot.controller;

import com.example.Springboot.service.ProjetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;

@Controller
@RequestMapping("/api/pieces-jointes")
public class PieceJointeController {

    @Autowired
    private ProjetService projetService;

    private static final String UPLOAD_DIR = "uploads/";

    @PostMapping
    public ResponseEntity<?> ajouterPieceJointe(
            @RequestParam("projetId") Long projetId,
            @RequestParam("type") String type,
            @RequestParam(value = "fichier", required = false) MultipartFile fichier,
            @RequestParam(value = "nomFichier", required = false) String nomFichier,
            @RequestParam(value = "description", required = false) String description) {
        
        try {
            // Vérifier les autorisations
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String userRole = auth.getAuthorities().stream()
                    .findFirst()
                    .map(Object::toString)
                    .orElse("");
            
            if (!userRole.contains("ADMIN") && !userRole.contains("SUPERVISEUR")) {
                return ResponseEntity.status(403).body("Accès non autorisé");
            }

            String filename;
            
            // Si un nouveau fichier est fourni, le traiter
            if (fichier != null && !fichier.isEmpty()) {
                // Créer le répertoire d'upload s'il n'existe pas
                Path uploadPath = Paths.get(UPLOAD_DIR);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }

                // Générer un nom de fichier unique
                String originalFilename = fichier.getOriginalFilename();
                String extension = "";
                if (originalFilename != null && originalFilename.contains(".")) {
                    extension = originalFilename.substring(originalFilename.lastIndexOf("."));
                }
                filename = UUID.randomUUID().toString() + extension;

                // Sauvegarder le fichier
                Path filePath = uploadPath.resolve(filename);
                Files.copy(fichier.getInputStream(), filePath);
            } else if (nomFichier != null && !nomFichier.trim().isEmpty()) {
                // Modification d'une pièce jointe existante sans nouveau fichier
                filename = nomFichier.trim();
                System.out.println("DEBUG - Utilisation du nom de fichier fourni: " + filename);
            } else {
                // Pour les modifications de description uniquement, on doit récupérer le nom du fichier existant
                // depuis la base de données
                System.out.println("DEBUG - Récupération du nom de fichier depuis la base de données pour le type: " + type);
                try {
                    var projetOpt = projetService.getProjetById(projetId);
                    if (projetOpt.isPresent()) {
                        var projet = projetOpt.get();
                        switch (type) {
                            case "contrat":
                                filename = projet.getContratPieceJointe();
                                break;
                            case "pvReceptionProvisoire":
                                filename = projet.getPvReceptionProvisoire();
                                break;
                            case "pvReceptionDefinitive":
                            case "pvReceptionDefinitif":
                                filename = projet.getPvReceptionDefinitif();
                                break;
                            case "attestationReference":
                                filename = projet.getAttestationReference();
                                break;
                            case "suivi_execution_detaille":
                                filename = projet.getSuiviExecutionDetaillePieceJointe();
                                break;
                            case "suivi_reglement_detaille":
                                filename = projet.getSuiviReglementDetaillePieceJointe();
                                break;
                            default:
                                return ResponseEntity.badRequest().body("Type de pièce jointe non reconnu: " + type);
                        }
                        
                        System.out.println("DEBUG - Nom de fichier récupéré depuis la base: " + filename);
                        
                        if (filename == null || filename.trim().isEmpty()) {
                            return ResponseEntity.badRequest().body("Aucune pièce jointe existante trouvée pour le type: " + type);
                        }
                    } else {
                        return ResponseEntity.badRequest().body("Projet non trouvé avec l'ID: " + projetId);
                    }
                } catch (Exception e) {
                    System.out.println("DEBUG - Exception lors de la récupération du projet: " + e.getMessage());
                    return ResponseEntity.status(500).body("Erreur lors de la récupération du projet: " + e.getMessage());
                }
            }

            // Mettre à jour le projet avec la nouvelle pièce jointe
            System.out.println("DEBUG - Ajout/Modification pièce jointe: projetId=" + projetId + ", type=" + type + ", filename=" + filename + ", description=" + description);
            boolean success = projetService.ajouterPieceJointe(projetId, type, filename, description);
            
            if (success) {
                System.out.println("DEBUG - Pièce jointe ajoutée/modifiée avec succès");
                return ResponseEntity.ok().body("Pièce jointe enregistrée avec succès");
            } else {
                System.out.println("DEBUG - Erreur lors de l'ajout/modification de la pièce jointe");
                return ResponseEntity.badRequest().body("Erreur lors de l'enregistrement de la pièce jointe");
            }

        } catch (IOException e) {
            return ResponseEntity.status(500).body("Erreur lors du traitement du fichier: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Erreur serveur: " + e.getMessage());
        }
    }

    @GetMapping("/files/{filename}")
    public ResponseEntity<?> telechargerFichier(@PathVariable String filename) {
        try {
            Path filePath = Paths.get(UPLOAD_DIR).resolve(filename);
            if (Files.exists(filePath)) {
                String mimeType = Files.probeContentType(filePath);
                if (mimeType == null) {
                    mimeType = "application/octet-stream";
                }
                byte[] fileContent = Files.readAllBytes(filePath);
                return ResponseEntity.ok()
                        .header("Content-Disposition", "inline; filename=\"" + filename + "\"")
                        .header("Content-Type", mimeType)
                        .body(fileContent);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Erreur lors du téléchargement du fichier");
        }
    }

    @GetMapping("/preview/{filename}")
    public ResponseEntity<byte[]> previewPdfAsImage(@PathVariable String filename) {
        try {
            Path pdfPath = Paths.get(UPLOAD_DIR).resolve(filename);
            if (!Files.exists(pdfPath)) {
                return ResponseEntity.notFound().build();
            }
            try (PDDocument document = PDDocument.load(pdfPath.toFile())) {
                PDFRenderer pdfRenderer = new PDFRenderer(document);
                BufferedImage bim = pdfRenderer.renderImageWithDPI(0, 150); // première page, 150 DPI
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ImageIO.write(bim, "png", baos);
                return ResponseEntity.ok()
                        .header("Content-Type", "image/png")
                        .body(baos.toByteArray());
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }

    @DeleteMapping("/{projetId}/{type}")
    public ResponseEntity<?> supprimerPieceJointe(@PathVariable Long projetId, @PathVariable String type) {
        boolean ok = projetService.supprimerPieceJointe(projetId, type);
        if (ok) return ResponseEntity.ok().build();
        return ResponseEntity.status(500).body("Erreur lors de la suppression");
    }
} 