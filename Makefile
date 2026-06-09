IMAGE   := k8s-app:1.0
CLUSTER := devops-demo

.PHONY: help build cluster ingress load deploy helm logs url clean

help:
	@echo "Alvos disponíveis:"
	@echo "  make cluster   - cria o cluster kind"
	@echo "  make ingress   - instala o Ingress NGINX no cluster"
	@echo "  make build     - builda a imagem Docker da app"
	@echo "  make load      - carrega a imagem no cluster kind"
	@echo "  make deploy    - aplica os manifests crus (k8s/)"
	@echo "  make helm      - instala via Helm chart (helm/k8s-app)"
	@echo "  make url       - mostra como acessar a app"
	@echo "  make clean     - apaga o cluster"

build:
	docker build -t $(IMAGE) ./app

cluster:
	kind create cluster --name $(CLUSTER) --config kind-config.yaml

ingress:
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=120s

load:
	kind load docker-image $(IMAGE) --name $(CLUSTER)

deploy:
	kubectl apply -f k8s/

helm:
	helm upgrade --install k8s-app ./helm/k8s-app \
		--namespace demo --create-namespace

url:
	@echo "Adicione ao /etc/hosts:  127.0.0.1 app.localhost"
	@echo "Depois acesse:  http://app.localhost"
	@echo "Ou via port-forward:  kubectl -n demo port-forward svc/k8s-app 8080:80"

clean:
	kind delete cluster --name $(CLUSTER)
