# Paysera Design System

> Category: Fintech & Crypto
> European fintech UI. Action-blue on white, role-driven semantic tokens, flat-by-default elevation, light for customers and dark for ops.

## 1. Visual Theme & Atmosphere

Paysera is a **European payments and banking platform**, and its UI reads exactly like that: trustworthy, dense with real money, and allergic to decoration. The system is built on a two-level token model lifted straight from `lib-paysera-ui` — a base Figma palette (`--blue-600`, `--gray-300`, ...) feeds a semantic layer (`--surface-action-primary-initial`, `--text-neutral-primary-initial`, ...) so a single `[data-theme="dark"]` remap flips the entire product between customer-light and ops-dark without touching a component.

The defining contrast pair is **IBM-Carbon action blue (`#0f62fe`) on pure white (`#ffffff`)** with near-black slate text (`#1f2937`). This is not the playful purple of consumer fintech nor the neon of crypto exchanges — it is the calm, regulated blue of a licensed payment institution. Surfaces are **flat by default**: elevation is earned, not sprinkled. A dashboard tile gets one `--shadow-default`; it never stacks a second shadow tier on top.

There is a sharp distinction between the **Paysera brand blue (`#000099`)** and the **action blue (`#0f62fe`)**. The brand blue is for the logotype and hero moments only — it never becomes a button background or a link color. Mixing the two is the single most common way to make Paysera output look wrong.

**Key Characteristics:**
- Two-level tokens: base palette → semantic roles. Components reference roles, never raw hex.
- Action blue `#0f62fe` for all interactive controls; Paysera blue `#000099` reserved for brand marks.
- Flat by default — one elevation level per surface, no glassmorphism, no neumorphism, no faux-3D.
- Conservative radii: 4px buttons/inputs/badges, 8px form cards, 12px dashboard tiles, full only for chips/pills.
- Role-driven status color: success green, critical red, warning yellow/orange, info blue — never decorative.
- Light theme for customer-facing web; dark theme (`[data-theme="dark"]`) for internal ops and data dashboards.
- Inter for all UI, PT Mono for transaction IDs, IBANs, hashes, and tabular numeric data.

### Use Cases

Paysera is purpose-built for:
- **Customer banking and payments web** — account flows, transfers, currency conversion, onboarding (light theme).
- **Internal operations consoles** — compliance review, transaction monitoring, merchant admin (dark theme).
- **Data dashboards** — KPI strips, volume charts, settlement tables (dark theme).
- **Forms with real consequences** — KYC, IBAN entry, beneficiary management, where a label is never a placeholder.

### Prior Art

The palette is IBM Carbon-derived (the Carbon blue ramp `#4589ff` / `#0f62fe` / `#0043ce` / `#002d9c` is unmistakable) layered over a Tailwind-aligned neutral/slate scale. The role-and-state token naming (`{category}-{role}-{variant}-{state}`) echoes Shopify Polaris and Atlassian's token taxonomy. The flat, bordered, label-on-top form composition is closest to GOV.UK and Stripe Dashboard discipline. Sub-brands (Paysera POS, Paysera Tickets) swap the logo only and inherit every token.

## 2. Color

Paysera color is **role-first**. You never pick "green" — you pick `surface-success-*` because the meaning is "succeeded". The base palette below is the raw primitive layer; application and component code consume the semantic layer only.

### Base Palette (primitives)

| Token | Hex | Ramp role |
|-------|-----|-----------|
| `--paysera-blue` | `#000099` | Brand mark / hero only — never an action |
| `--blue-600` | `#0f62fe` | Action / info primary |
| `--blue-500` | `#4589ff` | Action hover, dark-mode action/info icon |
| `--blue-400` | `#78a9ff` | Dark-mode action / info text (AA on slate-800 card) |
| `--blue-700` | `#0043ce` | Action pressed |
| `--blue-50` | `#eff6ff` | Info / action subtle surface |
| `--green-600` | `#16a34a` | Success primary surface |
| `--green-700` | `#15803d` | Success text |
| `--red-600` | `#dc2626` | Critical primary surface / border |
| `--red-700` | `#b91c1c` | Critical text (AA on red-50 subtle surface) |
| `--red-400` | `#f87171` | Dark-mode critical text (AA on slate-800 card) |
| `--red-50` | `#fef2f2` | Critical subtle surface |
| `--yellow-500` | `#eab308` | Warning primary surface |
| `--yellow-700` | `#a16207` | Warning text |
| `--orange-50` | `#fff7ed` | Warning subtle surface |
| `--gray-800` | `#1f2937` | Body text (light) |
| `--gray-500` | `#6b7280` | Muted text |
| `--gray-300` | `#d1d5db` | Default border (light) |
| `--gray-100` | `#f3f4f6` | Secondary background (light) |
| `--slate-950` | `#020617` | Tertiary action surface (buttons, switch-off, tooltip) |
| `--slate-900` | `#0f172a` | Page background (dark) |
| `--slate-800` | `#1e293b` | Card surface (dark) |
| `--slate-50` | `#f8fafc` | Body text (dark) |
| `--white` | `#ffffff` | Page background (light), card surface (light), inversed text |

### Key Semantic Tokens (light theme)

| Role | Token | Resolves to |
|------|-------|-------------|
| Primary CTA background | `--surface-action-primary-initial` | `#0f62fe` |
| Primary CTA hover | `--surface-action-primary-hover` | `#4589ff` |
| Primary CTA text | `--text-inversed-primary-initial` | `#ffffff` |
| Body text | `--text-neutral-primary-initial` | `#1f2937` |
| Muted text | `--text-neutral-secondary-initial` | `#6b7280` |
| Default border | `--border-neutral-primary-initial` | `#d1d5db` |
| Page background | `--background-neutral-primary-initial` | `#ffffff` |
| Card surface | `--surface-neutral-primary-initial` | `#ffffff` |
| Error text | `--text-critical-primary-initial` | `#b91c1c` |
| Error surface | `--surface-critical-secondary-initial` | `#fef2f2` |
| Success text | `--text-success-primary-initial` | `#15803d` |
| Success surface | `--surface-success-secondary-initial` | `#f0fdf4` |
| Warning text | `--text-warning-primary-initial` | `#a16207` |
| Warning surface | `--surface-warning-secondary-initial` | `#fff7ed` |
| Info text | `--text-info-primary-initial` | `#0f62fe` |
| Info surface | `--surface-info-secondary-initial` | `#eff6ff` |

### Status Color Mapping

| Meaning | Surface token | Text token | Example |
|---------|---------------|------------|---------|
| Success / Positive | `--surface-success-secondary-initial` | `--text-success-primary-initial` | "Paid", "Completed", "+12%" |
| Critical / Negative | `--surface-critical-secondary-initial` | `--text-critical-primary-initial` | "Failed", "Declined", "-8%" |
| Warning / Pending | `--surface-warning-secondary-initial` | `--text-warning-primary-initial` | "Pending", "Review" |
| Info / Neutral | `--surface-info-secondary-initial` | `--text-info-primary-initial` | "Processing", "Draft" |

### Contrast (WCAG AA)

All paired tokens are verified at 4.5:1 minimum against their intended background (ratios computed with the WCAG 2.x sRGB relative-luminance formula). Body `#1f2937` on white is 13.6:1. Action `#0f62fe` on white is 5.0:1. Success text `#15803d` on `#f0fdf4` is 4.79:1. Critical text uses `#b91c1c` (`--red-700`), not `#dc2626`: `#dc2626` on the subtle red surface `#fef2f2` is only 4.41:1 and fails, while `#b91c1c` is 5.91:1 on `#fef2f2` and 6.47:1 on white. Warning text uses `#a16207` (not `#eab308`) precisely because `a16207` clears 4.5:1 on `#fff7ed` (4.64:1) where the brighter yellow would fail. Tertiary text uses `#6b7280` (`--gray-500`, 4.83:1 on white), not `#9ca3af` (`--gray-400`, only 2.54:1) — `gray-400` is reserved for decorative/disabled non-text and borders.

### Dark Mode

Dark mode is a genuine semantic remap, not a copy of the light block. The base palette is unchanged; only the Level-2 tokens flip under `[data-theme="dark"]`. Page background becomes `--slate-900` (`#0f172a`), card surface becomes `--slate-800` (`#1e293b`), body text becomes `--slate-50` (`#f8fafc`).

Crucially, **action/info/critical text shifts lighter than the Paysera source so it clears AA on the dark *card* surface, not just the page background.** This is a fork-level deviation: the upstream `lib-paysera-ui` dark block keeps these roles at `#4589ff`/`#ef4444` (`--blue-500`/`--red-500`), which clear AA on the page background `slate-900` (`#4589ff` 5.33:1, `#ef4444` 4.74:1) but **fail on the slate-800 card surface** (`#4589ff` 4.37:1, `#ef4444` 3.89:1) — and most link/error/badge text in this product lives inside a card. We therefore use `#78a9ff` (`--blue-400`) for action/info text (6.21:1 on slate-800, 7.58:1 on slate-900) and `#f87171` (`--red-400`) for critical text (5.29:1 on slate-800, 6.45:1 on slate-900). Icons stay at `--blue-500`/`--red-500` (the source values) since the large-graphic threshold is 3:1, which they clear. The `*-secondary` text tints likewise flip to the LIGHT end of each ramp (`--red-300`, `--blue-300`, `--green-300`, `--orange-300`) — all 7:1+ on slate-800 — rather than the source's dark `-800` tints, which would be invisible on a dark card. The full override lives in `tokens.css`.

```css
:root {
  --surface-action-primary-initial: #0f62fe;
  --background-neutral-primary-initial: #ffffff;
  --surface-neutral-primary-initial: #ffffff;
  --text-neutral-primary-initial: #1f2937;
  --text-action-primary-initial: #0f62fe;
  --text-info-primary-initial: #0f62fe;
  --text-critical-primary-initial: #b91c1c; /* red-700 — AA on red-50 subtle surface */
  --text-neutral-tertiary-initial: #6b7280; /* gray-500 — AA on white */
  --focus-outline-neutral-primary-initial: #0f62fe;
}

[data-theme="dark"] {
  --background-neutral-primary-initial: #0f172a;
  --surface-neutral-primary-initial: #1e293b;  /* card surface — the AA-binding background */
  --surface-neutral-secondary-initial: #334155;
  --text-neutral-primary-initial: #f8fafc;
  --text-neutral-secondary-initial: #9ca3af;
  --text-action-primary-initial: #78a9ff;      /* blue-400 — AA on slate-800 card */
  --text-info-primary-initial: #78a9ff;
  --icon-action-primary-initial: #4589ff;       /* blue-500 icon — 3:1 large-graphic bar */
  --text-critical-primary-initial: #f87171;    /* red-400 — AA on slate-800 card */
  --border-neutral-primary-initial: #374151;
  --focus-outline-neutral-primary-initial: #4589ff;
}
```

## 3. Typography

Paysera uses **Inter for all UI** — headings, body, labels, buttons — and **PT Mono** for anything that must align as a column or read as an identifier: transaction IDs, IBANs, hashes, tabular numbers. There is no display serif and no second sans; the secondary token is kept identical to primary only to allow future divergence.

### Font Stack

```css
:root {
  --font-sans: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
  --font-mono: "PT Mono", ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
}
```

### Type Scale (pre-composed text styles)

| Role | Style | Size | Weight | Line Height | Use |
|------|-------|------|--------|-------------|-----|
| Display | `display-s` | 36px (2.25rem) | 600 | 1.1 | Hero / KPI numbers on dashboards |
| H1 | `headline-l` | 32px (2rem) | 600 | 1.2 | Page title |
| H2 | `headline-m` | 28px (1.75rem) | 600 | 1.25 | Section header, modal title |
| H3 | `headline-s` | 24px (1.5rem) | 600 | 1.3 | Card title, subsection |
| Title | `title-l` | 22px (1.375rem) | 600 | 2rem | Form group title |
| Title | `title-m` | 16px (1rem) | 600 | 1.5rem | Default title, button label |
| Body | `body-l` | 16px (1rem) | 400 | 1.5rem | Default paragraph text |
| Body | `body-m` | 14px (0.875rem) | 400 | 1.25rem | Secondary text, helper text |
| Caption | `body-s` | 12px (0.75rem) | 400 | 1rem | Legal text, footnotes, metadata |
| Label | `label-m` | 14px (0.875rem) | 500 | 1.25rem | Form label, chip text |
| Label | `label-s` | 12px (0.75rem) | 500 | 1rem | KPI label (uppercase-tracked), input label-on-top |
| Code | `code-m` | 14px (0.875rem) | 400 | 1.25rem | Inline code, transaction hash, IBAN |

Use the pre-composed `headline-*` / `body-*` / `label-*` utility classes rather than assembling size + weight + family by hand. Type scale is identical across breakpoints — Paysera does **not** use `clamp()` fluid typography; instead choose a smaller style at smaller breakpoints (`display-m` desktop → `headline-l` mobile).

**Font labels for catalog extraction:**

```
Display: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif
Body: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif
Mono: "PT Mono", ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace
```

## 4. Spacing

Tailwind-aligned scale on a 4px base (1rem = 16px). Use for padding, margin, and gap.

```css
:root {
  --space-1: 0.25rem;  /* 4px  */  --space-2: 0.5rem;  /* 8px  */
  --space-3: 0.75rem;  /* 12px */  --space-4: 1rem;    /* 16px */
  --space-5: 1.25rem;  /* 20px */  --space-6: 1.5rem;  /* 24px */
  --space-8: 2rem;     /* 32px */  --space-10: 2.5rem; /* 40px */
  --space-12: 3rem;    /* 48px */  --space-16: 4rem;   /* 64px */
}
```

| Usage | Value |
|-------|-------|
| Card padding | `--space-6` (24px); `--space-4` (16px) on small |
| Page padding (desktop) | `--space-8`–`--space-10` (32–40px) |
| Page padding (mobile) | `--space-5` (20px) |
| Form field gap | `--space-6` (24px) |
| Section gap | `--space-8` (32px) |
| Inline gap | `--space-2`–`--space-3` (8–12px) |

### Radius

```css
:root {
  --radius-sm: 0.125rem;     /* 2px  */
  --radius-default: 0.25rem; /* 4px — button, input, badge */
  --radius-md: 0.375rem;     /* 6px  */
  --radius-lg: 0.5rem;       /* 8px — form cards, modals */
  --radius-xl: 0.75rem;      /* 12px — dashboard tiles */
  --radius-full: 9999px;     /* chips, pills, switch track */
}
```

## 5. Layout & Composition

### Grid System

Mobile-first, 12 columns on desktop (24px gutter), 8 on tablet (16px), 4 on mobile (16px). Content max-width caps: 1400px dashboards, 640px centered forms, 720px long-form reading.

```css
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: var(--space-6);
  max-width: 1400px;
  margin-inline: auto;
  padding: var(--space-8);
}

/* KPI strip: 5 columns on lg+, collapses to 2 on small via minmax */
.kpi-strip {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: var(--space-4);
}
```

### Breakpoints

| Name | Min width | Target |
|------|-----------|--------|
| `sm` | 640px | Small tablets, large phones landscape |
| `md` | 768px | Tablets |
| `lg` | 1024px | Laptops, small desktops |
| `xl` | 1280px | Standard desktops |
| `2xl` | 1536px | Large desktops |

**Collapsing patterns:** data tables → card list below `md`; multi-column forms → single column below `md`; side-by-side charts → stacked below `lg`; fixed sidebar nav → bottom tab bar or drawer below `md`; modal → bottom sheet below `sm`.

**Touch targets:** minimum 44×44px below `lg`, minimum 32×32px at `lg` and above.

### Elevation Hierarchy

Flat by default. Pick exactly one level per surface — never stack two shadow tiers on the same card.

| Level | Shadow | Use |
|-------|--------|-----|
| Base | `none` | Page background |
| Raised | `--shadow-default` | Cards, panels, table rows |
| Overlay | `--shadow-md` | Dropdowns, selects, menus |
| Modal | `--shadow-xl` | Dialogs, drawers |
| Transient | `--shadow-lg` | Toasts, tooltips |

This is an intentionally reduced elevation subset (`sm`/`default`/`md`/`lg`/`xl`); the source `shadows.json` also defines `2xl`, `inner`, and dark-theme white-glow variants that this flat-by-default system does not ship.

## 6. Components

All component CSS references semantic tokens — never raw hex — so a single `[data-theme="dark"]` flip recolors everything. Every interactive component carries a `:focus-visible` outline matching the real `@paysera/ui` themes (`outline 2px` + `outline-offset 1px` in `--focus-outline-neutral-primary-initial`).

### Button

Six variants. One `primary` per view; a second strong action becomes `secondary`. Note the counter-intuitive signature: `secondary` is the dark **tertiary** surface (slate-950), not a light grey.

```css
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-1);
  height: 2.5rem;            /* md: 40px; lg: 3rem; sm: 2rem */
  padding-inline: var(--space-3);
  border-radius: var(--radius-default);
  border: 1px solid transparent;
  font-family: var(--font-sans);
  font-size: 0.875rem;       /* label-m */
  font-weight: 500;
  cursor: pointer;
  transition: background var(--transition-fast), border-color var(--transition-fast);
}

.btn:focus-visible {
  outline: 2px solid var(--focus-outline-neutral-primary-initial);
  outline-offset: 1px;
}

.btn-primary {
  background: var(--surface-action-primary-initial);
  color: var(--text-inversed-primary-initial);
}
.btn-primary:hover { background: var(--surface-action-primary-hover); }
.btn-primary:active { background: var(--surface-action-primary-pressed); }

.btn-secondary {
  background: var(--surface-action-tertiary-initial); /* slate-950 — intentional */
  color: var(--text-inversed-primary-initial);
}
.btn-secondary:hover { background: var(--surface-action-tertiary-hover); }

.btn-tertiary {
  background: transparent;
  border-color: var(--border-action-secondary-initial);
  color: var(--text-neutral-primary-initial);
}
.btn-tertiary:hover { background: var(--surface-action-secondary-hover); }

.btn-ghost {
  background: transparent;
  color: var(--text-neutral-primary-initial);
}
.btn-ghost:hover { background: var(--surface-action-secondary-hover); }

.btn-critical {
  background: transparent;
  border-color: var(--border-critical-primary-initial);
  color: var(--text-critical-primary-initial);
}
.btn-critical:hover { background: var(--surface-critical-secondary-hover); }

.btn[disabled] {
  background: var(--surface-neutral-secondary-disabled);
  color: var(--text-neutral-secondary-initial);
  cursor: not-allowed;
}
```

### Input (bordered container, label-on-top)

The canonical Paysera field is a single bordered `<label>` wrapping a top `label-s` over a `body-m` value — never a placeholder-as-label. Focus outline sits on the container via `:focus-within`.

```css
.field {
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 3rem;              /* md; lg: 3.5rem */
  padding-inline: var(--space-3);
  border: 1px solid var(--border-action-secondary-initial);
  border-radius: var(--radius-default);
  background: var(--surface-neutral-primary-initial);
  cursor: text;
}
.field:hover { border-color: var(--border-action-secondary-hover); }
.field:focus-within {
  outline: 2px solid var(--focus-outline-neutral-primary-initial);
  outline-offset: 1px;
}

.field-label {
  font-size: 0.75rem;        /* label-s */
  font-weight: 500;
  line-height: 1;
  color: var(--text-neutral-secondary-initial);
}

.field-input {
  margin-top: 0.125rem;
  border: 0;
  padding: 0;
  width: 100%;
  background: transparent;
  outline: none;
  font-family: var(--font-sans);
  font-size: 0.875rem;       /* body-m */
  color: var(--text-neutral-primary-initial);
}

/* Critical state: 2px red border + red label + helper below */
.field.is-critical { border-width: 2px; border-color: var(--border-critical-primary-initial); }
.field.is-critical .field-label { color: var(--text-critical-primary-initial); }

.field-error {
  margin-top: var(--space-1);
  padding-inline: var(--space-3);
  font-size: 0.75rem;        /* body-s */
  color: var(--text-critical-primary-initial);
}
```

### Card

Default = raised surface with `--shadow-default` and no border. Outlined = flat with a visible border. Never nest a shadowed card inside a shadowed card — inner containers are outlined or flat.

```css
.card {
  background: var(--surface-neutral-primary-initial);
  border-radius: var(--radius-xl);   /* lg (8px) for forms */
  box-shadow: var(--shadow-default);
  padding: var(--space-6);
}
.card-outlined {
  background: var(--surface-neutral-primary-initial);
  border: 1px solid var(--border-neutral-secondary-initial);
  border-radius: var(--radius-xl);
  box-shadow: none;
  padding: var(--space-6);
}
.card-interactive { transition: box-shadow var(--transition-base); cursor: pointer; }
.card-interactive:hover { box-shadow: var(--shadow-lg); }
.card-interactive:focus-visible {
  outline: 2px solid var(--focus-outline-neutral-primary-initial);
  outline-offset: 2px;
}
.card-title { font-size: 1.375rem; font-weight: 600; color: var(--text-neutral-primary-initial); }
```

### Badge

Subtle role surface + role text, `--radius-default` (4px) — a rounded rect, **not** a pill. Use for counts; use StatusTag for status.

```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.125rem 0.625rem;
  border-radius: var(--radius-default);
  font-size: 0.75rem;        /* body-s */
  font-weight: 500;
}
.badge-default { background: var(--surface-neutral-secondary-initial); color: var(--text-neutral-primary-initial); }
.badge-info    { background: var(--surface-info-secondary-initial);    color: var(--text-info-primary-initial); }
.badge-success { background: var(--surface-success-secondary-initial); color: var(--text-success-primary-initial); }
.badge-warning { background: var(--surface-warning-secondary-initial); color: var(--text-warning-primary-initial); }
.badge-critical{ background: var(--surface-critical-secondary-initial);color: var(--text-critical-primary-initial); }
```

### Alert

A 4px left accent (not a full border) over a subtle role surface. Page-level persistent state only — transient confirmations use a Snackbar.

```css
.alert {
  display: flex;
  align-items: flex-start;
  gap: var(--space-2);
  min-width: 280px;
  padding: var(--space-3) var(--space-2);
  border-left: 4px solid var(--border-info-primary-initial);
  border-radius: var(--radius-lg);
  background: var(--surface-info-secondary-initial);
}
.alert-icon  { width: 1.25rem; height: 1.25rem; flex-shrink: 0; color: var(--icon-info-primary-initial); }
.alert-title { font-size: 0.875rem; font-weight: 600; color: var(--text-neutral-primary-initial); }
.alert-body  { font-size: 0.875rem; color: var(--text-neutral-primary-initial); }

.alert-success  { border-left-color: var(--border-success-primary-initial);  background: var(--surface-success-secondary-initial); }
.alert-success .alert-icon { color: var(--icon-success-primary-initial); }
.alert-warning  { border-left-color: var(--border-warning-primary-initial);  background: var(--surface-warning-secondary-initial); }
.alert-warning .alert-icon { color: var(--icon-warning-primary-initial); }
.alert-critical { border-left-color: var(--border-critical-primary-initial); background: var(--surface-critical-secondary-initial); }
.alert-critical .alert-icon { color: var(--icon-critical-primary-initial); }
```

### Chip (filter)

Pill-shaped (`--radius-full`), transparent with a secondary border. Selected gets a 2px action-blue border (color change, not a fill).

```css
.chip {
  display: inline-flex;
  align-items: center;
  gap: var(--space-1);
  height: 2rem;
  padding-inline: var(--space-3);
  border: 1px solid var(--border-action-secondary-initial);
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--text-neutral-primary-initial);
  font-size: 0.875rem;       /* label-m */
  font-weight: 500;
  cursor: pointer;
  transition: background var(--transition-fast), border-color var(--transition-fast);
}
.chip:hover { background: var(--surface-action-secondary-hover); }
.chip:focus-visible {
  outline: 2px solid var(--focus-outline-neutral-primary-initial);
  outline-offset: 1px;
}
.chip.is-selected { border-width: 2px; border-color: var(--border-action-primary-initial); }
```

### Table

Header row sits on the secondary neutral surface with **dark** header text (not muted). Body rows are the primary surface with a hover and a blue-100 selected state.

```css
.table { width: 100%; border-collapse: collapse; border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm); }
.table thead th {
  height: 3rem;
  padding: 0.875rem var(--space-4);
  text-align: left;
  background: var(--surface-neutral-secondary-initial);
  border-bottom: 1px solid var(--border-neutral-primary-initial);
  font-size: 0.875rem;       /* label-m */
  font-weight: 500;
  color: var(--text-neutral-primary-initial);
}
.table tbody td {
  height: 3rem;
  padding: 0.875rem var(--space-4);
  border-bottom: 1px solid var(--border-neutral-primary-initial);
  background: var(--surface-neutral-primary-initial);
  font-size: 0.875rem;       /* body-m */
  color: var(--text-neutral-primary-initial);
}
.table tbody tr:hover td { background: var(--surface-action-secondary-hover); }
.table tbody tr.is-selected td { background: var(--surface-action-secondary-pressed); }
.table .cell-id { font-family: var(--font-mono); }  /* PT Mono for IDs / IBANs */
```

## 7. Motion & Interaction

Motion is restrained and functional. Default easing is the Paysera ease-out `cubic-bezier(0.23, 1, 0.32, 1)`; enter ~200ms, exit ~140ms.

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Hover / state change | 100ms | ease-out |
| Panel / accordion expand | 200ms | ease-out |
| Modal / drawer enter | 200ms | ease-out |
| Modal / drawer exit | 140ms | ease-out |
| Progress / value transition | 300ms | ease-out |

```css
:root {
  --transition-fast: 100ms cubic-bezier(0.23, 1, 0.32, 1);
  --transition-base: 200ms cubic-bezier(0.23, 1, 0.32, 1);
  --transition-slow: 300ms cubic-bezier(0.23, 1, 0.32, 1);
}

@media (prefers-reduced-motion: reduce) {
  .card-interactive { transition: none; }
  .chip, .btn { transition: none; }
  .accordion-collapsible-inner { animation: none; }
}
```

## 8. Voice & Brand

### Iconography

Lucide icons, pinned to a stable pre-1.0 release. Use the Icon component everywhere — never raw SVG. Match icon size to accompanying text (`sm` with `body-m`, `md` with `body-l`, `base` with titles). Pair every status with an icon so meaning survives color-blindness. No decorative icons in dense tables.

### Tone

- **Trustworthy and plain.** Verb-first, sentence-case button labels of 1–3 words ("View invoice", not "Click here").
- **Localization-aware.** Paysera ships in 30+ European languages; reserve horizontal space per locale and prefer rewriting copy over shrinking a component.
- **Status vocabulary is centralized.** Keep one status dictionary across the product; never invent ad-hoc status strings.

### Brand Discipline

The Paysera brand blue `#000099` appears on the logotype and hero moments only. It is never a button background, link color, or surface fill. Sub-brands (Paysera POS, Paysera Tickets) swap the logo only and inherit every color, type, and component token from Paysera Main.

## 9. Anti-patterns

- Do not use raw hex in components — always reference a semantic token (`--surface-action-primary-initial`), so dark mode stays correct.
- Do not mix Paysera brand blue (`#000099`) with action blue (`#0f62fe`) — brand blue is for marks and hero moments only, never controls.
- Do not use glassmorphism, neumorphism, or faux-3D — Paysera is regulated fintech, not web3.
- Do not use gradients as a primary surface color — gradients are allowed only in hero sections and chart fills, subtle and single-hue.
- Do not stack two primary buttons — one becomes `secondary`; one primary action per view.
- Do not use success green (`#16a34a`) decoratively — reserve it strictly for "succeeded" states.
- Do not stack two shadow tiers on one surface — pick a single elevation level per card.
- Do not use border-radius above 12px on cards or above 4px on buttons/inputs/badges — only chips and pills use `--radius-full`.
- Do not use a bare `<input>` — always wrap in the bordered label-on-top `<label>` composition so border, focus outline, and label sit together.
- Do not use placeholder text as a field label — it is an accessibility and i18n failure.
- Do not use Badge for status — use StatusTag, which is semantically clearer and pairs an icon with the meaning.
- Do not invent new component primitives — compose from existing ones and flag the gap.
