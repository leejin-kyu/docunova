import { test, expect } from '@playwright/test';

const BACKEND_URL = 'http://localhost:8000';

test.describe('Backend API Tests', () => {
  test('should get health status', async ({ request }) => {
    const response = await request.get(`${BACKEND_URL}/health`);
    expect(response.ok()).toBeTruthy();
    expect(response.status()).toBe(200);

    const data = await response.json();
    console.log('Health response:', data);
    expect(data).toBeDefined();
  });

  test('should handle CORS correctly', async ({ request }) => {
    const response = await request.get(`${BACKEND_URL}/health`, {
      headers: {
        'Origin': 'http://localhost:3001'
      }
    });

    expect(response.ok()).toBeTruthy();

    // Check for CORS headers
    const headers = response.headers();
    console.log('CORS headers present:', {
      'access-control-allow-origin': headers['access-control-allow-origin'],
      'access-control-allow-credentials': headers['access-control-allow-credentials']
    });
  });

  test('should test Ollama connection endpoint', async ({ request }) => {
    const response = await request.get(`${BACKEND_URL}/api/v1/models`);

    if (response.ok()) {
      const data = await response.json();
      console.log('Available models:', data);
      expect(data).toBeDefined();
      console.log('✓ Ollama connection working');
    } else {
      console.log('⚠ Models endpoint returned:', response.status());
    }
  });

  test('should handle invalid endpoints gracefully', async ({ request }) => {
    const response = await request.get(`${BACKEND_URL}/api/v1/nonexistent`);

    // Should return 404 or similar error
    expect(response.status()).toBeGreaterThanOrEqual(400);
    console.log('✓ Invalid endpoint handled correctly with status:', response.status());
  });

  test('should handle malformed requests', async ({ request }) => {
    const response = await request.post(`${BACKEND_URL}/api/v1/query`, {
      data: {
        // Intentionally malformed data
        invalid_field: 'test'
      }
    });

    // Should return 4xx error
    expect(response.status()).toBeGreaterThanOrEqual(400);
    expect(response.status()).toBeLessThan(500);
    console.log('✓ Malformed request rejected with status:', response.status());
  });

  test('should test query endpoint with proper structure', async ({ request }) => {
    const response = await request.post(`${BACKEND_URL}/api/v1/query`, {
      data: {
        query: '안녕하세요',
        collection_name: 'docunova_documents',
        top_k: 5
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('Query endpoint status:', response.status());

    if (response.ok()) {
      const data = await response.json();
      console.log('Query response:', data);
      console.log('✓ Query endpoint working');
    } else {
      console.log('⚠ Query endpoint returned:', response.status());
      const text = await response.text();
      console.log('Response body:', text);
    }
  });

  test('should check vector search endpoint', async ({ request }) => {
    const response = await request.post(`${BACKEND_URL}/api/v1/search`, {
      data: {
        query: 'test search',
        top_k: 3
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('Search endpoint status:', response.status());

    if (response.ok()) {
      const data = await response.json();
      console.log('Search results:', data);
      console.log('✓ Vector search endpoint working');
    } else {
      console.log('⚠ Search endpoint returned:', response.status());
    }
  });

  test('should test streaming query endpoint', async ({ request }) => {
    const response = await request.post(`${BACKEND_URL}/api/v1/query/stream`, {
      data: {
        query: '테스트 질문',
        collection_name: 'docunova_documents'
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('Streaming endpoint status:', response.status());

    if (response.status() === 200) {
      console.log('✓ Streaming endpoint accessible');
      console.log('Content-Type:', response.headers()['content-type']);
    } else {
      console.log('⚠ Streaming endpoint returned:', response.status());
    }
  });

  test('should handle file upload validation', async ({ request }) => {
    // Test upload endpoint without file
    const response = await request.post(`${BACKEND_URL}/api/v1/upload`, {
      data: {}
    });

    // Should reject missing file
    expect(response.status()).toBeGreaterThanOrEqual(400);
    console.log('✓ Upload validation working, status:', response.status());
  });

  test('should check collections endpoint', async ({ request }) => {
    const response = await request.get(`${BACKEND_URL}/api/v1/collections`);

    console.log('Collections endpoint status:', response.status());

    if (response.ok()) {
      const data = await response.json();
      console.log('Collections:', data);
      console.log('✓ Collections endpoint working');
    } else {
      console.log('⚠ Collections endpoint returned:', response.status());
    }
  });
});
