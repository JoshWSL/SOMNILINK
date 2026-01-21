from django.urls import path
from .views import movement_event

urlpatterns = [
    path("events/movement/", movement_event),
]
