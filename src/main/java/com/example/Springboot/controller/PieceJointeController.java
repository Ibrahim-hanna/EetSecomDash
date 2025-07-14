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
            @RequestParam("fichier") MultipartFile fichier,
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
            String filename = UUID.randomUUID().toString() + extension;

            // Sauvegarder le fichier
            Path filePath = uploadPath.resolve(filename);
            Files.copy(fichier.getInputStream(), filePath);

            // Mettre à jour le projet avec la nouvelle pièce jointe
            System.out.println("DEBUG - Ajout pièce jointe: projetId=" + projetId + ", type=" + type + ", filename=" + filename);
            boolean success = projetService.ajouterPieceJointe(projetId, type, filename, description);
            
            if (success) {
                System.out.println("DEBUG - Pièce jointe ajoutée avec succès");
                return ResponseEntity.ok().body("Pièce jointe ajoutée avec succès");
            } else {
                System.out.println("DEBUG - Erreur lors de l'ajout de la pièce jointe");
                return ResponseEntity.badRequest().body("Erreur lors de l'ajout de la pièce jointe");
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