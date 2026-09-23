# RS Nexus — Global Trade CRM & Business Intelligence

Prototype for RS Holding Company. Single-file static app (`index.html`) — no build step, no backend required to run. All data shown is **DEMO / SAMPLE** data stored in the browser's `localStorage`.

## Run locally
Just open `index.html` in a browser, or serve it:
```bash
npx serve .
```

## Deploy — GitHub
```bash
cd rs-nexus
git init
git add .
git commit -m "Initial commit — RS Nexus prototype"
git branch -M main
git remote add origin https://github.com/<your-username>/rs-nexus.git
git push -u origin main
```

## Deploy — Vercel
**Option A — Vercel dashboard (recommended)**
1. Go to https://vercel.com/new
2. Import the GitHub repo you just pushed
3. Framework preset: **Other** (or "Static") — no build command, no output directory needed
4. Click **Deploy**

**Option B — Vercel CLI**
```bash
npm i -g vercel
cd rs-nexus
vercel
vercel --prod
```

`vercel.json` is already set up for a static site with security headers — no configuration needed on Vercel's side.

## Make data real and shared between users (Supabase)

By default the app stores data in each visitor's own browser (`localStorage`) — nobody shares data with anyone else. To turn on a **real, shared, multi-user backend**:

1. Create a free project at https://supabase.com
2. Open the **SQL Editor** and run `rsnexus-shared-state.sql` (included here) — it creates one table that holds the shared dataset, with security rules and real-time sync turned on.
3. Go to **Project Settings → API** and copy the **Project URL** and the **anon public** key.
4. Open `index.html`, search for `const CLOUD = { url: '', anonKey: '' };` (near the very end of the file) and paste your values in:
   ```js
   const CLOUD = { url: 'https://xxxxx.supabase.co', anonKey: 'eyJ...' };
   ```
5. Go to **Authentication → Providers** and make sure **Email** is enabled. Commit and push — Vercel redeploys automatically.
6. Open the live site: the sign-in screen now asks for a real email + password instead of the demo role picker. Use **Create account** to make the first account (yourself), then invite teammates the same way, or add them directly under **Authentication → Users** in Supabase.

What you get once this is on:
- **Shared data** — every signed-in teammate sees and edits the same leads, opportunities, quotations, etc., live (changes made by one person appear for others within a second or two, no refresh needed).
- **Real accounts** — email + password sign-in via Supabase Auth, replacing the demo role picker.
- Roles/branches keep working: a signed-in email is matched to a person in the app's Team list by email. A new teammate who isn't in that list yet is added automatically with a default "Sales" role — change their role from **Team** inside the app afterwards.

**Trade-off to know:** this first step moves the *whole* CRM dataset as one shared document — simple and reliable for a small team, but it means permission checks (who can see/edit what) are enforced by the app in the browser, not by the database itself. `rsnexus-schema.sql` has the fully normalized, per-table schema for a later upgrade to per-record queries with role/branch-aware database security — worth doing before this is used with sensitive real customer data at scale.

## Notes
- This is a working prototype (HTML/CSS/vanilla JS), not the final Next.js build described in the original spec — but it's one self-contained file, so it deploys anywhere with zero build step, including as a real shared app once Supabase is wired in above.
- `rs-nexus-schema.sql` (delivered separately, not needed for the shared-data setup above) has the normalized PostgreSQL/Supabase schema this data model maps to for a fuller backend migration later.
- Without Supabase configured: demo login, pick any role on the sign-in screen. Role permissions and branch scoping are enforced client-side for the demo, and data lives only in your own browser.
