#!/usr/bin/env node

/**
 * 🌐 Script pour configurer les origines CORS dans Supabase Storage
 *
 * Usage:
 * node setup_cors.js
 *
 * Prérequis:
 * - npm install @supabase/supabase-js
 * - Variables d'environnement ou modification du script
 */

const https = require("https");

// ============================================================================
// Configuration - À METTRE À JOUR
// ============================================================================

const SUPABASE_URL = "https://xxxxxxxxxxx.supabase.co";
const SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";

// Origines CORS à ajouter
const CORS_ORIGINS = [
  "http://localhost:*", // Dev local
  "http://localhost:3000", // Dev local (React, etc.)
  "http://localhost:8000", // Dev local (autre port)
  "https://foncira.app", // Production (adapter selon votre domaine)
  "https://*.lovable.app", // Lovable
  "https://*.vercel.app", // Vercel
  "https://*.supabase.co", // Supabase
];

// ============================================================================
// Classe pour la configuration CORS
// ============================================================================

class SupabaseCorsSetup {
  constructor(supabaseUrl, serviceRoleKey) {
    this.supabaseUrl = supabaseUrl;
    this.serviceRoleKey = serviceRoleKey;
  }

  /**
   * Effectuer une requête HTTP vers l'API Supabase
   */
  async makeRequest(method, path, body = null) {
    return new Promise((resolve, reject) => {
      const url = new URL(this.supabaseUrl);
      const options = {
        hostname: url.hostname,
        port: url.port || 443,
        path: path,
        method: method,
        headers: {
          "Content-Type": "application/json",
          apikey: this.serviceRoleKey,
          Authorization: `Bearer ${this.serviceRoleKey}`,
        },
      };

      const req = https.request(options, (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: data ? JSON.parse(data) : null,
          });
        });
      });

      req.on("error", reject);

      if (body) {
        req.write(JSON.stringify(body));
      }
      req.end();
    });
  }

  /**
   * Récupérer la configuration CORS actuelle
   */
  async getCorsConfig() {
    console.log("\n📍 Récupération de la configuration CORS actuelle...");
    try {
      const response = await this.makeRequest(
        "GET",
        "/rest/v1/rpc/get_cors_config",
      );
      console.log("✅ Configuration CORS actuelle:");
      console.log(JSON.stringify(response.body, null, 2));
      return response.body;
    } catch (error) {
      console.warn("⚠️  Impossible de récupérer CORS via API:", error.message);
      console.log(
        "   💡 Vous devrez le faire manuellement via Supabase Dashboard",
      );
    }
  }

  /**
   * Ajouter une origine CORS
   */
  async addCorsOrigin(origin) {
    try {
      const response = await this.makeRequest(
        "POST",
        "/rest/v1/rpc/add_cors_origin",
        { origin: origin },
      );

      if (response.status >= 200 && response.status < 300) {
        console.log(`  ✅ ${origin}`);
        return true;
      } else {
        console.log(`  ⚠️  ${origin} (status: ${response.status})`);
        return false;
      }
    } catch (error) {
      console.log(`  ⚠️  ${origin} - Erreur: ${error.message}`);
      return false;
    }
  }

  /**
   * Configurer toutes les origines CORS
   */
  async setupAllCors() {
    console.log("\n🌐 Configuration des origines CORS...\n");

    let successful = 0;
    let failed = 0;

    for (const origin of CORS_ORIGINS) {
      const result = await this.addCorsOrigin(origin);
      if (result) {
        successful++;
      } else {
        failed++;
      }
    }

    console.log(`\n📊 Résumé:`);
    console.log(`   ✅ Succès: ${successful}`);
    console.log(`   ⚠️  Erreurs: ${failed}`);

    return failed === 0;
  }

  /**
   * Afficher les instructions manuelles
   */
  printManualInstructions() {
    console.log("\n" + "=".repeat(70));
    console.log("📌 CONFIGURATION MANUELLE VIA SUPABASE DASHBOARD");
    console.log("=".repeat(70) + "\n");

    console.log(
      "Si la configuration automatique a échoué, faites-le manuellement:\n",
    );
    console.log("1️⃣  Allez à Supabase Dashboard:");
    console.log(`    ${this.supabaseUrl}/project/settings/api\n`);

    console.log("2️⃣  Allez à Settings > API > CORS allow-listed origins\n");

    console.log("3️⃣  Ajoutez les origines suivantes:\n");
    CORS_ORIGINS.forEach((origin, index) => {
      console.log(`    ${index + 1}. ${origin}`);
    });

    console.log(
      '\n4️⃣  Cliquez sur "Add origin" ou "Update" pour chaque origine\n',
    );

    console.log("5️⃣  Vérifiez que les origines sont ajoutées\n");

    console.log(
      "   💡 Pour la production, adapter les domaines à votre application\n",
    );
  }

  /**
   * Exécution complète
   */
  async run() {
    console.log("\n╔════════════════════════════════════════════════════════╗");
    console.log("║  🌐 Configuration CORS - Supabase Storage          🌐  ║");
    console.log("╚════════════════════════════════════════════════════════╝\n");

    // Vérifier la configuration
    if (
      SUPABASE_URL.includes("xxxxxxxxxxx") ||
      SUPABASE_SERVICE_ROLE_KEY.includes("eyJ")
    ) {
      console.log(
        "❌ ERREUR: Mettez à jour SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY!\n",
      );
      console.log("📍 Trouvez ces valeurs:");
      console.log("   1. Allez à: https://app.supabase.com");
      console.log("   2. Sélectionnez votre projet");
      console.log("   3. Settings > API > Project URL et Service Role key");
      console.log("   4. Copiez les valeurs dans ce script\n");
      process.exit(1);
    }

    console.log("📍 Configuration:");
    console.log(`   Supabase URL: ${SUPABASE_URL}`);
    console.log(`   Origines à configurer: ${CORS_ORIGINS.length}\n`);

    try {
      // Récupérer la config actuelle
      await this.getCorsConfig();

      // Ajouter les origines
      const success = await this.setupAllCors();

      // Instructions manuelles
      this.printManualInstructions();

      if (success) {
        console.log(
          "╔════════════════════════════════════════════════════════╗",
        );
        console.log(
          "║  ✅ CONFIGURATION CORS RÉUSSIE!                    ✅  ║",
        );
        console.log(
          "╚════════════════════════════════════════════════════════╝\n",
        );
      } else {
        console.log(
          "╔════════════════════════════════════════════════════════╗",
        );
        console.log(
          "║  ⚠️  À COMPLÉTER MANUELLEMENT                      ⚠️  ║",
        );
        console.log(
          "╚════════════════════════════════════════════════════════╝\n",
        );
      }
    } catch (error) {
      console.error("❌ Erreur:", error.message);
      this.printManualInstructions();
    }
  }
}

// ============================================================================
// MAIN - Point d'entrée
// ============================================================================

async function main() {
  const setup = new SupabaseCorsSetup(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  await setup.run();
}

main().catch(console.error);
