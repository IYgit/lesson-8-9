# GitHub Webhook Setup для автоматичного білда Jenkins

## 1. Налаштування GitHub Webhook

### У GitHub репозиторії:
1. Перейти до **Settings** → **Webhooks** → **Add webhook**
2. **Payload URL:** `http://a3d338368a5dc4fa196b1df4e74f665c-337891972.eu-central-1.elb.amazonaws.com:8080/github-webhook/`
3. **Content type:** `application/json`
4. **Which events:** `Just the push event`
5. **Active:** ✅ Enabled
6. **SSL verification:** Disable SSL verification (для тестування)

## 2. Налаштування Jenkins Job

### В Jenkins Dashboard:
1. Відкрити job **django-pipeline**
2. **Configure** → **Build Triggers**
3. Увімкнути: ✅ **GitHub hook trigger for GITScm polling**
4. Увімкнути: ✅ **Poll SCM** з розкладом: `H/2 * * * *` (перевірка кожні 2 хв)
5. **Save**

## 3. Перевірка тригерів у Jenkinsfile

```groovy
pipeline {
    triggers {
        // Перевіряти Git репозиторій кожні 2 хвилини на предмет змін
        pollSCM('H/2 * * * *')
        // Автоматичний білд після GitHub push
        githubPush()
    }
    // ... решта конфігурації
}
```

## 4. Тестування

### Щоб перевірити автоматичний білд:
1. Зробити commit і push в main гілку
2. Webhook автоматично тригерить Jenkins
3. Перевірити в **Jenkins Console Output**

### URLs для налаштування:
- **Jenkins:** http://a3d338368a5dc4fa196b1df4e74f665c-337891972.eu-central-1.elb.amazonaws.com:8080
- **GitHub Webhook URL:** http://a3d338368a5dc4fa196b1df4e74f665c-337891972.eu-central-1.elb.amazonaws.com:8080/github-webhook/

### Логін Jenkins:
- **Username:** admin
- **Password:** H@dyRlwgkI*D%DRR

## 5. Альтернативні тригери

### Cron-based trigger:
```groovy
triggers {
    cron('@daily')  // Щоденно о 00:00
    cron('H 9 * * 1-5')  // Щодня о 9:00 в робочі дні
}
```

### Multi-branch trigger:
```groovy
triggers {
    pollSCM('H/5 * * * *')  // Кожні 5 хвилин
}
```

## 6. Troubleshooting

### Якщо webhook не працює:
1. Перевірити GitHub webhook delivery logs
2. Перевірити Jenkins System Log
3. Переконатися що Jenkins доступний ззовні
4. Перевірити firewall/security groups

### Корисні команди:
```bash
# Перевірити Jenkins logs
kubectl logs -n jenkins deployment/jenkins -f

# Перевірити webhook delivery в GitHub
# Settings → Webhooks → Recent Deliveries
```
