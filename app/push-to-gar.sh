#!/bin/bash
set -e

# Konfiguracja
PROJECT_ID="project-e2a4c0c6-d515-440a-abd"
REGION="europe-central2"
REPOSITORY="kontenery"
IMAGE_NAME="devops-app"

# Pełna nazwa obrazu
FULL_IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}"

echo "🚀 Wypychanie obrazu do Google Artifact Registry..."
echo "📦 Obraz: ${FULL_IMAGE_NAME}"
echo ""

# Krok 1: Konfiguracja Docker dla Artifact Registry
echo "1️⃣ Konfiguracja Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Krok 2: Wypchanie obrazu z tagiem 'latest'
echo ""
echo "2️⃣ Wypychanie obrazu z tagiem 'latest'..."
docker push ${FULL_IMAGE_NAME}:latest

# Krok 3: Wypchanie obrazu z tagiem 'v1.0'
echo ""
echo "3️⃣ Wypychanie obrazu z tagiem 'v1.0'..."
docker push ${FULL_IMAGE_NAME}:v1.0

echo ""
echo "✅ Obrazy zostały pomyślnie wypchnięte do Artifact Registry!"
echo ""
echo "📋 Dostępne obrazy:"
echo "   - ${FULL_IMAGE_NAME}:latest"
echo "   - ${FULL_IMAGE_NAME}:v1.0"
echo ""
echo "🔗 Możesz je użyć w Kubernetes:"
echo "   image: ${FULL_IMAGE_NAME}:v1.0"
