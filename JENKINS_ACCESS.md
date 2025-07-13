# Jenkins Access Instructions

## Поточна ситуація
AWS LoadBalancer ще створюється, DNS не резолвиться. Використовуємо port-forward для доступу.

## 🔧 Доступ через Port-Forward

### 1. Запустити port-forward (якщо не запущений):
```bash
kubectl port-forward -n jenkins service/jenkins 8080:80
```

### 2. Відкрити Jenkins в браузері:
**URL:** http://localhost:8080

### 3. Логін:
- **Username:** user
- **Password:** SfAGo1vYai

## 🌐 Доступ через LoadBalancer (коли буде готовий)

### URL (може зайняти 5-10 хвилин для DNS):
- **Jenkins:** http://ad19d5d2091bc40dd9d9278b9076fa39-1885378173.eu-central-1.elb.amazonaws.com
- **Webhook:** http://ad19d5d2091bc40dd9d9278b9076fa39-1885378173.eu-central-1.elb.amazonaws.com/github-webhook/

### Перевірка доступності:
```bash
curl -I http://ad19d5d2091bc40dd9d9278b9076fa39-1885378173.eu-central-1.elb.amazonaws.com
```

## 📋 Налаштування Jenkins Job

### В Jenkins Dashboard:
1. **New Item** → **Pipeline** → назва: `django-pipeline`
2. **Pipeline** → **Definition:** Pipeline script from SCM
3. **SCM:** Git
4. **Repository URL:** https://github.com/IYgit/lesson-8-9.git
5. **Branch:** */main
6. **Script Path:** Jenkinsfile

### Build Triggers:
- ✅ **Poll SCM:** H/2 * * * *
- ✅ **GitHub hook trigger for GITScm polling** (коли LoadBalancer буде готовий)

## 🔍 Troubleshooting

### Якщо port-forward не працює:
```bash
# Перевірити статус
kubectl get pods -n jenkins
kubectl get svc -n jenkins

# Перезапустити port-forward
kubectl port-forward -n jenkins service/jenkins 8080:80
```

### Якщо LoadBalancer не готовий:
```bash
# Перевірити статус LoadBalancer
kubectl describe svc jenkins -n jenkins

# Перевірити DNS
nslookup a73c7f005f34940ddaa9ffc5bdb233cfe-2065428861.eu-central-1.elb.amazonaws.com
```

## ⏰ Очікувані часи
- **Port-forward:** Доступний негайно
- **LoadBalancer DNS:** 5-10 хвилин після створення
- **Jenkins startup:** 2-3 хвилини після pod запуску
