# 🌱 AgroDiag AI

<p align="center">
  <img src="assets/images/logo.png" width="120" alt="AgroDiag AI Logo"/>
</p>

<p align="center">
  <strong>Application mobile intelligente de diagnostic des maladies des plantes</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/Groq-AI-orange?style=for-the-badge"/>
</p>

---

## 📱 À propos

**AgroDiag AI** est une application mobile développée avec Flutter qui permet aux agriculteurs de détecter rapidement les maladies de leurs plantes grâce à l'intelligence artificielle.

L'application analyse une photo de plante prise par l'utilisateur et fournit :
- 🔬 Un **diagnostic précis** de la maladie détectée
- 💊 Des **recommandations de traitement** adaptées
- 👨‍🌾 La possibilité de **contacter un agent agricole** spécialisé

---

## ✨ Fonctionnalités

| Fonctionnalité | Description |
|---|---|
| 🤖 Diagnostic IA | Analyse d'image par Groq AI pour détecter les maladies |
| 📷 Capture photo | Prise de photo ou sélection depuis la galerie |
| 👨‍🌾 Agents agricoles | Liste d'agents disponibles avec profil complet |
| 💬 Messagerie temps réel | Chat entre agriculteurs et agents via Firestore |
| 📊 Historique | Suivi de tous les diagnostics effectués |
| 🤖 Assistant virtuel | Chatbot agricole intégré |
| 👤 Profil utilisateur | Photo de profil, stats, complétion de profil |
| 🔐 Authentification | Inscription/connexion sécurisée via Firebase Auth |
| 🌿 Conseil du jour | Conseil agricole qui change chaque jour |

---

## 🛠️ Technologies utilisées

- **Frontend** : Flutter (Dart)
- **Backend** : Python FastAPI (hébergé sur Render)
- **Base de données** : Cloud Firestore (Firebase)
- **Authentification** : Firebase Authentication
- **Intelligence Artificielle** : Groq API
- **Stockage** : Firebase Firestore

---

## 📂 Structure du projet
---

## 🚀 Installation

### Prérequis
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Android Studio ou VS Code
- Compte Firebase

### Étapes

1. **Cloner le repo**
```bash
git clone https://github.com/NolaneDalhin/agrodiag-ai.git
cd agrodiag-ai
