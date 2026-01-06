# Deployment aplikacji do Google Kubernetes Engine (GKE)

## Status plików

✅ **deployment.yaml** - gotowy
✅ **service.yaml** - gotowy  
✅ **Obraz Docker** - otagowany dla Artifact Registry
✅ **gcloud** - zainstalowany i skonfigurowany
✅ **kubectl** - zainstalowany

## ⚠️ Brakuje: Klaster GKE

Nie masz jeszcze klastra Kubernetes w GKE. Musisz go utworzyć.

---

## 🌐 Opcja 1: Utwórz klaster przez przeglądarkę (ZALECANE)

### Krok 1: Otwórz Google Cloud Console

1. Przejdź do: https://console.cloud.google.com/kubernetes/list
2. Upewnij się, że wybrany jest projekt: `project-e2a4c0c6-d515-440a-abd`

### Krok 2: Utwórz klaster GKE

1. Kliknij **"CREATE"** lub **"UTWÓRZ KLASTER"**
2. Wybierz **"GKE Standard"** (lub Autopilot dla prostszej konfiguracji)

### Krok 3: Konfiguracja klastra (Standard)

**Podstawowe ustawienia:**
- **Nazwa klastra:** `devops-cluster` (lub dowolna nazwa)
- **Region:** `europe-central2` (ten sam co Artifact Registry!)
- **Typ klastra:** Zonal lub Regional (Regional = bardziej niezawodny)

**Node pool (pula węzłów):**
- **Liczba węzłów:** 1-3 (dla testów wystarczy 1)
- **Typ maszyny:** `e2-medium` (2 vCPU, 4GB RAM) - wystarczy dla testów
- **Typ dysku:** Standard persistent disk
- **Rozmiar dysku:** 10-20 GB

**Opcje zaawansowane (opcjonalne):**
- **Włącz Workload Identity** - zalecane dla bezpieczeństwa
- **Włącz HTTP Load Balancing** - potrzebne dla LoadBalancer Service
- **Włącz monitoring i logging** - zalecane

### Krok 4: Utwórz klaster

1. Kliknij **"CREATE"** na dole strony
2. Poczekaj 5-10 minut na utworzenie klastra

---

## 💻 Opcja 2: Utwórz klaster przez terminal

```bash
# Utwórz klaster GKE (Standard)
gcloud container clusters create devops-cluster \
  --region europe-central2 \
  --num-nodes 1 \
  --machine-type e2-medium \
  --disk-size 20 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 3 \
  --enable-autorepair \
  --enable-autoupgrade \
  --project project-e2a4c0c6-d515-440a-abd

# LUB Utwórz klaster GKE Autopilot (prostszy, zarządzany przez Google)
gcloud container clusters create-auto devops-cluster-autopilot \
  --region europe-central2 \
  --project project-e2a4c0c6-d515-440a-abd
```

**Uwaga:** Tworzenie klastra zajmie 5-10 minut.

---

## 📤 Po utworzeniu klastra - Deployment aplikacji

### Metoda 1: Użyj skryptu (ZALECANE)

1. **Edytuj skrypt** `deploy-to-gke.sh`:
   ```bash
   nano deploy-to-gke.sh
   ```
   
2. **Zmień nazwę klastra** w linii 13:
   ```bash
   CLUSTER_NAME="devops-cluster"  # Wpisz nazwę swojego klastra
   ```

3. **Uruchom skrypt:**
   ```bash
   ./deploy-to-gke.sh
   ```

### Metoda 2: Ręcznie krok po kroku

```bash
# 1. Pobierz credentials do klastra
gcloud container clusters get-credentials devops-cluster \
  --region europe-central2 \
  --project project-e2a4c0c6-d515-440a-abd

# 2. Sprawdź połączenie
kubectl get nodes

# 3. Deploy aplikacji
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 4. Sprawdź status
kubectl get pods
kubectl get services
```

### Metoda 3: Przez przeglądarkę (Google Cloud Console)

1. Przejdź do: https://console.cloud.google.com/kubernetes/workload
2. Kliknij **"DEPLOY"**
3. Wybierz **"Upload YAML"**
4. Wklej zawartość `deployment.yaml`, kliknij **"DEPLOY"**
5. Powtórz dla `service.yaml`

---

## 🔍 Weryfikacja po deployment

### Sprawdź pody
```bash
kubectl get pods -l app=devops-app
```

Oczekiwany wynik:
```
NAME                                    READY   STATUS    RESTARTS   AGE
devops-app-deployment-xxxxxxxxx-xxxxx   1/1     Running   0          1m
```

### Sprawdź service i uzyskaj zewnętrzny IP
```bash
kubectl get service devops-app-service
```

Oczekiwany wynik (po kilku minutach):
```
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
devops-app-service   LoadBalancer   10.x.x.x        34.xxx.xxx.xxx   80:xxxxx/TCP   2m
```

### Testuj aplikację

Gdy EXTERNAL-IP się pojawi:
```bash
# Pobierz IP
EXTERNAL_IP=$(kubectl get service devops-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Testuj aplikację
curl http://$EXTERNAL_IP/
curl http://$EXTERNAL_IP/metrics
```

Lub otwórz w przeglądarce: `http://EXTERNAL-IP/`

---

## 📊 Monitoring

### Logi aplikacji
```bash
kubectl logs -l app=devops-app --tail=50 -f
```

### Metryki Prometheus
```
http://EXTERNAL-IP/metrics
```

---

## 💰 Koszty (szacunkowe)

**Klaster GKE Standard:**
- 1 węzeł e2-medium: ~$25/miesiąc
- LoadBalancer: ~$18/miesiąc
- **Razem:** ~$43/miesiąc

**Klaster GKE Autopilot:**
- Płacisz tylko za zasoby podów
- Dla 1 małego poda: ~$10-15/miesiąc

**💡 Tip:** Usuń klaster po testach, żeby nie płacić:
```bash
gcloud container clusters delete devops-cluster --region europe-central2
```

---

## 🎯 Podsumowanie kroków

1. ✅ Pliki deployment.yaml i service.yaml - gotowe
2. ⏳ **Utwórz klaster GKE** (przez przeglądarkę lub terminal)
3. ⏳ **Wypchnij obraz do Artifact Registry:** `./push-to-gar.sh`
4. ⏳ **Deploy aplikacji:** `./deploy-to-gke.sh` (lub przez przeglądarkę)
5. ⏳ **Sprawdź EXTERNAL-IP:** `kubectl get service devops-app-service`
6. ⏳ **Testuj aplikację:** Otwórz `http://EXTERNAL-IP/`

**Która metoda Cię interesuje?**
- Przeglądarka (łatwiejsza, wizualna)
- Terminal (szybsza, automatyczna)
