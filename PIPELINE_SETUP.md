# Створення Django Pipeline в Jenkins

## 📋 Покрокова інструкція

### 1. Відкрити Jenkins Dashboard
**URL:** http://a73c7f005f34940dda9ffc5bdb233cfe-2065428861.eu-central-1.elb.amazonaws.com

**Credentials:**
- **Username:** `user`
- **Password:** `qVY3gnhwbL`

### 2. Створити новий Pipeline Job

1. **Натисніть:** "New Item" (у лівій панелі)
2. **Enter an item name:** `django-pipeline`
3. **Оберіть:** "Pipeline"
4. **Натисніть:** "OK"

### 3. Налаштування Pipeline

#### General Settings:
- **Description:** `CI/CD Pipeline for Django application with ECR and ArgoCD`
- **✅ GitHub project:** `https://github.com/IYgit/lesson-8-9`

#### Build Triggers:
- **✅ Poll SCM:** `H/2 * * * *` (перевіряє кожні 2 хвилини)
- **✅ GitHub hook trigger for GITScm polling** (для webhook)

#### Pipeline Definition:
- **Definition:** `Pipeline script from SCM`
- **SCM:** `Git`
- **Repository URL:** `https://github.com/IYgit/lesson-8-9.git`
- **Credentials:** (поки що None, але потрібно буде додати для push)
- **Branches to build:** `*/main`
- **Script Path:** `Jenkinsfile`

### 4. Advanced Options (Optional)

#### Additional Behaviours:
- **✅ Clean before checkout** (рекомендовано)
- **✅ Shallow clone** depth: 1

#### Pipeline Syntax:
```groovy
// Наш Jenkinsfile вже налаштований з:
// - Kubernetes agents (Kaniko + Git)
// - ECR push з тегуванням
// - Helm chart update
// - Git commit та push
```

### 5. Збереження та тестування

1. **Натисніть:** "Save"
2. **Натисніть:** "Build Now" для першого тесту
3. **Перегляд логів:** Console Output

## 🔧 Налаштування Git Credentials (для push)

### Для push змін в Git репозиторій потрібні credentials:

1. **Dashboard** → **Manage Jenkins** → **Manage Credentials**
2. **Global credentials** → **Add Credentials**
3. **Kind:** `Username with password`
4. **Username:** `IYgit` (ваш GitHub username)
5. **Password:** `<GitHub Personal Access Token>`
6. **ID:** `github-credentials`
7. **Description:** `GitHub credentials for push`

### Оновити Jenkinsfile з credentials:
```groovy
// В stage('Update Helm Chart') додати:
withCredentials([usernamePassword(
    credentialsId: 'github-credentials',
    usernameVariable: 'GIT_USERNAME',
    passwordVariable: 'GIT_PASSWORD'
)]) {
    sh """
        git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/IYgit/lesson-8-9.git
        git push origin HEAD:main
    """
}
```

## 🚀 Automatic Builds

### GitHub Webhook (коли LoadBalancer буде стабільний):
1. **GitHub** → **Settings** → **Webhooks**
2. **Payload URL:** `http://a73c7f005f34940dda9ffc5bdb233cfe-2065428861.eu-central-1.elb.amazonaws.com/github-webhook/`
3. **Content type:** `application/json`
4. **Events:** Just the push event

## 📊 Pipeline Stages

Наш Jenkinsfile включає:

1. **✅ Check Branch** - виконується тільки для main
2. **✅ Checkout** - клонує код з Git
3. **✅ Build and Push to ECR** - збирає Docker образ з Kaniko
4. **✅ Update Helm Chart** - оновлює values.yaml з новим тегом
5. **✅ Deploy with ArgoCD** - ArgoCD автоматично синхронізує

## 🔍 Monitoring та Logs

### Корисні команди для діагностики:
```bash
# Перевірити ECR images
aws ecr describe-images --repository-name dev-lesson-5-app --region eu-central-1

# Перевірити ArgoCD apps
kubectl get applications -n argocd

# Перевірити Jenkins pods
kubectl get pods -n jenkins

# Pipeline logs в Jenkins UI
Dashboard → django-pipeline → Build History → Console Output
```

## 🎯 Очікуваний результат

Після успішного налаштування:
1. **Push в main** → автоматичний тригер
2. **Docker build** → push до ECR
3. **Helm update** → commit в Git
4. **ArgoCD sync** → deployment в Kubernetes

**Jenkins Dashboard URL:** http://a73c7f005f34940dda9ffc5bdb233cfe-2065428861.eu-central-1.elb.amazonaws.com
