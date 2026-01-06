#!/bin/bash
# Skrypt do deployment aplikacji do Google Kubernetes Engine (GKE)

set -e

echo "🚀 Deployment aplikacji DevOps do GKE"
echo "======================================"
echo ""

# Konfiguracja
PROJECT_ID="project-e2a4c0c6-d515-440a-abd"
REGION="europe-central2"
CLUSTER_NAME="your-cluster-name"  # ZMIEŃ NA NAZWĘ SWOJEGO KLASTRA!

echo "📋 Konfiguracja:"
echo "   Project: ${PROJECT_ID}"
echo "   Region: ${REGION}"
echo "   Cluster: ${CLUSTER_NAME}"
echo ""

# Krok 1: Ustaw projekt GCP
echo "1️⃣ Ustawianie projektu GCP..."
gcloud config set project ${PROJECT_ID}

# Krok 2: Pobierz credentials do klastra GKE
echo ""
echo "2️⃣ Pobieranie credentials do klastra GKE..."
gcloud container clusters get-credentials ${CLUSTER_NAME} \
  --region ${REGION} \
  --project ${PROJECT_ID}

# Krok 3: Sprawdź połączenie
echo ""
echo "3️⃣ Sprawdzanie połączenia z klastrem..."
kubectl cluster-info
kubectl get nodes

# Krok 4: Deploy aplikacji
echo ""
echo "4️⃣ Deployowanie aplikacji..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Krok 5: Sprawdź status
echo ""
echo "5️⃣ Sprawdzanie statusu deployment..."
kubectl get deployments
kubectl get pods -l app=devops-app
kubectl get services devops-app-service

echo ""
echo "✅ Deployment zakończony!"
echo ""
echo "📊 Aby zobaczyć logi aplikacji:"
echo "   kubectl logs -l app=devops-app --tail=50"
echo ""
echo "🌐 Aby uzyskać zewnętrzny IP (LoadBalancer):"
echo "   kubectl get service devops-app-service"
echo "   (Poczekaj kilka minut, aż EXTERNAL-IP się pojawi)"
