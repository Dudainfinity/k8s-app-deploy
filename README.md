# Deploy em Kubernetes (local com kind/minikube)

Conteinerização de uma aplicação web e deploy em um cluster **Kubernetes local**
(sem custo de nuvem), feito de **duas formas**: com **manifests crus**
(Deployment, Service, Ingress, ConfigMap) e com um **Helm chart** equivalente.

A aplicação responde com o **nome do Pod** que a atendeu — assim dá pra ver o
**balanceamento de carga** entre as 3 réplicas na prática.

> Projeto de portfólio com foco em **Kubernetes / Orquestração de Containers** —
> a competência mais pedida em vagas de DevOps hoje.

---

## 🧩 O que é provisionado

| Recurso | Função |
|---|---|
| **Deployment** (3 réplicas) | Roda a aplicação com liveness/readiness probes e limites de recurso |
| **Service** (ClusterIP) | Expõe e balanceia entre os Pods |
| **Ingress** (NGINX) | Acesso externo via `http://app.localhost` |
| **ConfigMap** | Injeta a versão da app via variável de ambiente |

Mesma stack disponível como **Helm chart** parametrizável em `helm/k8s-app`.

---

## 📁 Estrutura

```
k8s-app-deploy/
├── app/                        # Aplicação Flask conteinerizada
│   ├── app.py                  #   retorna o nome do Pod (mostra o balanceamento)
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/                        # Manifests crus
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── helm/k8s-app/               # Mesma stack como Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── kind-config.yaml            # Cluster kind com suporte a Ingress
└── Makefile                    # Atalhos para subir tudo
```

---

## 🚀 Passo a passo (com kind)

Pré-requisitos: Docker, kubectl e [kind](https://kind.sigs.k8s.io/) (ou minikube).

```bash
# 1. Cria o cluster local
make cluster

# 2. Instala o Ingress NGINX
make ingress

# 3. Builda a imagem da app e carrega no cluster
make build
make load

# 4a. Deploy com os manifests crus...
make deploy

#   ...OU 4b. deploy com Helm (escolha um)
make helm

# 5. Acessa a app
#   adicione "127.0.0.1 app.localhost" ao /etc/hosts e abra:
#   http://app.localhost
```

Atualize a página algumas vezes: o campo `"pod"` muda, mostrando o
**balanceamento entre as réplicas**.

```json
{ "message": "Deploy em Kubernetes funcionando!", "pod": "k8s-app-7d9c...", "version": "1.0" }
```

---

## 🟣 Alternativa com minikube

```bash
minikube start
minikube addons enable ingress

# usa o Docker de dentro do minikube para a imagem ficar disponível no cluster
eval $(minikube docker-env)
docker build -t k8s-app:1.0 ./app

kubectl apply -f k8s/         # ou: make helm
minikube tunnel               # para o Ingress responder
```

---

## 🔍 Comandos úteis

```bash
kubectl -n demo get pods,svc,ingress      # ver tudo que subiu
kubectl -n demo get pods -o wide          # ver as réplicas
kubectl -n demo logs -l app=k8s-app       # logs de todos os Pods
kubectl -n demo scale deploy/k8s-app --replicas=5   # escalar
kubectl -n demo port-forward svc/k8s-app 8080:80    # acesso sem Ingress
```

---

## 🧰 Stack

`Kubernetes` · `Docker` · `kind / minikube` · `Helm` · `Ingress NGINX` · `Python (Flask)`

---

Feito por **Maria Eduarda** — foco em DevOps & Cloud (AWS).
[GitHub](https://github.com/Dudainfinity)
