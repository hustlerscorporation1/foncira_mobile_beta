# 🔄 Synchronisation des Rôles - Implémentation Complete

## ✅ Implémentation Effectuée

### 1. **UserRoleProvider** (`lib/providers/user_role_provider.dart`)

- ✅ Récupère le rôle depuis Supabase
- ✅ Détecte les changements de rôle
- ✅ Synchronise en arrière-plan (avec timeout 5s)
- ✅ Gestion des erreurs réseau
- ✅ Logs détaillés pour le debugging

**Getters disponibles:**

```dart
provider.currentRole        // 'admin', 'agent', 'client'
provider.isAdmin            // bool
provider.isAgent            // bool
provider.isClient           // bool
provider.hasRoleChanged     // Détecte changement
provider.errorMessage       // Messages d'erreur
```

### 2. **RoleBasedNavigation** (`lib/services/role_based_navigation.dart`)

- ✅ Fonction centralisée de navigation par rôle
- ✅ Redirection automatique vers l'interface correcte
- ✅ Validation d'accès par rôle
- ✅ Notifications visuelles des changements

**Méthodes:**

```dart
RoleBasedNavigation.getRouteForRole(role)          // 'admin' → '/admin'
RoleBasedNavigation.navigateByRole(context, role)  // Navigue
RoleBasedNavigation.hasAccessToRoute(role, route)  // Vérifie accès
```

### 3. **SplashPage** (Modifiée)

- ✅ Appelle `initializeUserRole()` au démarrage
- ✅ Redirige selon le rôle (not juste '/home')
- ✅ Gestion des erreurs avec fallback
- ✅ Logs pour tracer l'initialisation

**Flux:**

```
SplashPage → initializeUserRole()
  ├─ Récupère rôle depuis Supabase
  ├─ Redirige vers:
  │  ├─ '/admin' si role='admin'
  │  ├─ '/agent' si role='agent'
  │  └─ '/home' si role='client'
  └─ Fallback '/home' en cas d'erreur
```

### 4. **AppLifecycleDetector** (`lib/widgets/app_lifecycle_detector.dart`)

- ✅ Détecte quand l'app revient au foreground
- ✅ Synchronise le rôle en arrière-plan
- ✅ Affiche notification si changement
- ✅ Redirige automatiquement si rôle changé

**Widget wrapper:**

```dart
WithAppLifecycleDetection(
  child: MyPage(),
  onAppResumed: (context) { /* custom logic */ }
)
```

### 5. **main.dart** (Modifié)

- ✅ Ajouté `UserRoleProvider` au MultiProvider
- ✅ Wrappé les routes avec `WithAppLifecycleDetection`
  - `/home` → WithAppLifecycleDetection(FonciraHomePage)
  - `/admin` → WithAppLifecycleDetection(AdminDashboard)
  - `/agent` → WithAppLifecycleDetection(AgentDashboard)

---

## 🔄 Flux de Synchronisation

### **Au démarrage de l'app:**

```
1. SplashPage initialise (3s d'animation)
2. Vérifie si l'utilisateur est authentifié
3. Appelle UserRoleProvider.initializeUserRole()
   ├─ Récupère rôle depuis Supabase (timeout 5s)
   ├─ Stocke le rôle courant
   └─ Retourne true/false
4. Navigue vers la route appropriée:
   - '/admin' si role = 'admin'
   - '/agent' si role = 'agent'
   - '/home' si role = 'client' (par défaut)
5. Page est wrappée avec WithAppLifecycleDetection
```

### **Quand l'app revient au foreground:**

```
1. WidgetsBindingObserver.didChangeAppLifecycleState() appelé
2. État = AppLifecycleState.resumed
3. WithAppLifecycleDetection déclenche _onAppResumed()
4. Appelle UserRoleProvider.syncRoleInBackground()
   ├─ Récupère rôle depuis Supabase (dans un Future)
   └─ Vérifie si hasRoleChanged
5. Si changement détecté:
   ├─ Affiche notification: "Rôle mis à jour: X → Y"
   ├─ Attend 2s
   └─ Redirige vers la nouvelle interface
6. Si pas de changement: Rien (reste sur la page)
```

### **Quand le rôle change en background:**

```
Scénario: User est connecté, rôle 'client'
1. Admin change le rôle à 'agent' dans Supabase
2. User revient à l'app (app en background → foreground)
3. WithAppLifecycleDetection.didChangeAppLifecycleState() appelé
4. syncRoleInBackground() récupère le nouveau rôle
5. Détecte: previousRole='client' != currentRole='agent'
6. Affiche: "🔄 Votre rôle a été mis à jour: client → agent"
7. Redirige vers '/agent' (interface agent)
```

---

## 🧪 Cas d'Usage à Tester

### Test 1: Changement client → agent

```
1. User: Client (rôle = 'client')
2. Admin change rôle à 'agent' dans Supabase
3. User app: En background
4. User ramène app au foreground
✅ Attendu: Redirection vers '/agent', notification affichée
```

### Test 2: Changement client → admin

```
1. User: Client
2. Admin change rôle à 'admin'
3. User ramène app au foreground
✅ Attendu: Redirection vers '/admin', notification affichée
```

### Test 3: Changement agent → client

```
1. User: Agent
2. Admin change rôle à 'client'
3. User ramène app au foreground
✅ Attendu: Redirection vers '/home', notification affichée
```

### Test 4: Sans changement

```
1. User: Client (rôle = 'client')
2. User ramène app au foreground (rôle inchangé)
✅ Attendu: Aucune notification, reste sur '/home'
```

### Test 5: Erreur réseau

```
1. User: Client
2. Admin change rôle à 'admin'
3. User ramène app au foreground (pas de réseau)
✅ Attendu: Timeout 5s, garde l'ancien rôle, pas de redirection
```

---

## 📊 Architecture

```
main.dart
├─ MultiProvider
│  ├─ AuthProvider
│  ├─ TerrainProvider
│  ├─ VerificationProvider
│  ├─ NotificationProvider
│  ├─ UserModeProvider
│  └─ UserRoleProvider ✨ NEW
└─ MaterialApp (routes)
   ├─ '/': SplashPage (appelle initializeUserRole)
   ├─ '/home': WithAppLifecycleDetection(FonciraHomePage)
   ├─ '/admin': WithAppLifecycleDetection(AdminDashboard)
   ├─ '/agent': WithAppLifecycleDetection(AgentDashboard)
   └─ ...

UserRoleProvider
├─ initializeUserRole() - Sync au démarrage + login
├─ syncRoleInBackground() - Sync lors du retour au foreground
├─ _fetchUserRole() - Récupère depuis Supabase (timeout 5s)
└─ hasRoleChanged - Détecte changements

WithAppLifecycleDetection (WidgetsBindingObserver)
├─ onAppResumed - Redirige si rôle changé
├─ onAppPaused - Log
└─ onAppDetached - Log

RoleBasedNavigation (utilitaires statiques)
├─ getRouteForRole()
├─ navigateByRole()
├─ hasAccessToRoute()
└─ showRoleChangeNotification()
```

---

## 🔧 Comment Utiliser

### **1. Vérifier le rôle courant:**

```dart
final userRoleProvider = context.read<UserRoleProvider>();
print('Rôle: ${userRoleProvider.currentRole}');

if (userRoleProvider.isAdmin) {
  // Affiche du contenu admin
}
```

### **2. Écouter les changements de rôle:**

```dart
Consumer<UserRoleProvider>(
  builder: (context, userRole, _) {
    return Text('Rôle: ${userRole.currentRole}');
  },
)
```

### **3. Naviguer manuellement selon le rôle:**

```dart
final userRole = context.read<UserRoleProvider>();
await RoleBasedNavigation.navigateByRole(context, userRole.currentRole);
```

### **4. Ajouter des pages avec lifecycle detection:**

```dart
'/my-page': (context) => WithAppLifecycleDetection(
  child: const MyPage(),
)
```

---

## 📋 Checklist Implémentation

- ✅ `UserRoleProvider` créé avec sync en arrière-plan
- ✅ `RoleBasedNavigation` service créé
- ✅ `SplashPage` modifiée pour appeler `initializeUserRole()`
- ✅ `AppLifecycleDetector` widget créé pour lifecycle events
- ✅ `main.dart` modifié pour ajouter le provider et wrapper les routes
- ✅ Import ajouté dans `main.dart`
- ✅ Routes wrappées avec `WithAppLifecycleDetection`
- ✅ Logs détaillés pour debugging
- ✅ Gestion des erreurs et timeouts
- ✅ Documentation complète

---

## 🐛 Debugging

### Logs à rechercher:

```
✅ [Role Sync] Rôle initialisé: client
🔄 [Role Sync] Rôle changé: client → agent
❌ [Role Sync] Erreur: ...
⏱️  [Role Sync] Timeout lors de la récupération du rôle
🔄 [Lifecycle] App resumed - Synchronisation...
📍 [Navigation] Navigation initiale: client → /home
🔄 [Navigation] Redirection due au changement de rôle: admin → /admin
```

### Vérifier la sync manuelle:

```dart
// Dans Flutter DevTools Console:
final provider = context.read<UserRoleProvider>();
await provider.initializeUserRole();
print(provider.currentRole); // Devrait afficher le rôle courant
print(provider.hasRoleChanged); // true si changement
```

---

## ⚠️ Limitations & Notes

1. **Timeout de 5 secondes** - Si le réseau est lent, le ancien rôle est gardé
2. **Sync en arrière-plan** - N'affiche pas les erreurs directement
3. **Redirection immédiate** - Peut être jarring, 2s de délai avant redirection
4. **Local storage** - Le rôle n'est pas persisté en SharedPreferences (peut être ajouté si besoin)

---

## 🚀 Améliorations Futures (Optionnel)

1. Persister le rôle en SharedPreferences pour comparaison rapide
2. Ajouter refresh pull-to-refresh pour force sync
3. Ajouter un badge "rôle changé" dans l'UI
4. Implémenter une queue pour les changements multiples
5. Ajouter des tests unitaires pour UserRoleProvider

---

**Implémentation Complétée!** ✨
