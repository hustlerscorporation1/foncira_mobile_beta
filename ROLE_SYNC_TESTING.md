// ══════════════════════════════════════════════════════════════
// ROLE SYNCHRONIZATION - TEST GUIDE
// ══════════════════════════════════════════════════════════════

/\*\*

- Ce guide explique comment tester l'implémentation complète
- de la synchronisation des rôles.
  \*/

// ══════════════════════════════════════════════════════════════
// TEST 1: INITIALIZATION AU DÉMARRAGE (Splash → Home)
// ══════════════════════════════════════════════════════════════

/\*
ÉTAPES:

1. Assure-toi que tu es connecté avec un user 'client'
2. Relance l'app complètement: flutter run

COMPORTEMENT ATTENDU:
✅ SplashPage affiche 3s d'animation
✅ Console: "✅ [Role Sync] Rôle initialisé: client"
✅ Redirige vers `/home` (interface client)

LOGS À VÉRIFIER:

- Flutter console: "📍 [Navigation] Navigation initiale: client → /home"
- Firebase: Aucune erreur
  \*/

// ══════════════════════════════════════════════════════════════
// TEST 2: CHANGEMENT DE RÔLE EN BACKGROUND (Client → Admin)
// ══════════════════════════════════════════════════════════════

/\*
SETUP:

1. Connecte-toi avec un user de rôle 'client'
2. Lance l'app: flutter run
3. Attends que tu sois sur la home page

TEST:

1. Ouvre Supabase Studio dans un navigateur
2. Va à Table: public.users
3. Trouve la ligne pour ton user
4. Change la colonne 'primary_role' de 'client' à 'admin'
5. Clique Save
6. Reviens à l'app (ramène du background au foreground)

COMPORTEMENT ATTENDU:
✅ Console: "🔄 [Lifecycle] App resumed - Synchronisation du rôle en arrière-plan..."
✅ Snackbar: "🔄 Votre rôle a été mis à jour: client → admin"
✅ Après 2s: Redirection vers `/admin` (interface admin)
✅ Console: "⚠️ [Role Sync] Rôle changé: client → admin"
✅ Console: "🔄 [Navigation] Redirection due au changement de rôle: admin → /admin"

LOGS À VÉRIFIER:

- Tous les logs [Lifecycle], [Role Sync], [Navigation] affichés
- Pas d'erreur dans la console Flutter
  \*/

// ══════════════════════════════════════════════════════════════
// TEST 3: CHANGEMENT DE RÔLE EN BACKGROUND (Admin → Agent)
// ══════════════════════════════════════════════════════════════

/\*
SETUP:

1. Redémarrage depuis TEST 2 (tu es maintenant admin)
2. Flutter run pour relancer
3. Attends-toi sur la page admin

TEST:

1. Ouvre Supabase Studio
2. Modifie ton user: 'primary_role' = 'admin' → 'agent'
3. Reviens à l'app (foreground)

COMPORTEMENT ATTENDU:
✅ Snackbar: "🔄 Votre rôle a été mis à jour: admin → agent"
✅ Redirection vers `/agent` (interface agent)
✅ Console: "🔄 [Role Sync] Rôle changé: admin → agent"
\*/

// ══════════════════════════════════════════════════════════════
// TEST 4: PAS DE CHANGEMENT (Client → Client)
// ══════════════════════════════════════════════════════════════

/\*
SETUP:

1. User rôle 'client'
2. App ouverte sur la home

TEST:

1. Mets l'app en background (Home button)
2. Attends 2 secondes
3. Ramène l'app au foreground

COMPORTEMENT ATTENDU:
✅ Console: "🔄 [Lifecycle] App resumed..."
✅ Console: "🔄 Synchronisation du rôle..."
✅ AUCUNE snackbar (rôle inchangé)
✅ Reste sur la page home
✅ Console: Pas de log "Rôle changé"
\*/

// ══════════════════════════════════════════════════════════════
// TEST 5: ERREUR RÉSEAU (Timeout)
// ══════════════════════════════════════════════════════════════

/\*
SETUP:

1. User rôle 'client'
2. App ouverte

TEST:

1. DÉSACTIVE le WiFi/data du téléphone (déconnecte Internet)
2. Mets l'app en background
3. Attends 10 secondes
4. Ramène l'app au foreground

COMPORTEMENT ATTENDU:
✅ Console: "⏱️ [Role Sync] Timeout lors de la récupération du rôle"
✅ Reste sur la page home (pas de redirection)
✅ Garde l'ancien rôle 'client'
✅ Pas d'erreur crashante

LOGS À VÉRIFIER:

- Voit le timeout log après ~5 secondes
  \*/

// ══════════════════════════════════════════════════════════════
// TEST 6: ACCÈS NON AUTORISÉ (Agent essaye d'accéder à /admin)
// ══════════════════════════════════════════════════════════════

/\*
SETUP:

1. User rôle 'agent'

TEST:

1. Dans la console Flutter, tape:
   ```
   Navigator.of(context).pushNamed('/admin');
   ```

COMPORTEMENT ATTENDU:
✅ AdminGuard refuse l'accès
✅ L'utilisateur revient à la page précédente
✅ Snackbar: "Unauthorized" ou redirection automatique

NOTES:

- C'est géré par AdminGuard.protectedRoute()
- Notre système s'assure que la redirection est cohérente
  \*/

// ══════════════════════════════════════════════════════════════
// DEBUG CONSOLE
// ══════════════════════════════════════════════════════════════

/\*
Pour vérifier manuellement l'état dans Flutter DevTools:

1. Ouvre Flutter DevTools: flutter pub global run devtools
2. Va à Debug Console tab
3. Utilise la console pour:

// Vérifier le rôle courant:
Provider.of<UserRoleProvider>(context, listen: false).currentRole

// Vérifier les logs:
UserRoleProvider().initializeUserRole()

// Forcer une sync:
Provider.of<UserRoleProvider>(context, listen: false).syncRoleInBackground()

// Vérifier les changements détectés:
Provider.of<UserRoleProvider>(context, listen: false).hasRoleChanged
\*/

// ══════════════════════════════════════════════════════════════
// LOGS À CHERCHER
// ══════════════════════════════════════════════════════════════

/\*
LOGS NORMAUX (OK):
✅ "✅ [Role Sync] Rôle initialisé: client"
✅ "📍 [Navigation] Navigation initiale: client → /home"
✅ "🔄 [Lifecycle] App resumed"
✅ "🔄 Synchronisation du rôle..."
✅ "⏱️ [Role Sync] Timeout..."

LOGS D'ERREUR (À INVESTIGUER):
❌ "❌ [Role Sync] Erreur:" - Erreur Supabase, vérifie les permissions
❌ "❌ [Lifecycle] Erreur:" - Erreur dans le lifecycle listener
❌ "Exception:" - Crash non géré
❌ "Permission denied" - Vérifie les RLS policies Supabase
\*/

// ══════════════════════════════════════════════════════════════
// CHECKLIST FINAL
// ══════════════════════════════════════════════════════════════

/\*
AVANT DE CONSIDÉRER COMME "DONE":

✅ Test 1: Initialization au démarrage fonctionne

- Naviguer vers la bonne page selon le rôle

✅ Test 2 & 3: Changements de rôle en background:

- Détecte les changements
- Affiche notification
- Redirige vers la bonne interface

✅ Test 4: Pas de changement:

- Aucune notification/redirection inutile
- Reste sur la page courante

✅ Test 5: Gestion erreurs/timeouts:

- Ne crash pas
- Garde l'ancien rôle

✅ Test 6: Accès protégé:

- Utilisateur ne peut pas accéder à une interface non autorisée

✅ Console logs:

- Tous les logs attendus affichés
- Pas d'erreurs non gérées

✅ Performance:

- Pas de lag lors du retour au foreground
- Timeout de 5s respecté
  \*/

// ══════════════════════════════════════════════════════════════
// DÉBOGGAGE AVANCÉ
// ══════════════════════════════════════════════════════════════

/\*
Si un test échoue:

1. PREMIER: Vérifier les logs console Flutter
   - Cherche les logs [Role Sync], [Lifecycle], [Navigation]
   - Si message d'erreur, copie-le entièrement

2. DEUXIÈME: Vérifier Supabase
   - Va à Supabase Studio
   - Vérifie que la colonne 'primary_role' existe et est modifiée
   - Vérifie les valeurs: 'client', 'agent', 'admin'

3. TROISIÈME: Vérifier les tables
   - SELECT \* FROM users WHERE id = 'your-user-id'
   - Régarde la colonne 'primary_role'

4. QUATRIÈME: Vérifier la requête Supabase
   - Dans initializeUserRole(), la requête cherche:
   - auth_id OU id (essaye les deux)
   - primary_role

5. CINQUIÈME: Vérifier les permissions
   - Tap on users table → RLS Policies
   - Vérifie que la requête SELECT est accessible
     \*/

// ══════════════════════════════════════════════════════════════
// NOTES IMPORTANTES
// ══════════════════════════════════════════════════════════════

/\*

1. TIMEOUT DE 5 SECONDES
   - Si Supabase est lent, le timeout peut se déclencher
   - En production, considère 3s suffisant pour une bonne connexion

2. NOTIFICATION APRÈS 2 SECONDES
   - C'est intentionnel pour laisser le temps de voir la notification
   - Peut être ajusté dans app_lifecycle_detector.dart

3. RÔLES AUTORISÉS
   - 'client' (défaut)
   - 'agent'
   - 'admin'
   - Ajouter d'autres rôles: modifier RoleBasedNavigation

4. DONNÉES PERSISTANTES
   - Le rôle n'est pu persisté en SharedPreferences
   - À ajouter si on veut éviter la requête Supabase à chaque sync

5. MULTIPLES CHANGEMENTS RAPIDES
   - Si le rôle change 2x rapides en background:
   - Seul le dernier changement est détecté
   - C'est acceptable pour la plupart des cas d'usage
     \*/
