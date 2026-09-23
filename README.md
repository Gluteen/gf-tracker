# Product Tracker

A shared, real-time product tracker. Static site (no build step) backed by Supabase (Postgres + Realtime + Storage), deployed on Vercel.

## 1. Create the Supabase project

1. Go to [supabase.com](https://supabase.com) → New project (free tier is fine).
2. Once it's ready, open **SQL Editor** → New query, paste the contents of `supabase/schema.sql`, and run it. This creates the `products` table, sets up row-level security, and enables realtime.
3. Go to **Storage** → New bucket → name it `images` → toggle **Public bucket** on. This is where uploaded product photos live.
4. Go to **Project Settings → API**. Copy:
   - **Project URL**
   - **anon public** key

## 2. Wire up the frontend

Open `index.html` and replace these two lines near the top of the `<script type="module">` block:

```js
const SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR-ANON-PUBLIC-KEY';
```

The anon key is meant to be public — it's safe to commit and ship in client-side code. Access control comes from the Row Level Security policies in `schema.sql`, not from keeping this key secret.

You can test locally by just opening `index.html` in a browser, or running any static file server (`npx serve .`).

## 3. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/gf-tracker.git
git push -u origin main
```

## 4. Deploy on Vercel

1. Go to [vercel.com](https://vercel.com) → **Add New → Project** → import your GitHub repo.
2. Framework preset: choose **Other** (it's a static site, no build command needed).
3. Leave the build/output settings blank — Vercel will just serve `index.html` as-is.
4. Deploy. You'll get a URL like `gf-tracker.vercel.app`.

Send that link to your friends and family — everyone who opens it sees the same live list, and changes anyone makes show up for everyone else within a second or two (via Supabase Realtime), no page refresh needed.

## Security note (read this before sharing widely)

The default policies in `schema.sql` let **anyone with the anon key** read and write the table — same trust model as a shared Google Doc link. Since the anon key ships in your public JavaScript, that effectively means **anyone who finds your URL** can add, edit, or delete entries, not just people you send it to directly.

For a small trusted group this is usually fine. If you want tighter control later, options include:
- **Supabase Auth** (magic-link email login) + RLS policies scoped to `auth.uid()`, so only signed-in users can write.
- A shared "invite code" column checked on insert/update via a Postgres function.
- Making the table read-only for anon and only writable via a server-side API route (would require moving off a pure static site to something like Next.js on Vercel).

Happy to help set up any of these if you want tighter access control down the track.

## Notes on the free tier

Supabase's free tier includes a Postgres database, 1GB file storage, and realtime — plenty for a personal/family product list. It pauses inactive projects after a week of no traffic (auto-resumes on next visit, with a short delay). Vercel's free (Hobby) tier is more than enough for a static site like this.
