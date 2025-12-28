import pytest
from app import app


def test_health():
    with app.test_client() as client:
        rv = client.get('/health')
        assert rv.status_code == 200
        data = rv.get_json()
        assert 'status' in data


def test_quantum_text():
    with app.test_client() as client:
        rv = client.post('/quantum_text', json={'text': 'Hello world'})
        # If qiskit is not installed in this environment the endpoint returns 503 with helpful message.
        if rv.status_code == 200:
            data = rv.get_json()
            assert 'transformed' in data
        elif rv.status_code == 503:
            data = rv.get_json()
            assert 'error' in data and 'qiskit' in data.get('message', '').lower()
        else:
            pytest.fail(f"Unexpected status code: {rv.status_code} - {rv.data.decode()}")
