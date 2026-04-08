#!/usr/bin/env node

/**
 * Script de configuration Supabase Storage
 * Configure le bucket 'documents' avec les permissions nécessaires pour les uploads
 */

const https = require("https");

// ════════════════════════════════════════════════════════════
// CONFIGURATION
// ════════════════════════════════════════════════════════════

const PROJECT_ID = "rmdncmywkjhoqwglypov";
const API_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtZG5jbXl3a2pob3F3Z2x5cG92Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzE1OTQxNiwiZXhwIjoyMDcyNzM1NDE2fQ.Srxae6cKwz6IOHkSyY7iZ_6F2PBR0iE2J5vr96-iW_s";
const BUCKET_NAME = "documents";

// ════════════════════════════════════════════════════════════
// UTILITAIRES
// ════════════════════════════════════════════════════════════

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: `${PROJECT_ID}.supabase.co`,
      path: path,
      method: method,
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        "Content-Type": "application/json",
        apikey: API_KEY,
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => {
        try {
          resolve({
            status: res.statusCode,
            data: data ? JSON.parse(data) : null,
            headers: res.headers,
          });
        } catch {
          resolve({
            status: res.statusCode,
            data: data,
            headers: res.headers,
          });
        }
      });
    });

    req.on("error", reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

// ════════════════════════════════════════════════════════════
// CONFIGURATION DU BUCKET
// ════════════════════════════════════════════════════════════

async function setupBucket() {
  console.log("🚀 Démarrage de la configuration Supabase Storage\n");

  try {
    // 1. Créer le bucket
    console.log('1️⃣  Création du bucket "documents"...');
    const createRes = await makeRequest("POST", "/storage/v1/b", {
      name: BUCKET_NAME,
      public: true,
      file_size_limit: 52428800, // 50MB
    });

    if (createRes.status === 201 || createRes.status === 200) {
      console.log("✅ Bucket créé avec succès (ou déjà existant)\n");
    } else if (createRes.status === 409) {
      console.log('ℹ️  Bucket "documents" existe déjà, continuant...\n');
    } else {
      console.log(`❌ Erreur: ${createRes.status}`, createRes.data);
    }

    // 2. Ajouter les policies RLS
    console.log("2️⃣  Configuration des policies RLS...\n");

    const policies = [
      {
        name: "Enable anon uploads",
        definition: "role() = 'anon'",
        action: "INSERT",
      },
      {
        name: "Enable authenticated uploads",
        definition: "role() = 'authenticated'",
        action: "INSERT",
      },
      {
        name: "Enable public read",
        definition: "true",
        action: "SELECT",
      },
      {
        name: "Enable user deletes",
        definition: "role() = 'authenticated'",
        action: "DELETE",
      },
    ];

    for (const policy of policies) {
      console.log(
        `  • Ajoutant policy: "${policy.name}" (${policy.action})...`,
      );

      const policyRes = await makeRequest(
        "POST",
        `/storage/v1/b/${BUCKET_NAME}/policies`,
        {
          name: policy.name,
          definition: policy.definition,
          action: policy.action,
        },
      );

      if (policyRes.status === 201 || policyRes.status === 200) {
        console.log(`    ✅ Policy ajoutée`);
      } else if (policyRes.status === 409) {
        console.log(`    ℹ️  Policy existe déjà`);
      } else {
        console.log(`    ❌ Erreur: ${policyRes.status}`, policyRes.data);
      }
    }

    console.log("\n3️⃣  Configuration CORS...");

    // 3. Ajouter les origines CORS
    const corsOrigins = [
      "http://localhost:3000",
      "http://localhost:8080",
      "http://localhost:5173",
      "http://10.0.2.2:5173", // Android emulator
      "https://rmdncmywkjhoqwglypov.supabase.co",
      "*", // À adapter selon besoin
    ];

    const corsRes = await makeRequest("PATCH", `/storage/v1/b/${BUCKET_NAME}`, {
      allowed_mime_types: [
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ],
      file_size_limit: 52428800,
      public: true,
    });

    if (corsRes.status === 200 || corsRes.status === 204) {
      console.log("✅ Configuration CORS appliquée\n");
    } else {
      console.log(`⚠️  Warning CORS: ${corsRes.status}\n`);
    }

    console.log("═════════════════════════════════════════════════");
    console.log("✅ Configuration Supabase Storage COMPLÈTE!");
    console.log("═════════════════════════════════════════════════\n");
    console.log('Le bucket "documents" est maintenant prêt pour les uploads!');
    console.log("Les vendeurs peuvent uploader des photos de terrain.\n");
  } catch (error) {
    console.error("❌ Erreur:", error.message);
    process.exit(1);
  }
}

// ════════════════════════════════════════════════════════════
// EXÉCUTION
// ════════════════════════════════════════════════════════════

setupBucket();
