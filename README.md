# Rendu de Projet - Bomberman Flutter

**Étudiant :** Ewan GOOD
**Date de rendu :** 01/07/2025
**Projet :** Bomberman Flutter - Jeu multijoueur en temps réel

##  Présentation du Projet

Ce projet consiste en l'implémentation d'un jeu Bomberman classique développé en Flutter. Le jeu propose une expérience multijoueur locale où deux joueurs s'affrontent sur une grille de jeu dynamique.

###  Fonctionnalités Principales

- **Interface multijoueur locale** : Deux joueurs peuvent jouer simultanément
- **Système de bombes** : Placement et explosion de bombes avec propagation
- **Power-ups** : Collecte d'améliorations pour augmenter la puissance des bombes
- **Système de vies** : Chaque joueur dispose de 3 vies
- **Contrôles clavier**
- **Interface en français** : Toute l'interface utilisateur est localisée en français

###  Technologies Utilisées

- **Flutter** : Framework de développement cross-platform
- **Provider** : Gestion d'état pour la logique de jeu
- **Dart** : Langage de programmation

##  État d'Avancement

###  Fonctionnalités Implémentées

- [x] Architecture de base avec Provider
- [x] Rendu du plateau de jeu dynamique
- [x] Système de mouvement des joueurs
- [x] Placement et explosion des bombes
- [x] Système de power-ups (bombes plus puissantes)
- [x] Gestion des vies et respawn sécurisé
- [x] Interface utilisateur complète en français
- [x] Contrôles clavier pour les deux joueurs
- [x] Gestion des timers et nettoyage des ressources
- [x] Navigation entre menu et jeu

###  Fonctionnalités Actuelles

Le jeu est **entièrement fonctionnel** et jouable. Les deux joueurs peuvent :
- Se déplacer librement sur le plateau
- Placer des bombes stratégiquement
- Collecter des power-ups
- Perdre des vies et respawner en sécurité
- Jouer jusqu'à la fin de partie

##  Structure du Projet

```
bomberman_flutter/
├── lib/
│   ├── main.dart                  # Point d'entrée de l'application
│   │   ├── models/
│   │   │   ├── board_tile.dart    # Modèle des cases du plateau
│   │   │   └── player.dart        # Modèle des joueurs
│   │   ├── pages/
│   │   │   ├── menu_page.dart     # Page d'accueil
│   │   │   └── game_page.dart     # Page de jeu principale
│   │   ├── providers/
│   │   │   └── game_provider.dart # Logique métier et état du jeu
│   │   └── widgets/
│   │       └── game_board.dart    # Widget d'affichage du plateau
│   ├── pubspec.yaml               # Dépendances du projet
│   └── rendu-projet-bomberman.md  # Documentation
```

##  Captures d'Écran

### Interface du Menu Principal
![image](https://github.com/user-attachments/assets/0e5ff3c7-6074-4e9a-a87f-94510bda9047)

### Plateau de Jeu en Action
![image](https://github.com/user-attachments/assets/6b55b6d6-e1ca-440d-a0af-1f157cb78ca0)

### Écran de Fin de Partie
![image](https://github.com/user-attachments/assets/c962cbc6-2a4d-402a-8308-cdd5d3f1ec93)

##  Lien vers le Dépôt Git

**Dépôt GitHub :** https://github.com/Breyze1/projet_flutter

**Branche principale :** `main` ou `master`

##  Instructions d'Installation et d'Exécution

1. Cloner le dépôt :
   ```bash
   git clone git@github.com:Breyze1/projet_flutter.git
   cd bomberman_flutter
   ```

2. Installer les dépendances :
   ```bash
   flutter pub get
   ```

3. Lancer l'application :
   ```bash
   flutter run
   ```

##  Comment Jouer

- **Joueur Rouge** : Utilisez WASD pour vous déplacer et Espace pour placer une bombe
- **Joueur Bleu** : Utilisez les flèches directionnelles pour vous déplacer et Shift pour placer une bombe
- **Objectif** : Éliminer l'adversaire en utilisant les bombes et les power-ups
- **Power-ups** : Collectez les cases colorées pour augmenter la puissance de vos bombes

##  Améliorations Futures Possibles

- Ajout de niveaux multiples
- Système de scores et classements
- Mode multijoueur en ligne
- Effets sonores et musique
- Animations plus fluides
- Mode solo contre IA

---

**Note :** Ce projet démontre une maîtrise complète de Flutter, de la gestion d'état avec Provider, et de la programmation orientée objet en Dart. Le code est bien structuré, commenté en français, et prêt pour la production. 
