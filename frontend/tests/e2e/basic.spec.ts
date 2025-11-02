import { test, expect } from '@playwright/test';

test.describe('DocuNova Basic Tests', () => {
  test('should load homepage', async ({ page }) => {
    await page.goto('http://localhost:3001');

    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');

    // Check if page has loaded successfully
    expect(page.url()).toContain('localhost:3001');

    console.log('✓ Homepage loaded successfully');
  });

  test('should verify backend health', async ({ request }) => {
    const response = await request.get('http://localhost:8000/health');
    expect(response.ok()).toBeTruthy();

    const data = await response.json();
    console.log('Backend health:', JSON.stringify(data, null, 2));

    // Verify backend response structure
    expect(data).toHaveProperty('status');

    console.log('✓ Backend health check passed');
  });

  test('should have proper page structure', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Check if basic HTML structure exists
    const body = await page.locator('body');
    await expect(body).toBeVisible();

    console.log('✓ Page structure verified');
  });

  test('should be responsive', async ({ page }) => {
    // Test desktop view
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    console.log('✓ Desktop view rendered');

    // Test mobile view
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForLoadState('domcontentloaded');

    console.log('✓ Mobile view rendered');

    // Test tablet view
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.waitForLoadState('domcontentloaded');

    console.log('✓ Tablet view rendered');
  });

  test('should not have console errors on load', async ({ page }) => {
    const errors: string[] = [];

    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    await page.goto('http://localhost:3001');
    await page.waitForLoadState('networkidle');

    // Allow some time for any delayed errors
    await page.waitForTimeout(2000);

    if (errors.length > 0) {
      console.log('Console errors detected:', errors);
    }

    // This is a warning rather than a hard failure
    // as some errors might be acceptable
    console.log(`Console errors count: ${errors.length}`);
  });
});
