# QzzCity Digital Admin

This is the first admin-dashboard scaffold for the existing GitHub Pages website. It is intentionally kept on the `feature/qzzcity-digital-admin` branch so the current live site remains unchanged.

## Important architecture

GitHub Pages serves static files. It cannot securely protect an admin area or store shared edits by itself. This dashboard uses Supabase Auth + Postgres for secure sign-in and shared content storage.

## Setup

1. Create a **separate Supabase project for QzzCity Digital** (do not reuse QzzCityRestaurant's production database).
2. In Supabase Authentication, disable public sign-ups and create the administrator user yourself.
3. Open the Supabase SQL Editor and run `admin/schema.sql`.
4. Copy the project URL and anon/public key into `admin/config.js`.
5. Do not use a service_role key in browser code.
6. Enable GitHub Pages deployment for the branch only after review/testing.

## Current scope

The dashboard UI includes overview, services, pricing, portfolio, testimonials, enquiries and business settings. It authenticates with Supabase and writes to the database once configured.

**The existing public homepage is not yet connected to these tables.** That is a separate integration step: wire the public page to read the same content records, then test every section before merging this branch into main. Until then, dashboard edits are saved in the database but do not automatically change the public page.

## Access control note

Only create the intended administrator account. The SQL policies allow authenticated users to manage admin content; keep public sign-ups disabled and do not invite untrusted users.
