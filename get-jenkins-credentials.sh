#!/bin/bash

# Скрипт для отримання Jenkins credentials

echo "=================================================="
echo "           JENKINS LOGIN CREDENTIALS"
echo "=================================================="
echo
echo "📍 Jenkins URL (port-forward):"
echo "   kubectl port-forward -n jenkins service/jenkins 8080:80"
echo "   http://localhost:8080"
echo
echo "📍 Jenkins URL (AWS LoadBalancer):"
kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "   LoadBalancer DNS ще не готовий"
echo
echo "🔑 Login Credentials:"
echo "   Username: admin"
echo -n "   Password: "
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-password}" 2>/dev/null | base64 -d || echo "H@dyRlwgkI*D%DRR"
echo
echo
echo "📋 Конфігурація знаходиться в:"
echo "   modules/jenkins/values.yaml"
echo
echo "🔧 Для зміни пароля:"
echo "   1. Редагувати modules/jenkins/values.yaml"
echo "   2. helm upgrade jenkins..."
echo "   3. kubectl rollout restart deployment jenkins -n jenkins"
echo
echo "=================================================="
