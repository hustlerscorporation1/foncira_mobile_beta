# Schéma Base de Données FONCIRA - Documentation Complète

## Vue d'ensemble

Ce schéma PostgreSQL/Supabase couvre l'intégralité de l'application FONCIRA, transformant une app statique en plateforme dynamique avec backend complet.

**Statistiques du schéma :**

- 11 tables principales + 3 views
- 70+ index performants
- RLS (Row Level Security) sur toutes les tables
- 15 ENUMs PostgreSQL pour intégrité des données
- Test data cohérent pour 2 agents, 3 terrains, 2 clients, 1 vérification complète

---

## Architecture Générale

```
USERS (Clients + Agents + Admins)
  ├── AGENTS (agents vérificateurs)
  ├── VERIFICATIONS (tunnel complet)
  │   ├── VERIFICATION_DOCUMENTS (multiupload)
  │   ├── VERIFICATION_REPORTS (verdict final)
  │   └── VERIFICATION_MILESTONES (J1/J3/J7/J10)
  ├── PAYMENTS (paiements)
  ├── REFERRALS (parrainage)
  ├── NOTIFICATIONS (système de messages)
  └── TESTIMONIALS (témoignages)

TERRAINS_FONCIRA (marketplace)
  └── Lié aux VERIFICATIONS si vérification du marketplace
```

---

## Détail des Tables

### 1. USERS - Authentification et Profils

**Rôle :** Table centrale d'authentification et profils utilisateurs

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire, lié à auth.uid() Supabase |
| `email` | VARCHAR | Email unique pour login |
| `first_name` | VARCHAR | Prénom du client ou nom du agent |
| `phone_number` | VARCHAR | Numéro WhatsApp (+228...) |
| `country_code` | VARCHAR(3) | Code pays (TG par défaut) |
| `role` | ENUM | 'client', 'agent', 'admin' |
| `referral_code` | VARCHAR(10) | Code unique de parrain (ex: KOFI123) |
| `referral_balance` | NUMERIC | Montant en FCFA à verser au parrain |
| `is_active` | BOOLEAN | Compte actif/suspendu |

**Cas d'usage :**

- Connexion via Supabase Auth
- Profils clients avec leur historique
- Gestion des agents et accès

---

### 2. AGENTS - Vérificateurs de Terrain

**Rôle :** Profils détaillés des agents assignés aux vérifications

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `user_id` | UUID FK | Référence à l'utilisateur |
| `full_name` | VARCHAR | Nom complet de l'agent |
| `specialization` | VARCHAR | Domaine d'expertise |
| `verifications_completed` | INTEGER | Nombre de vérifications finalisées |
| `average_rating` | NUMERIC(3,2) | Note moyenne (ex: 4.8/5) |
| `is_available` | BOOLEAN | Agent libre ou occupé |
| `current_workload` | INTEGER | Nombre de vérifications en cours |
| `max_concurrent` | INTEGER | Max simultanées (ex: 5) |

**Relations :**

- ONE-TO-ONE avec users
- ONE-TO-MANY avec verifications (agent_id)
- ONE-TO-ONE avec verification_reports

---

### 3. TERRAINS_FONCIRA - Marketplace

**Rôle :** Annonces de terrains du marketplace FONCIRA

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `title` | VARCHAR | Titre annonce (ex: "500m² Kégué") |
| `location` | VARCHAR | Localisation complète |
| `ville` | VARCHAR | Ville (filtre important) |
| `price_fcfa` | NUMERIC | Prix en FCFA |
| `price_usd` | NUMERIC | Prix en USD (converti) |
| `surface` | NUMERIC | Surface en m² |
| `document_type` | ENUM | Type doc: titre_foncier, convention, aucun_document, etc. |
| `terrain_status` | ENUM | 'disponible', 'en_cours_vente', 'reserve' |
| `seller_type` | ENUM | 'agence' ou 'particulier' |
| `seller_name` | VARCHAR | Nom du vendeur |
| `verification_status` | VARCHAR | État de vérification (mapé d'une vérification associée) |
| `additional_photos` | JSONB | Array d'URLs photos |

**Cas d'usage :**

- Listing et filtrage du marketplace
- Affichage détail d'un terrain
- Trigger vérification depuis une annonce

---

### 4. VERIFICATIONS - Cœur du Tunnel

**Rôle :** Table pivot du tunnel de vérification complet

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `user_id` | UUID FK | Client demandeur |
| `terrain_id_foncira` | UUID FK | NULL si externe |
| `source` | ENUM | 'foncira_marketplace' \| 'externe' |
| `status` | ENUM | receptionnee → rapport_livre |
| `risk_level` | ENUM | 'faible', 'modere', 'eleve' |
| `terrain_title/location/price` | VARCHAR/NUMERIC | Capture snapshot du terrain |
| `external_location` | VARCHAR | Si externe: localisation saisie |
| `external_seller_contact` | VARCHAR | Si externe: contact vendeur |
| `sharing_link` | VARCHAR | Lien Facebook/WhatsApp partagé |
| `document_type` | ENUM | Type doc fourni (titre_foncier, etc.) |
| `agent_id` | UUID FK | Agent assigné (NULL initialement) |
| `expected_delivery_at` | TIMESTAMP | Date livraison prévue (now + 10j) |
| `actual_delivery_at` | TIMESTAMP | Date livraison réelle |
| `post_report_decision` | ENUM | Choix client: 'acheter'/'accompagnement'/'pas_maintenant' |

**État du tunnel :**

1. **receptionnee** - Infos collectées, paiement en attente
2. **pre_analyse** - Documents reçus, vérification initiale
3. **verification_administrative** - Vérif cadastrale en cours
4. **verification_terrain** - Visite terrain en cours
5. **analyse_finale** - Compilation du rapport
6. **rapport_livre** - Rapport livré au client

---

### 5. VERIFICATION_DOCUMENTS - Multiupload

**Rôle :** Stockage des documents uploadés par le client

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `verification_id` | UUID FK | Vérification associée |
| `file_name` | VARCHAR | Nom du fichier |
| `file_path` | VARCHAR | Path Supabase Storage (ex: buckets/uploads/...) |
| `file_type` | VARCHAR | 'PDF', 'JPG', 'PNG' |
| `document_category` | VARCHAR | 'titre', 'convention', 'recu', 'photo', 'autre' |
| `uploaded_by` | UUID FK | User qui a uploadé |

**RLS :** Accessible au client, à l'agent assigné, aux admins

---

### 6. VERIFICATION_REPORTS - Verdict Final

**Rôle :** Rapport de vérification remis au client

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `verification_id` | UUID FK UNIQUE | Une vérification = un rapport |
| `agent_id` | UUID FK | Agent rédacteur |
| `risk_level` | ENUM | 'faible', 'modere', 'eleve' |
| `verdict_summary` | VARCHAR | Résumé 1 ligne (ex: "Terrain conforme, faible risque") |
| `positive_points` | JSONB | Array de pointeurs positifs identifiés |
| `points_to_verify` | JSONB | Array de points d'attention |
| `alternative_terrains` | JSONB | Si risque élevé: terrains alternatifs proposés |
| `full_report_text` | TEXT | Rapport complet détaillé |

**Exemple de positive_points :**

```json
[
  "Un titre foncier est présent — c'est le document le plus solide qui existe au Togo.",
  "La convention signée prouve une intention d'achat formalisée.",
  "Bornes cadastrales conformes au plan officiel."
]
```

---

### 7. VERIFICATION_MILESTONES - Jalons J1/J3/J7/J10

**Rôle :** Suivi granulaire du workflow avec photos et messages

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `verification_id` | UUID FK | Vérification associée |
| `milestone_day` | INTEGER | 1, 3, 7, 10 |
| `milestone_name` | VARCHAR | Ex: "Vérification cadastrale" |
| `status` | ENUM | 'en_attente', 'en_cours', 'termine' |
| `started_at` | TIMESTAMP | Quand l'étape a commencé |
| `completed_at` | TIMESTAMP | Quand l'étape s'est terminée |
| `notes` | TEXT | Notes de l'agent (ex: "Bornes conformes") |
| `location_photos` | JSONB | Array d'URLs de photos horodatées |
| `gps_coordinates` | JSONB | {latitude, longitude} du terrain |
| `message_sent` | BOOLEAN | Notification envoyée oui/non |
| `message_content` | TEXT | Contenu du message proactif |

**Exemple message J3 :**

```
"J3 : Notre agent est allé sur le terrain ce matin. Voici 3 photos."
```

---

### 8. PAYMENTS - Paiements

**Rôle :** Traçabilité des paiements de vérification

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `verification_id` | UUID FK | Vérification payée |
| `user_id` | UUID FK | Client payeur |
| `amount_fcfa` | NUMERIC | Montant en FCFA (150,000 par défaut) |
| `amount_usd` | NUMERIC | Montant en USD (259 par défaut) |
| `payment_method` | ENUM | 'mobile_money' \| 'carte_bancaire' |
| `status` | ENUM | 'en_attente' → 'validee' \| 'echouee' \| 'remboursee' |
| `transaction_reference` | VARCHAR | Ref fournisseur (ex: MTN-20240104-0001) |
| `provider_response` | JSONB | Réponse complète du fournisseur |

---

### 9. REFERRAL_TRANSACTIONS - Parrainage

**Rôle :** Suivi des revenus de parrainage

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `referrer_id` | UUID FK | L'agent qui parraine |
| `referred_user_id` | UUID FK | Le nouveau client |
| `verification_id` | UUID FK | Vérification qui a généré le revenu |
| `amount_earned_fcfa` | NUMERIC | Montant gagné en FCFA |
| `amount_earned_usd` | NUMERIC | Montant en USD |
| `payment_status` | ENUM | 'en_attente' → 'validee' → versé |

---

### 10. NOTIFICATIONS - Système de Messages

**Rôle :** Notifications utilisateurs en temps réel

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `recipient_id` | UUID FK | Destinataire |
| `notification_type` | ENUM | 'verification_update', 'payment_confirmation', 'report_ready', 'systeme' |
| `title` | VARCHAR | Titre notification |
| `message` | TEXT | Corps du message |
| `related_verification_id` | UUID FK | Vérif associée (si applicable) |
| `is_read` | BOOLEAN | Lu/non lu |
| `action_url` | VARCHAR | Deep link (ex: /verifications/VR001) |

---

### 11. TESTIMONIALS - Témoignages

**Rôle :** Avis clients pour renforcer la confiance

**Colonnes clés :**
| Colonne | Type | Description |
|---------|------|-------------|
| `id` | UUID | Clé primaire |
| `user_id` | UUID FK | Auteur |
| `buyer_name` | VARCHAR | Nom acheteur affiché |
| `country_code` | VARCHAR(3) | Pays |
| `terrain_amount` | NUMERIC | Prix du terrain en FCFA |
| `risk_avoided` | VARCHAR | Niveau risque évité (ex: '25M FCFA') |
| `testimonial_text` | TEXT | Texte du témoignage |
| `is_published` | BOOLEAN | Visible publiquement oui/non |

---

## Row Level Security (RLS)

Chaque table active RLS avec les règles suivantes :

### Clients

- Voient **seulement** leurs propres vérifications
- Voient les agents assignés
- Voient leurs propres paiements/notifications
- Voient les terrains marketplace (publics)

### Agents

- Voient **seulement** les vérifications assignées
- Voient les documents de ces vérifications
- Peuvent créer/mettre à jour rapports
- Voient l'agent record (lecture seule) sauf le leur (lecture-écriture)

### Admins

- Voient **tout**
- Toutes les opérations

### Terrains Marketplace

- Publics pour lecture
- Admins uniquement pour création/modification

---

## Types ENUM Importants

### `verification_status` (6 états)

```
receptionnee → pre_analyse → verification_administrative
→ verification_terrain → analyse_finale → rapport_livre
```

### `risk_level` (3 niveaux)

```
faible (🟢) | modere (🟡) | eleve (🔴)
```

### `document_type` (6 types)

```
titre_foncier | logement | convention | recu_vente |
aucun_document | ne_sais_pas
```

### `verification_source` (2 sources)

```
foncira_marketplace | externe
```

---

## Indexes Critiques

Les indexes les plus importants pour les requêtes fréquentes :

1. **Vérifications par client :** `idx_verifications_user_id`
2. **Vérifications par agent :** `idx_verifications_agent_id`
3. **Vérifications par statut :** `idx_verifications_status`
4. **Terrains par ville :** `idx_terrains_ville`
5. **Notifications non lues :** `idx_notifications_is_read`
6. **Paiements par statut :** `idx_payments_status`

---

## Conversions et Calculs

### Convert FCFA ↔ USD

```sql
-- Taux de change : 1 USD = 655.957 XOF
SELECT convert_fcfa_to_usd(150000); -- Retourne 259
```

### Exemple requête : Verificactions en attente pour un agent

```sql
SELECT v.id, v.terrain_title, v.status, COUNT(m.id) as completed_milestones
FROM verifications v
LEFT JOIN verification_milestones m ON v.id = m.verification_id AND m.status = 'termine'
WHERE v.agent_id = '550e8400-e29b-41d4-a716-446655440101'
  AND v.status != 'rapport_livre'
GROUP BY v.id
ORDER BY v.submitted_at ASC;
```

---

## Test Data Inclus

Le script inclut des données de test cohérentes :

**Agents (2) :**

- Kofi Mensah - Spécialiste vérification cadastrale (47 vérifs ✓)
- Ama Owusu - Spécialiste vérification coutumière (35 vérifs ✓)

**Clients (2) :**

- Akosua Duah
- Kwame Boateng

**Terrains (3) :**

- Terrain 500m² Kégué - Titre foncier - Disponible
- Terrain 1000m² Tokoin - Convention - Disponible
- Terrain 800m² Avédji - Aucun doc - Réservé

**Vérification Complète (1) :**

- Client: Akosua Duah
- Terrain: Kégué
- Agent: Kofi Mensah
- Status: Analyse finale
- Risk: Faible
- 4 milestones J1/J3/J7/J10 (3 terminées, 1 en cours)
- Rapport avec points positifs et points à vérifier

---

## Déploiement sur Supabase

**Étapes :**

1. Créer un projet Supabase
2. Aller dans l'éditeur SQL
3. Coller le contenu complet de `database_schema.sql`
4. Exécuter (✓ tout doit être vert)
5. Les tables sont créées avec RLS activé
6. Les test data sont insérées automatiquement
7. Commencer à intégrer l'app Flutter

**Important :** Ne pas modifier les UUID générés. Les lier directement depuis l'app lors de création de nouvelles données.

---

## Prochaines Étapes

1. **Créer les services Dart :**
   - `supabase_service.dart` - Client Supabase
   - `verification_service.dart` - CRUD vérifications
   - `payment_service.dart` - Gestion paiements
   - `storage_service.dart` - Upload documents

2. **Intégrer à VerificationState :**
   - Remplacer données statiques par requêtes Supabase

3. **Implémenter RLS :**
   - Vérifier les politiques au déploiement
   - Tester avec différents rôles utilisateurs

4. **Ajouter webhooks :**
   - Notifications push quand milestone complétée
   - Emails de confirmation

---

**Schéma généré:** Avril 2026  
**Version:** 1.0  
**Statut:** Prêt à déployer
