from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <h1>CI/CD Human Error Reduction Demo</h1>
    <p>Version 1.3 deployed automatically through GitHub Actions.</p>
    <p>This project demonstrates how automation prevents wrong-version and skipped-validation deployments.</p>
    """

@app.route("/health")
def health():
    return {"status": "healthy", "version": "1.3"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
