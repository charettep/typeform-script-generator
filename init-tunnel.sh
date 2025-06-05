#!/bin/bash

# -----------------------------
# 🎯 Tunnel Auto-Setup Script
# -----------------------------
# Prérequis : cloudflared, jq, token API Cloudflare, zone_id Cloudflare

# === Configuration utilisateur ===
TUNNEL_NAME="typeform-script-generator"
SERVICE_URL="http://localhost:5000"
SUBDOMAIN="webhook.frnknstn.com"
CF_API_TOKEN="${CF_API_TOKEN}"
ZONE_ID="${CF_ZONE_ID}"

# === Couleurs pour log ===
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === Étape 1 : Login Cloudflare ===
echo -e "${BLUE}🔐 Connexion à Cloudflare...${NC}"
cloudflared tunnel login

# === Étape 2 : Créer le tunnel ===
echo -e "${BLUE}🚇 Création du tunnel nommé '${TUNNEL_NAME}'...${NC}"
cloudflared tunnel create "$TUNNEL_NAME"

# === Étape 3 : Générer config.yaml ===
CONFIG_PATH="$HOME/.cloudflared/config.yaml"
CREDENTIAL_PATH="$HOME/.cloudflared/${TUNNEL_NAME}.json"
echo -e "${BLUE}⚙️  Génération de config.yaml...${NC}"
cat <<EOF > "$CONFIG_PATH"
tunnel: $TUNNEL_NAME
credentials-file: $CREDENTIAL_PATH
ingress:
  - hostname: $SUBDOMAIN
    service: $SERVICE_URL
  - service: http_status:404
EOF

# === Étape 4 : Récupérer Tunnel ID ===
TUNNEL_ID=$(cat "$CREDENTIAL_PATH" | jq -r .TunnelID)
echo -e "${GREEN}✅ Tunnel ID : $TUNNEL_ID${NC}"

# === Étape 5 : Enregistrer l’entrée DNS via API Cloudflare ===
echo -e "${BLUE}🌐 Enregistrement DNS CNAME vers tunnel Cloudflare...${NC}"
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type":"CNAME",
    "name":"webhook",
    "content":"'"$TUNNEL_ID"'.cfargotunnel.com",
    "ttl":120,
    "proxied":true
  }'

# === Étape 6 : Démarrer le tunnel ===
echo -e "${BLUE}🚀 Démarrage du tunnel...${NC}"
cloudflared tunnel --config "$CONFIG_PATH" run
