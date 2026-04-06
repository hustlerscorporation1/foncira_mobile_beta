# 🏘️ FONCIRA — Tunnel de Vérification Complet (7 Étapes)

## 📋 Vue d'ensemble

Tunnel de vérification foncière **post-clic sur "Demander une vérification"** et **"Terrain externe"**.  
Tout en **un seul fichier** (`verification_tunnel_page.dart`) avec navigation fluide et états internes.

---

## 🚀 Accès

| Route                      | Déclencheur                                               |
| -------------------------- | --------------------------------------------------------- |
| `VerificationTunnelPage()` | Clic sur "Terrain externe" dans `RequestVerificationPage` |
| Navigation fluide interne  | 7 étapes gérées par `currentStep`                         |

---

## 📱 Les 7 Étapes

### **ÉTAPE 1 — Formulaire** ✍️

**Fichier interne :** `_Step1Form`

- **3 champs uniquement :** Prénom, WhatsApp, Pays
- **Design :** Chaleureux, minimaliste, sans administratif
- **Validations :** Tous les champs obligatoires
- **CTA :** "Envoyer ma demande →"
- **Effet :** Simulation 2s de chargement avant confirmation

---

### **ÉTAPE 2 — Confirmation** ✅

**Fichier interne :** `_Step2Confirmation`

- **Affichage automatique** après soumission
- **Contenu personnalisé :**
  - Prénom du client
  - Agent fictif assigné : **Kofi Mensah**
  - Délai annoncé : **7-10 jours**
  - Prochaines étapes numérotées (4 jalons)
- **Ton :** Humain, rassurant, encourageant
- **CTA :** "Continuer vers le paiement →"

---

### **ÉTAPE 3 — Paiement** 💳

**Fichier interne :** `_Step3Payment`

- **Méthodes disponibles :**
  - Mobile Money (MTN + Moov)
  - Carte bancaire (Visa/Mastercard)
- **Garantie visible en gras :**
  > "Votre argent est bloqué jusqu'à la livraison du rapport.  
  > Si on ne livre pas, vous êtes remboursé automatiquement."
- **Montant :** 15 000 F CFA
- **Pas de renvoi vers CGU** — promesse affichée directement
- **Sélection requise :** Validation avant paiement

---

### **ÉTAPE 4 — Tableau de Bord** 📊

**Fichier interne :** `_Step4Dashboard`

- **Barre de progression visuelle**
- **3 phases avec horodatage :**
  1. ✅ **J1 — Vérification cadastrale** : Documents officiels validés
  2. 📸 **J3 — Visite terrain** : Photos et relevés géolocalisés
  3. 🏛️ **J7 — Vérification coutumière** : Reconnaissance locale confirmée
- **Auto-progression** : Les phases avancent automatiquement (3s chacune)
- **Ton proactif :** "On te notifiera dès qu'il y a une mise à jour"

---

### **ÉTAPE 5 — Rapport** 📄

**Fichier interne :** `_Step5Report`

- **Verdict immédiat** (tiré aléatoirement pour démo) :
  - 🟢 **Risque faible** → "Tu peux y aller !"
  - 🟡 **Risque modéré** → "Quelques points à vérifier"
  - 🔴 **Risque élevé** → "Pas recommandé pour l'instant"
- **Détails dépliables** (cliquer "Voir les détails")
- **Si risque élevé :**
  - Message valorisant
  - 3 alternatives proposées
- **Bouton télécharger** le rapport (non fonctionnel, simulé)
- **CTA :** "Continuer →"

---

### **ÉTAPE 6 — Décision** 🎯

**Fichier interne :** `_Step6Decision`

- **3 options cliquables :**
  1. ✅ **"Je veux acheter ce terrain"**
     - → Upsell modal : procuration + notaire
  2. 📋 **"Je veux un accompagnement"**
     - → Upsell modal : aide administrative
  3. ⏰ **"Pas maintenant"**
     - → Modal avec 2 terrains alternatifs vérifiés
- **Chaque option** ouvre un modal avec suite logique

---

### **ÉTAPE 7 — Parrainage** 🎁

**Fichier interne :** `_Step7Referral`

- **N'apparaît qu'après satisfaction confirmée**
- **Feedback demandé :**
  - Satisfaction : 😍 Très satisfait / 😐 Moyen / 😞 Non satisfait
  - "Qu'as-tu aimé ?"
  - "Qu'est-ce qui ne t'a pas plu ?"
  - "Comment on peut s'améliorer ?"
- **Si feedback envoyé :**
  - Génération d'un code de parrainage personnalisé (format `FON######`)
  - Affichage du code avec copie facile
  - Message d'incitation : **"Tu gagnes 25 000 F CFA pour chaque ami"**
  - Bouton : "Partager sur WhatsApp →"

---

## 🎨 Style Visuel (Respecté)

| Élement              | Valeur                                         |
| -------------------- | ---------------------------------------------- |
| **Couleur primaire** | #0A6847 (vert FONCIRA)                         |
| **Accent**           | #C8A951 (or)                                   |
| **Info/Bleu**        | #3B82F6                                        |
| **Fond**             | #0B1215 (gris foncé)                           |
| **Cartes**           | #141E22                                        |
| **Typographie**      | Google Fonts : Outfit (titres) + Inter (texte) |
| **Thème**            | Dark mode (cohérent avec l'app)                |
| **Boutons**          | Gradient vert (kGradientCTA)                   |
| **Bordures**         | Rayon 14-18px, légères                         |

---

## ⚙️ Architecture Interne

```
VerificationTunnelPage (StatefulWidget)
├── État global
│   ├── currentStep (1-7)
│   ├── Form data : firstName, whatsapp, country
│   ├── Payment state
│   ├── Progress phase (0-2)
│   └── Feedback & referral code
│
├── Navigation
│   ├── WillPopScope : retour arrière entre étapes
│   ├── AnimatedSwitcher : transition fade
│   └── Gestion d'état interne : setState()
│
└── Composants:
    ├── _Step1Form
    ├── _Step2Confirmation
    ├── _Step3Payment
    ├── _Step4Dashboard
    ├── _Step5Report
    ├── _Step6Decision
    └── _Step7Referral
```

---

## 🔄 Navigation & States

| Transition | Trigger                           | Effet             | Délai         |
| ---------- | --------------------------------- | ----------------- | ------------- |
| 1 → 2      | Clic "Envoyer ma demande"         | Confirmation auto | 2s chargement |
| 2 → 3      | Clic "Continuer vers le paiement" | Immédiat          | —             |
| 3 → 4      | Paiement validé                   | Dashboard affiche | 1s chargement |
| 4 → 5      | Phases terminées (J7)             | Auto-passage      | 2s après fin  |
| 5 → 6      | Clic "Continuer"                  | Décision          | —             |
| 6 → 7      | Choix + upsell accepté            | Parrainage        | —             |
| ← (retour) | Clic back                         | Étape précédente  | —             |

---

## 📊 Données Fictives (_Hard-coded_)

### Agent assigné

```dart
final String agentName = 'Kofi Mensah';
final int delayDays = 10;
```

### Délai et étapes

```dart
final List<String> nextSteps = [
  'Validation de votre demande',
  'Vérification cadastrale (J1-J3)',
  'Visite terrain et photos (J4-J6)',
  'Rapport final et verdict (J7-J10)',
];
```

### Phases de progression

```
J1 : Cadastrale (📋)
J3 : Terrain + photos (📸)
J7 : Coutumière (🏛️)
```

### Risques (aléatoires)

```dart
risk = ['low', 'medium', 'high'][DateTime.now().millisecond % 3];
```

---

## ✨ Fonctionnalités Clés

### ✅ Mobile Money & Carte Bancaire

- Sélection visuelle claire
- Validation avant paiement

### ✅ Garantie de Remboursement

- **En gras sur l'écran de paiement**
- Pas d'envoi vers CGU
- Message directement intégré

### ✅ Progression Auto

- 3 phases s'affichent et avancent automatiquement
- Jalons horodatés
- Transition fluide vers le rapport

### ✅ Verdict Intelligent

- Aléatoire (pour démo)
- Couleur + emoji + sentiment
- Alternatives en cas de risque élevé

### ✅ Upsell Contextualisé

- Modal + message personnalisé
- Option "Plus tard"
- Alternatives terrains si "Pas maintenant"

### ✅ Parrainage Personnalisé

- Code généré après feedback
- Format `FON######`
- Partage WhatsApp

---

## 🔧 Intégration

### Depuis `RequestVerificationPage`

```dart
// Clic sur "Terrain externe"
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const VerificationTunnelPage(),
  ),
);
```

### Récupération de données (future API)

**Actuellement :** Données fictives hard-coded  
**Pour l'API :** Remplacer les valeurs ou appeler des endpoints

---

## 📝 Notes

- ✅ **Responsive mobile-first** : Adapté à tous les écrans
- ✅ **Navigation fluide** : Retour possible entre étapes
- ✅ **État interne** : Pas d'API, tout en local
- ✅ **Un seul fichier** : Facile à maintenir et déployer
- ✅ **Style visuel cohérent** : Palette FONCIRA respectée strictement

---

## 🚀 Prochaines Étapes

1. **Connecter à une API réelle** → Remplacer données fictives
2. **Intégrer paiement** → MTN API + Stripe/Square
3. **Notifications WhatsApp** → Confirmations automatiques
4. **Téléchargement rapport** → PDF généré backend
5. **Analytics** → Tracker les conversions par étape

---

**Créé pour :** FONCIRA — Vérification foncière au Togo  
**Version :** 1.0  
**Date :** Avril 2026
