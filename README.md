# Typeform Python Script Generator

## 🛠 Requirements

### Hardware:
- Any system that can run Python 3.10+
- Internet access

### Software:
- Python 3.10+
- `pip` (Python package manager)
- `cloudflared` (for local tunnel)
- (Optional) `nginx` for domain mapping

## 🔧 Configuration Instructions

1. Copy `.env.example` to `.env` and fill in your values:
```bash
cp .env.example .env
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## 🚀 Run Locally with Cloudflared (WSL2 Compatible)

```bash
python app.py
cloudflared tunnel --url http://localhost:5000
```

Cloudflared will give you a public HTTPS URL to use as the webhook in Typeform.

## 🌍 Live Deployment with Custom Domain (Cloudflare DNS)

1. Deploy on Render or Railway.
2. Map your domain in their UI.
3. Use Cloudflare DNS to point your domain (CNAME) to Render/Railway endpoint.
4. Secure with SSL.

## 📥 Usage Instructions

- Submit the Typeform: it will POST to `/webhook`
- The app:
  1. Reads answers
  2. Generates a script with OpenAI
  3. Emails the script to the user

## ✅ Sample Input

- Objectif: "Automatiser l'envoi d'un rapport par email"
- API: Oui
- Fichiers: Oui
- Email: user@example.com

## 📤 Output
You’ll get a complete Python script emailed to you automatically!

---

## 🚀 Déploiement sur Google Cloud Run

### 🧰 Prérequis

- Un projet GCP actif
- Le SDK GCP installé et authentifié : https://cloud.google.com/sdk/docs/install
- Facturation activée sur le projet

### 🐳 Étapes

```bash
# Se connecter à GCP
gcloud auth login
gcloud config set project [ID_DU_PROJET]

# Activer Cloud Run et Container Registry
gcloud services enable run.googleapis.com containerregistry.googleapis.com

# Déployer
gcloud builds submit --config cloudbuild.yaml
```

Une fois déployé, tu recevras une URL publique pour ton webhook Typeform.

---

## 🌐 Mapping de domaine avec Cloudflare

1. Dans Cloudflare, va dans ton domaine > DNS.
2. Ajoute un **CNAME** vers l’URL fournie par Cloud Run.
3. Active SSL Flexible ou Full.
4. (Optionnel) Configure le redirect HTTPS.


---

## 🌐 Mapper le domaine frnknstn.com via Cloudflare

1. Va sur Cloudflare > `frnknstn.com` > **DNS**
2. Ajoute l’entrée suivante :

| Type  | Name       | Content (Target)                    | TTL   | Proxy |
|-------|------------|--------------------------------------|-------|-------|
| CNAME | webhook    | `uuid.cfargotunnel.com` (Cloudflared) | Auto  | 🔶 Oui |

3. Ce `uuid.cfargotunnel.com` est affiché quand tu exécutes :
```bash
cloudflared tunnel create typeform-script-generator
```

4. Puis, démarre ton tunnel :
```bash
cloudflared tunnel --config .cloudflared/config.yaml run
```

ℹ️ Remplace `/home/YOUR-USER/` dans le fichier config avec le bon chemin Linux (utilise `echo $HOME`)
# trigger build
 
# Trigger build again
