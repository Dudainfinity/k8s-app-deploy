import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    # Retorna o nome do Pod (hostname) para dar pra ver o balanceamento
    # de carga entre as réplicas do Deployment.
    return jsonify(
        {
            "message": "Deploy em Kubernetes funcionando!",
            "pod": socket.gethostname(),
            "version": os.environ.get("APP_VERSION", "desconhecida"),
        }
    )


@app.route("/healthz")
def health():
    # Endpoint usado pelos probes de liveness e readiness do Kubernetes.
    return "ok", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
