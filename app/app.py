import os

from flask import Flask

app = Flask(__name__)

# Set by the deploy workflow so every response can prove which color
# actually answered it — the same "verify with a real command, not a
# green checkmark" habit as the rest of this portfolio.
COLOR = os.environ.get("DEPLOY_COLOR", "unknown")
VERSION = os.environ.get("APP_VERSION", "1.3")


@app.route("/")
def home():
    return f"""
    <h1>CI/CD Human Error Reduction Demo</h1>
    <p>Version {VERSION} ({COLOR}) deployed automatically through GitHub Actions.</p>
    <p>This project demonstrates how automation prevents wrong-version and skipped-validation deployments.</p>
    """

@app.route("/health")
def health():
    return {"status": "healthy", "version": VERSION, "color": COLOR}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
