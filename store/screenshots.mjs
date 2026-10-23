// Takes Play Store phone screenshots (1080x1920) of the live web app.
// All Gurbani shown comes live from BaniDB, exactly as in the app.
//
// Usage: node store/screenshots.mjs <site-url> <output-dir>
import { mkdirSync } from 'node:fs';
import { chromium } from 'playwright';

const [url, outDir] = process.argv.slice(2);
mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: 360, height: 640 },
  deviceScaleFactor: 3,
});

const pause = (ms) => page.waitForTimeout(ms);
const shot = async (name) => {
  await pause(2500); // let fonts and transitions settle
  await page.screenshot({ path: `${outDir}/${name}.png` });
  console.log('saved', name);
};
// Controls sit below the fold, so activate them through Flutter's semantics
// tree instead of scrolling: the wallpaper preview stays in the screenshot.
const tap = (role, name) =>
  page.getByRole(role, { name }).first().dispatchEvent('click');

await page.goto(url, { waitUntil: 'networkidle' });
await pause(6000);

// Turn on Flutter's accessibility tree so elements can be found by text.
await page.locator('flt-semantics-placeholder').dispatchEvent('click');
await pause(1000);

await page.getByRole('button', { name: 'Random shabad' }).click();
await page.getByRole('button', { name: /Ang \d+/ }).first().waitFor({ timeout: 30000 });
await shot('01-search');

await page.getByRole('button', { name: /Ang \d+/ }).first().click();
await pause(4000);
await shot('02-editor-amrit-vela');

await tap('button', 'Kesri');
await tap('checkbox', 'Rounded');
await shot('03-editor-kesri');

await tap('button', 'Marble');
await tap('checkbox', 'Classic');
await tap('switch', 'Show English meaning');
await shot('04-editor-marble-meaning');

await tap('button', 'Night');
await tap('checkbox', 'Modern');
await tap('switch', 'Show English meaning');
await tap('button', 'Top');
await shot('05-editor-night-top');

await browser.close();
