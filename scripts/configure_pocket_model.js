const fs = require('fs');
const path = require('path');

// 1. Load the template (source config)
// We look for it in /app/pocket_model.json (inside Docker) or local openclaw.json
const templatePath = process.env.POCKET_MODEL_TEMPLATE || './openclaw.json';
const outputPath = process.env.POCKET_MODEL_OUTPUT || './openclaw-runtime.json';

if (!fs.existsSync(templatePath)) {
    console.error(`❌ Template not found at ${templatePath}`);
    process.exit(1);
}

const config = JSON.parse(fs.readFileSync(templatePath, 'utf8'));

console.log("⚙️  Configuring PocketModel based on available keys...");

// 2. Identify available providers
const availableProviders = new Set();
const authKeys = Object.keys(config.auth || {});

// Map of provider -> Env Var Name (derived from the template value "${VAR_NAME}")
const envVarMap = {};

// Helper to extract env var name from "${VAR_NAME}"
function getEnvVarName(val) {
    if (typeof val === 'string' && val.startsWith('${') && val.endsWith('}')) {
        return val.slice(2, -1);
    }
    return null;
}

// Check each auth provider
for (const provider of authKeys) {
    const providerConfig = config.auth[provider];
    const apiKeyTemplate = providerConfig.api_key;
    const envVar = getEnvVarName(apiKeyTemplate);

    if (envVar) {
        if (process.env[envVar] && process.env[envVar].length > 0) {
            console.log(`✅ ${provider}: Key found (${envVar})`);
            availableProviders.add(provider);
            // Replace template with actual key (OpenClaw might handle env vars, but we can resolve them if needed. 
            // Actually, OpenClaw typically supports env var expansion, but if we remove the entry, it won't try to use it.)

            // We Keep strict mode: if we don't have the key, we remove the provider entirely.
        } else {
            console.log(`⚠️  ${provider}: Key missing (${envVar}) — Skipping.`);
            delete config.auth[provider];
        }
    } else {
        // If no env var template, assume it's hardcoded or open, so we keep it.
        availableProviders.add(provider);
    }
}

// 3. Filter Models
// Only keep models where the provider is available
if (config.models) {
    config.models = config.models.filter(model => {
        const isAvailable = availableProviders.has(model.provider);
        if (!isAvailable) {
            console.log(`🔻 Removing model ${model.id} (provider ${model.provider} missing)`);
        }
        return isAvailable;
    });
}

// 4. Update Defaults (Primary & Fallbacks)
// We need to ensure the primary model actually exists
if (config.agents && config.agents.defaults && config.agents.defaults.model) {
    let { primary, fallbacks } = config.agents.defaults.model;

    // Helper to check if a model ID is valid (exists in our filtered list)
    const isModelValid = (id) => config.models.find(m => m.id === id);

    const validFallbacks = (fallbacks || []).filter(id => isModelValid(id));

    // If primary is missing, promote the first valid fallback
    if (!isModelValid(primary)) {
        console.log(`⚠️  Primary model ${primary} unavailable.`);
        if (validFallbacks.length > 0) {
            primary = validFallbacks.shift(); // Take first fallback as new primary
            console.log(`🔄 Switched primary to: ${primary}`);
        } else {
            // If no fallbacks, try ANY matching model from the list
            if (config.models.length > 0) {
                primary = config.models[0].id;
                console.log(`🔄 Fallback to first available model: ${primary}`);
            } else {
                console.error("❌ No models available! Please check your API keys.");
                // We don't exit, we just let it generate an empty-ish config so the user can see errors in UI instead of crash.
            }
        }
    }

    config.agents.defaults.model.primary = primary;
    config.agents.defaults.model.fallbacks = validFallbacks;
}

// 5. Write the final config
// We resolved the keys? No, currently we just removed the missing ones.
// OpenClaw likely supports ${VAR} syntax. We'll leave the ${VAR} in place for the ones we kept.
// BUT, if OpenClaw doesn't support ${VAR} expansion natively in this specific JSON loader, 
// we might need to replace them. given the user's template had them, we assume support OR we need to replace.
// Let's replace them to be safe, creating a fully resolved runtime config.

for (const provider of Object.keys(config.auth)) {
    const envVar = getEnvVarName(config.auth[provider].api_key);
    if (envVar && process.env[envVar]) {
        config.auth[provider].api_key = process.env[envVar];
    }
}

// Write to disk
fs.writeFileSync(outputPath, JSON.stringify(config, null, 2));
console.log(`💾 Generated runtime config at ${outputPath}`);
