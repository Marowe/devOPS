# Integracja z Prometheus i Grafana + Deployment do Google Artifact Registry

## ✅ Weryfikacja integracji z Prometheus i Grafana

### Prometheus Integration

**Status:** ✅ W pełni zintegrowane

Aplikacja eksportuje metryki Prometheus na endpoincie `/metrics`:

```bash
curl http://localhost:5000/metrics
```

**Dostępne metryki:**
- `app_counter_total` - Główny licznik aplikacji (inkrementuje się co minutę)
- `python_gc_*` - Metryki garbage collectora Python
- `process_*` - Metryki procesu (CPU, pamięć, czas startu)

**Konfiguracja Prometheus** (`prometheus/prometheus.yml`):
```yaml
scrape_configs:
  - job_name: 'devops-stack-app'
    static_configs:
      - targets: ['devops-counter:5000']
    metrics_path: '/metrics'
```

### Grafana Integration

**Status:** ✅ Gotowe do wizualizacji

Aplikacja jest kompatybilna z Grafaną poprzez Prometheus jako źródło danych.

**Deployment Grafany:** `k8s/monitoring/grafana-deployment.yaml`

**Przykładowe zapytania PromQL dla dashboardu:**
```promql
# Wartość licznika
app_counter_total

# Tempo wzrostu licznika
rate(app_counter_total[5m])

# Użycie pamięci
process_resident_memory_bytes / 1024 / 1024

# Użycie CPU
rate(process_cpu_seconds_total[1m])
```

## 🐳 Przygotowanie obrazu Docker dla Google Artifact Registry

### Zbudowany obraz

**Nazwa lokalna:** `devops-app:latest`
**Rozmiar:** 133MB
**Base image:** `python:3.9-slim`

### Tagi dla Artifact Registry

Obraz został otagowany dla Google Artifact Registry:

```bash
# Tag 'latest'
europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app:latest

# Tag 'v1.0'
europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app:v1.0
```

**Weryfikacja:**
```bash
docker images | grep devops-app
```

Wynik:
```
europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app   latest   957bc0df6cbc   5 weeks ago   133MB
europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app   v1.0     957bc0df6cbc   5 weeks ago   133MB
devops-app                                                                           latest   957bc0df6cbc   5 weeks ago   133MB
```

## 📤 Wypychanie do Google Artifact Registry

### Wymagania

1. **Google Cloud CLI** - zainstaluj jeśli nie masz:
```bash
sudo snap install google-cloud-cli --classic
```

2. **Uwierzytelnienie GCP:**
```bash
gcloud auth login
gcloud config set project project-e2a4c0c6-d515-440a-abd
```

### Metoda 1: Użyj skryptu (ZALECANE)

Utworzony został skrypt `push-to-gar.sh`:

```bash
cd /home/mario/.gemini/antigravity/scratch/devops-stack/app
./push-to-gar.sh
```

Skrypt automatycznie:
- Konfiguruje Docker authentication
- Wypycha obraz z tagiem `latest`
- Wypycha obraz z tagiem `v1.0`

### Metoda 2: Ręcznie

```bash
# 1. Konfiguracja Docker dla Artifact Registry
gcloud auth configure-docker europe-central2-docker.pkg.dev

# 2. Push obrazu z tagiem 'latest'
docker push europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app:latest

# 3. Push obrazu z tagiem 'v1.0'
docker push europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app:v1.0
```

## 🎯 Użycie obrazu w Kubernetes

Po wypchaniu obrazu do Artifact Registry, możesz go użyć w deploymentach Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-counter-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: devops-counter
  template:
    metadata:
      labels:
        app: devops-counter
    spec:
      containers:
      - name: app
        image: europe-central2-docker.pkg.dev/project-e2a4c0c6-d515-440a-abd/kontenery/devops-app:v1.0
        ports:
        - containerPort: 5000
          name: http
        livenessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /metrics
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: devops-counter-service
  labels:
    app: devops-counter
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
    protocol: TCP
    name: http
  selector:
    app: devops-counter
```

## 📊 Monitoring w Kubernetes

### ServiceMonitor dla Prometheus Operator

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: devops-counter-monitor
  labels:
    app: devops-counter
spec:
  selector:
    matchLabels:
      app: devops-counter
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

## 🔐 Uwierzytelnienie w Kubernetes

Jeśli Twój klaster Kubernetes potrzebuje dostępu do prywatnego Artifact Registry:

```bash
# Utwórz secret dla Docker registry
kubectl create secret docker-registry gar-secret \
  --docker-server=europe-central2-docker.pkg.dev \
  --docker-username=_json_key \
  --docker-password="$(cat ~/key.json)" \
  --docker-email=your-email@example.com
```

Następnie dodaj do deploymentu:
```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: gar-secret
```

## 📝 Podsumowanie

✅ **Aplikacja jest w pełni zintegrowana z Prometheus:**
- Endpoint `/metrics` eksportuje metryki
- Konfiguracja Prometheus gotowa do scrapowania

✅ **Aplikacja jest gotowa do wizualizacji w Grafanie:**
- Metryki dostępne przez Prometheus
- Deployment Grafany istnieje

✅ **Obraz Docker przygotowany:**
- Zbudowany i otagowany dla Google Artifact Registry
- Dwa tagi: `latest` i `v1.0`
- Rozmiar: 133MB

✅ **Gotowe do deployment:**
- Skrypt `push-to-gar.sh` do wypchania obrazu
- Przykładowe manifesty Kubernetes
- Konfiguracja ServiceMonitor dla Prometheus Operator

## 🚀 Następne kroki

1. Zainstaluj Google Cloud CLI (jeśli nie masz)
2. Uwierzytelnij się w GCP
3. Uruchom `./push-to-gar.sh`
4. Deploy do Kubernetes używając manifestów powyżej
5. Skonfiguruj Grafana dashboard do wizualizacji metryk
