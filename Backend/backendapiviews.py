import requests
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from datetime import datetime, timedelta


# ============================================================
# 🔧 FHIR SETTINGS
# ============================================================
FHIR_BASE = settings.FHIR_BASE_URL  # z.B. "http://localhost:8080/fhir"
FHIR_HEADERS = {
    "Content-Type": "application/fhir+json"
}


# ============================================================
# 🔥 1) Sensor Movement Event -> FHIR Observation
# ============================================================
@api_view(["POST"])
def send_movement_event(request):
    """
    Flutter sendet:
    {
        "patient_id": "123",
        "intensity": 0.82
    }
    """
    patient_id = request.data.get("patient_id")
    intensity = request.data.get("intensity")

    if not patient_id or intensity is None:
        return Response({"error": "Missing parameters"}, status=400)

    obs = {
        "resourceType": "Observation",
        "status": "preliminary",
        "code": {"text": "RLS movement event"},
        "effectiveDateTime": datetime.utcnow().isoformat(),
        "subject": {"reference": f"Patient/{patient_id}"},
        "valueQuantity": {
            "value": float(intensity),
            "unit": "g-force"
        }
    }

    r = requests.post(f"{FHIR_BASE}/Observation", json=obs, headers=FHIR_HEADERS)

    return Response({"success": r.status_code == 201})


# ============================================================
# 🔥 2) Episode speichern -> FHIR Observation
# ============================================================
@api_view(["POST"])
def send_episode(request):
    """
    Flutter sendet:
    {
        "patient_id": "123",
        "start": "2025-01-22T22:58:00Z",
        "end": "2025-01-22T23:01:15Z",
        "total_intensity": 12.5
    }
    """
    data = request.data
    patient_id = data.get("patient_id")

    if not patient_id:
        return Response({"error": "Missing patient_id"}, status=400)

    duration_seconds = (
        datetime.fromisoformat(data["end"]) -
        datetime.fromisoformat(data["start"])
    ).total_seconds()

    obs = {
        "resourceType": "Observation",
        "status": "final",
        "code": {"text": "RLS Episode"},
        "effectiveDateTime": data["start"],
        "subject": {"reference": f"Patient/{patient_id}"},
        "component": [
            {"code": {"text": "duration"}, "valueQuantity": {"value": duration_seconds, "unit": "s"}},
            {"code": {"text": "total_intensity"}, "valueQuantity": {"value": data["total_intensity"], "unit": "sum"}}
        ]
    }

    r = requests.post(f"{FHIR_BASE}/Observation", json=obs, headers=FHIR_HEADERS)

    return Response({"success": r.status_code == 201})


# ============================================================
# 📜 3) Historie laden (alle Observations)
# ============================================================
@api_view(["GET"])
def load_history(request, patient_id):
    """
    Lädt alle Bewegungs- und Episoden-Observations eines Patienten.
    """
    r = requests.get(
        f"{FHIR_BASE}/Observation?patient={patient_id}",
        headers=FHIR_HEADERS
    )

    data = r.json()

    result = []
    for entry in data.get("entry", []):
        obs = entry["resource"]
        timestamp = obs.get("effectiveDateTime")
        obs_type = obs.get("code", {}).get("text", "Unknown")

        result.append(f"{timestamp} — {obs_type}")

    return Response(result)


# ============================================================
# 📊 4) Tagesstatistik (für Graphen)
# ============================================================
@api_view(["GET"])
def daily_stats(request, patient_id):
    """
    Gibt alle Events der letzten 24h zurück.
    Flutter verwendet diese Daten für Graphen.
    """
    since = (datetime.utcnow() - timedelta(hours=24)).isoformat()

    r = requests.get(
        f"{FHIR_BASE}/Observation?patient={patient_id}&date=ge{since}",
        headers=FHIR_HEADERS
    )

    data = r.json()

    events = []
    for entry in data.get("entry", []):
        obs = entry["resource"]
        ts = obs.get("effectiveDateTime")
        val = obs.get("valueQuantity", {}).get("value")
        ev_type = obs.get("code", {}).get("text")

        events.append({
            "time": ts,
            "value": val,
            "type": ev_type
        })

    return Response({"events": events})


# ============================================================
# 📥 5) Fragebögen abrufen (Arzt -> Patient)
# ============================================================
@api_view(["GET"])
def get_questionnaires(request, patient_id):
    """
    Holt alle Fragebögen, die dem Patienten zugewiesen wurden.
    Entspricht FHIR Questionnaire + QuestionnaireResponse.
    """
    r = requests.get(
        f"{FHIR_BASE}/Questionnaire?subject={patient_id}",
        headers=FHIR_HEADERS
    )

    data = r.json()

    questionnaires = [
        entry["resource"]
        for entry in data.get("entry", [])
    ]

    return Response(questionnaires)


# ============================================================
# 📝 6) Fragebogen-Antwort senden
# ============================================================
@api_view(["POST"])
def send_questionnaire_response(request):
    """
    Flutter sendet:
    {
        "patient_id": "123",
        "questionnaire_id": "xyz",
        "answers": [
            {"linkId": "1", "valueString": "Ja"},
            {"linkId": "2", "valueInteger": 4}
        ]
    }
    """
    data = request.data

    resource = {
        "resourceType": "QuestionnaireResponse",
        "status": "completed",
        "subject": {"reference": f"Patient/{data['patient_id']}"},
        "questionnaire": f"Questionnaire/{data['questionnaire_id']}",
        "item": [
            {
                "linkId": a["linkId"],
                "answer": [{k: v for k, v in a.items() if k != "linkId"}]
            }
            for a in data["answers"]
        ]
    }

    r = requests.post(f"{FHIR_BASE}/QuestionnaireResponse", json=resource, headers=FHIR_HEADERS)

    return Response({"success": r.status_code == 201})
