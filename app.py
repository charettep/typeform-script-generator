import os
import json
import smtplib
from email.mime.text import MIMEText
from flask import Flask, request
import openai
from dotenv import load_dotenv

# Load .env variables
load_dotenv()

# Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
SMTP_SERVER = os.getenv("SMTP_SERVER")
SMTP_USER = os.getenv("SMTP_USER")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")
SMTP_PORT = int(os.getenv("SMTP_PORT", 587))

app = Flask(__name__)
openai.api_key = OPENAI_API_KEY

def generate_script(prompt):
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "Tu es un assistant Python qui écrit des scripts sur mesure."},
            {"role": "user", "content": prompt}
        ]
    )
    return response.choices[0].message.content.strip()

def send_email(to_email, script_code):
    msg = MIMEText(script_code)
    msg["Subject"] = "Voici ton script Python généré !"
    msg["From"] = SMTP_USER
    msg["To"] = to_email

    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USER, SMTP_PASSWORD)
        server.send_message(msg)

@app.route("/webhook", methods=["POST"])
def webhook():
    data = request.json
    form_response = data["form_response"]

    answers = {a["field"]["ref"]: a.get("text") or a.get("boolean") or a.get("email") for a in form_response["answers"]}

    prompt = f"""Génère un script Python selon ces spécifications :
Objectif : {answers.get('goal')}
API à utiliser : {answers.get('api_usage')}
Fichiers à manipuler : {answers.get('file_usage')}
Autres specs : {answers.get('extra')}
"""

    script = generate_script(prompt)
    send_email(answers.get("email"), script)
    return "ok", 200

if __name__ == "__main__":
    app.run(port=5000)
