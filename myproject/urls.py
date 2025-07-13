"""myproject URL Configuration"""
from django.contrib import admin
from django.urls import path
from django.http import HttpResponse

def health_check(request):
    return HttpResponse("OK - Django app is running!")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health'),
    path('', health_check, name='home'),
]
