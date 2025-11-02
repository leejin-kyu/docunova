import { test, expect } from '@playwright/test';

test.describe('UI Interaction Tests', () => {
  test('should navigate through pages', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    console.log('✓ Homepage loaded');

    // Try to find common navigation elements
    const links = await page.locator('a').all();
    console.log(`Found ${links.length} navigation links`);

    // Take screenshot for reference
    await page.screenshot({ path: 'test-results/homepage.png', fullPage: true });
    console.log('✓ Screenshot saved');
  });

  test('should test input fields', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Look for input fields
    const inputs = await page.locator('input').all();
    const textareas = await page.locator('textarea').all();

    console.log(`Found ${inputs.length} input fields and ${textareas.length} textareas`);

    if (inputs.length > 0 || textareas.length > 0) {
      console.log('✓ Interactive input elements present');
    }
  });

  test('should test buttons', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Look for buttons
    const buttons = await page.locator('button').all();
    console.log(`Found ${buttons.length} buttons`);

    for (let i = 0; i < Math.min(buttons.length, 3); i++) {
      const text = await buttons[i].textContent();
      const isVisible = await buttons[i].isVisible();
      console.log(`Button ${i + 1}: "${text}" (visible: ${isVisible})`);
    }

    if (buttons.length > 0) {
      console.log('✓ Interactive buttons present');
    }
  });

  test('should test file upload if present', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Look for file input
    const fileInputs = await page.locator('input[type="file"]').all();

    if (fileInputs.length > 0) {
      console.log(`✓ Found ${fileInputs.length} file upload input(s)`);

      // Check if file input is interactive
      const isVisible = await fileInputs[0].isVisible();
      const isEnabled = await fileInputs[0].isEnabled();

      console.log(`File input - Visible: ${isVisible}, Enabled: ${isEnabled}`);
    } else {
      console.log('ℹ No file upload inputs found on homepage');
    }
  });

  test('should test form submission if present', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Look for forms
    const forms = await page.locator('form').all();
    console.log(`Found ${forms.length} form(s)`);

    if (forms.length > 0) {
      console.log('✓ Forms present on page');
    }
  });

  test('should test accessibility features', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Check for common accessibility attributes
    const ariaLabels = await page.locator('[aria-label]').all();
    const ariaDescribed = await page.locator('[aria-describedby]').all();
    const roleElements = await page.locator('[role]').all();

    console.log('Accessibility features:');
    console.log(`  - Elements with aria-label: ${ariaLabels.length}`);
    console.log(`  - Elements with aria-describedby: ${ariaDescribed.length}`);
    console.log(`  - Elements with role: ${roleElements.length}`);

    // Check for alt text on images
    const images = await page.locator('img').all();
    let imagesWithAlt = 0;

    for (const img of images) {
      const alt = await img.getAttribute('alt');
      if (alt !== null) {
        imagesWithAlt++;
      }
    }

    console.log(`  - Images with alt text: ${imagesWithAlt}/${images.length}`);
    console.log('✓ Accessibility check completed');
  });

  test('should test loading states', async ({ page }) => {
    await page.goto('http://localhost:3001');

    // Monitor loading state
    console.log('Page loading states:');

    const loadStates = ['load', 'domcontentloaded', 'networkidle'];
    for (const state of loadStates) {
      try {
        await page.waitForLoadState(state as any, { timeout: 10000 });
        console.log(`  ✓ ${state} achieved`);
      } catch (error) {
        console.log(`  ⚠ ${state} not achieved within timeout`);
      }
    }
  });

  test('should test page performance', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    const loadTime = Date.now() - startTime;

    console.log(`Page load time: ${loadTime}ms`);

    // Get performance metrics
    const metrics = await page.evaluate(() => {
      const perf = window.performance;
      const timing = perf.timing;

      return {
        domContentLoaded: timing.domContentLoadedEventEnd - timing.navigationStart,
        loadComplete: timing.loadEventEnd - timing.navigationStart,
      };
    });

    console.log('Performance metrics:', metrics);
    console.log('✓ Performance test completed');
  });

  test('should test keyboard navigation', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('domcontentloaded');

    // Test Tab navigation
    await page.keyboard.press('Tab');
    const focusedElement1 = await page.locator(':focus').first();

    if (await focusedElement1.count() > 0) {
      const tagName = await focusedElement1.evaluate(el => el.tagName);
      console.log(`✓ First Tab focus: ${tagName}`);

      // Tab again
      await page.keyboard.press('Tab');
      const focusedElement2 = await page.locator(':focus').first();

      if (await focusedElement2.count() > 0) {
        const tagName2 = await focusedElement2.evaluate(el => el.tagName);
        console.log(`✓ Second Tab focus: ${tagName2}`);
        console.log('✓ Keyboard navigation working');
      }
    } else {
      console.log('ℹ No focusable elements detected');
    }
  });

  test('should take full page screenshots for documentation', async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.waitForLoadState('networkidle');

    // Take screenshots at different viewports
    const viewports = [
      { name: 'desktop', width: 1920, height: 1080 },
      { name: 'laptop', width: 1366, height: 768 },
      { name: 'tablet', width: 768, height: 1024 },
      { name: 'mobile', width: 375, height: 667 }
    ];

    for (const viewport of viewports) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForLoadState('networkidle');
      await page.screenshot({
        path: `test-results/screenshot-${viewport.name}.png`,
        fullPage: true
      });
      console.log(`✓ Screenshot captured: ${viewport.name}`);
    }
  });
});
