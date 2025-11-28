# DevOps Stack Project

To jest prosta aplikacja w Pythonie (Flask), która została skonteneryzowana i przygotowana do wdrożenia w środowisku Kubernetes. Projekt demonstruje podstawowy stos DevOps/GitOps.

## Struktura Projektu

- `app/`: Kod źródłowy aplikacji Python oraz Dockerfile.
  - `app.py`: Główny plik aplikacji Flask. Udostępnia endpoint `/` oraz metryki Prometheus pod `/metrics`.
  - `Dockerfile`: Definicja obrazu kontenera.
- `k8s/`: Manifesty Kubernetes.
  - `app/`: Deployment i Ingress dla aplikacji.
  - `argocd/`: Konfiguracja dla Argo CD (opcjonalnie).

## Wymagania

- Docker
- Kubernetes (np. k3d, minikube, kind)
- kubectl

## Uruchomienie

### 1. Lokalnie z Dockerem

Aby zbudować i uruchomić aplikację lokalnie:

```bash
cd app
docker build -t devops-stack-app .
docker run -p 5000:5000 devops-stack-app
```

Aplikacja będzie dostępna pod adresem `http://localhost:5000`.
Metryki Prometheus: `http://localhost:5000/metrics`.

### 2. Wdrożenie na Kubernetes

Aby wdrożyć aplikację na klaster Kubernetes:

```bash
kubectl apply -f k8s/app/
```

Upewnij się, że masz skonfigurowany Ingress Controller, jeśli chcesz korzystać z Ingressa.

## Funkcje

- **Web Server**: Prosta strona powitalna zwracająca aktualny czas.
- **Monitoring**: Eksport metryk w formacie Prometheus (endpoint `/metrics`).
