# Paysera — Lithuanian fintech Design System

> Category: Fintech & Crypto
> Lithuanian fintech banking UI — action-blue (#0f62fe) on white, two-level semantic token system, Inter + PT Mono, trust-first regulated-product voice. Built from the official paysera/cc-design-system source.

Paysera — Lithuanian fintech for payments, money transfers, business accounts, checkout, cards, and lending. Serves ~1M users across Banking (consumer + business), Checkout (merchant payments), and Lending. Surfaces: web dashboard, iOS, Android, in-store kiosks, merchant portal. Design system: Paysera UI (React + Tailwind, ~37 components). Voice is professional, clear, trust-first — a regulated financial product, not a consumer lifestyle app.

## 1. Visual Theme & Atmosphere

Paysera's visual language is clean, institutional, and trust-first. The product UI uses generous white space, minimal decoration, and lets content — account balances, transaction lists, card details — take center stage. The palette is anchored by IBM-lineage action blue (`#0f62fe`, blue-600) for interactive elements, with a distinct brand navy (`#000099`) reserved for the wordmark and hero moments only. Backgrounds are white or very light gray — never warm, never patterned, never photographic.

The feeling is: a European bank that built its own tech. Professional enough for business accounts and merchant checkout; modern enough that consumer users trust it with their daily payments. No playful illustrations, no lifestyle imagery, no startup energy. Solid, clear, functional.

Logo mark: three interlocking arcs in blue, navy (`#000099`), and green (`#33CC66`). The green arc only appears in the logomark — it does not leak into the product palette as a decorative color. It is reserved for success states.

> **Source evidence**: Token values from `tokens/colors.json` and `tokens/tokens.css` in `paysera/cc-design-system`. Design rules from `RULES.md`. Component API from `COMPONENT-NOTES.md`. See `context/github/` for extraction notes.

## Source Context

This design system specification is grounded in the following source files from [`paysera/cc-design-system`](https://github.com/paysera/cc-design-system):

| Source file | What it provides | Local snapshot |
|-------------|-----------------|----------------|
| `RULES.md` | Design do/don't rules, responsive breakpoints, status color mapping | `context/github/paysera-cc-design-system/files/RULES.md` |
| `COMPONENT-NOTES.md` | Per-component design decisions from `*.theme.js` files | `context/github/paysera-cc-design-system/files/COMPONENT-NOTES.md` |
| `SUB-BRANDS.md` | Paysera POS and Tickets sub-brand rules | `context/github/paysera-cc-design-system/files/SUB-BRANDS.md` |
| `STACK.md` | Preview runtime, Tailwind config, 10 mandatory rules | `context/github/paysera-cc-design-system/files/STACK.md` |
| `tokens/colors.json` | Base palette + semantic token schema | `context/github/paysera-cc-design-system/files/tokens-colors.json` |
| `tokens/typography.json` | Font families, weights, type scale | `context/github/paysera-cc-design-system/files/tokens-typography.json` |
| `tokens/spacing.json` | Spacing, radius, breakpoints, grid | `context/github/paysera-cc-design-system/files/tokens-spacing.json` |
| `tokens/tokens.css` | Full two-level CSS variable system | `colors_and_type.css` (integrated) |
| `preview/_shared.css` | Typography classes with letter-spacing | `colors_and_type.css` (integrated) |
| `preview/_shared-config.js` | Per-utility Tailwind color maps | Referenced in DESIGN.md component specs |

Upstream production source: `gitlab.paysera.net/frontend/lib-paysera-ui` → `@paysera/ui/dist/styles/tokens.css` (Figma `Light.tokens.json` + `Dark.tokens.json`).

## Preserved Assets

Brand assets preserved under `assets/` from the brand guide and SVG exports:

| Asset | File | Usage |
|-------|------|-------|
| Wordmark (RGB) | `assets/logo-rgb.svg` | Default logo on light backgrounds |
| Wordmark (black) | `assets/logo-black.svg` | Monochrome contexts |
| Wordmark (white) | `assets/logo-white.svg` | On dark/colored backgrounds |
| Wordmark (inverted) | `assets/logo-rgb-inverted.svg` | Inverted color scheme |
| Logomark (RGB) | `assets/logomark-rgb.svg` | Compact mark, app icons |
| Logomark (black) | `assets/logomark-black.svg` | Monochrome compact mark |
| Logomark (white) | `assets/logomark-white.svg` | Compact mark on dark backgrounds |
| Logomark (inverted) | `assets/logomark-rgb-inverted.svg` | Inverted compact mark |
| Brand colours | `assets/brand-colours.png` | Colour reference swatch |

## 2. Color

### Two-level token system

Paysera uses a two-level CSS variable architecture (from `@paysera/ui/dist/styles/tokens.css`):

- **Level 1 (Base Palette)**: Named colors from Figma (`--blue-600`, `--gray-100`, etc.)
- **Level 2 (Semantic Tokens)**: Design system tokens referencing base palette (`--surface-action-primary-initial`, etc.)

Naming pattern: `{property}-{purpose}-{variant}-{state}`
- Properties: `background`, `border`, `icon`, `surface`, `text`, `focus-outline`
- Purposes: `action`, `critical`, `info`, `inversed`, `neutral`, `success`, `warning`
- Variants: `primary`, `secondary`, `tertiary`
- States: `initial`, `hover`, `pressed`, `disabled`, `visited`

### Base Palette (Level 1)

| Scale | Hex | Notes |
|-------|-----|-------|
| `--blue-50` | `#eff6ff` | Info tint backgrounds |
| `--blue-100` | `#dbeafe` | Selected states, pagination active |
| `--blue-200` | `#d0e2ff` | Focus rings |
| `--blue-500` | `#4589ff` | Hover states |
| `--blue-600` | `#0f62fe` | **Primary action blue** — buttons, links, active states |
| `--blue-700` | `#0043ce` | Pressed states |
| `--blue-800` | `#002d9c` | Gradient start for placeholder images |
| `--gray-50` | `#f9fafb` | Subtle backgrounds |
| `--gray-100` | `#f3f4f6` | Secondary surfaces, table headers |
| `--gray-200` | `#e5e7eb` | Disabled borders |
| `--gray-300` | `#d1d5db` | Default input borders |
| `--gray-400` | `#9ca3af` | Tertiary text, faded icons |
| `--gray-500` | `#6b7280` | Secondary/muted text |
| `--gray-800` | `#1f2937` | **Primary body text** |
| `--green-50` | `#f0fdf4` | Success tint background |
| `--green-500` | `#33cc66` | Brand logomark green |
| `--green-600` | `#16a34a` | Success primary surfaces |
| `--green-700` | `#15803d` | Success primary text/icons |
| `--red-50` | `#fef2f2` | Critical tint background |
| `--red-600` | `#dc2626` | Critical primary — errors, destructive |
| `--slate-50` | `#f8fafc` | Neutral icon background |
| `--slate-600` | `#475569` | Dark theme secondary icons |
| `--slate-800` | `#1e293b` | Dark theme card surfaces |
| `--slate-900` | `#0f172a` | Dark theme page background |
| `--slate-950` | `#020617` | **Secondary button fill, switch OFF, tooltips** |
| `--yellow-500` | `#eab308` | Warning primary surfaces |
| `--yellow-700` | `#a16207` | Warning primary text |
| `--orange-50` | `#fff7ed` | Warning tint background |

Brand-only colors (not in the semantic token system):
- `#000099` — Paysera Blue. Brand mark only — hero moments, logotype. Not for default actions.
- `#33CC66` — Logomark green arc. Maps to success semantic tokens in product UI.

### Semantic Tokens (Level 2 — Light Theme)

#### Surfaces

| Token | Resolves to | Hex | Usage |
|-------|------------|-----|-------|
| `--surface-action-primary-initial` | `--blue-600` | `#0f62fe` | Primary button background |
| `--surface-action-primary-hover` | `--blue-500` | `#4589ff` | Primary button hover |
| `--surface-action-primary-pressed` | `--blue-700` | `#0043ce` | Primary button pressed |
| `--surface-action-tertiary-initial` | `--slate-950` | `#020617` | **Secondary button fill** (dark!) |
| `--surface-action-tertiary-hover` | `--slate-900` | `#0f172a` | Secondary button hover |
| `--surface-action-secondary-hover` | `--blue-50` | `#eff6ff` | Ghost/tertiary button hover |
| `--surface-action-secondary-pressed` | `--blue-100` | `#dbeafe` | Pagination active, selected rows |
| `--surface-neutral-primary-initial` | `--white` | `#ffffff` | Card background, page background |
| `--surface-neutral-primary-hover` | `--blue-100` | `#dbeafe` | MenuItem hover |
| `--surface-neutral-secondary-initial` | `--gray-100` | `#f3f4f6` | Table header, muted fill |
| `--surface-critical-primary-initial` | `--red-600` | `#dc2626` | Critical button fill |
| `--surface-critical-secondary-initial` | `--red-50` | `#fef2f2` | Critical tint |
| `--surface-success-primary-initial` | `--green-600` | `#16a34a` | Success primary |
| `--surface-success-secondary-initial` | `--green-50` | `#f0fdf4` | Success tint |
| `--surface-warning-primary-initial` | `--yellow-500` | `#eab308` | Warning primary |
| `--surface-warning-secondary-initial` | `--orange-50` | `#fff7ed` | Warning tint |
| `--surface-info-primary-initial` | `--blue-600` | `#0f62fe` | Info primary |
| `--surface-info-secondary-initial` | `--blue-50` | `#eff6ff` | Info tint |

#### Backgrounds

| Token | Resolves to | Hex | Usage |
|-------|------------|-----|-------|
| `--background-neutral-primary-initial` | `--white` | `#ffffff` | Page background (light) |
| `--background-neutral-secondary-initial` | `--gray-100` | `#f3f4f6` | Secondary surface |

#### Text

| Token | Resolves to | Hex | Usage |
|-------|------------|-----|-------|
| `--text-neutral-primary-initial` | `--gray-800` | `#1f2937` | Primary body text |
| `--text-neutral-secondary-initial` | `--gray-500` | `#6b7280` | Secondary/muted text |
| `--text-neutral-tertiary-initial` | `--gray-400` | `#9ca3af` | Faded/placeholder text |
| `--text-action-primary-initial` | `--blue-600` | `#0f62fe` | Links, text buttons |
| `--text-action-primary-hover` | `--blue-500` | `#4589ff` | Link hover |
| `--text-action-primary-visited` | `--indigo-600` | `#4f46e5` | Visited links |
| `--text-critical-primary-initial` | `--red-600` | `#dc2626` | Error text |
| `--text-success-primary-initial` | `--green-700` | `#15803d` | Success text |
| `--text-warning-primary-initial` | `--yellow-700` | `#a16207` | Warning text |
| `--text-info-primary-initial` | `--blue-600` | `#0f62fe` | Info text |
| `--text-inversed-primary-initial` | `--white` | `#ffffff` | Text on dark/primary backgrounds |

#### Borders

| Token | Resolves to | Hex | Usage |
|-------|------------|-----|-------|
| `--border-neutral-primary-initial` | `--gray-300` | `#d1d5db` | Input borders, dividers |
| `--border-neutral-secondary-initial` | `--gray-100` | `#f3f4f6` | Light dividers |
| `--border-action-primary-initial` | `--blue-600` | `#0f62fe` | Focus borders, primary outlines |
| `--border-action-secondary-initial` | `--gray-300` | `#d1d5db` | Tertiary button, chip borders |
| `--border-critical-primary-initial` | `--red-600` | `#dc2626` | Error borders |
| `--border-success-primary-initial` | `--green-700` | `#15803d` | Success borders |

#### Icons

| Token | Resolves to | Usage |
|-------|------------|-------|
| `--icon-neutral-primary-initial` | `--slate-950` | Primary icons |
| `--icon-neutral-secondary-initial` | `--gray-500` | Muted icons |
| `--icon-action-primary-initial` | `--blue-600` | Action icons |
| `--icon-critical-primary-initial` | `--red-600` | Error icons |
| `--icon-success-primary-initial` | `--green-700` | Success icons |

#### Focus

| Token | Resolves to | Usage |
|-------|------------|-------|
| `--focus-outline-neutral-primary-initial` | `--blue-600` | Keyboard focus ring |

### Dark Theme Overrides

Dark mode is activated via `[data-theme="dark"]` on `<html>`, NOT via `.dark` class. Key overrides:

| Token | Light | Dark |
|-------|-------|------|
| `--background-neutral-primary-initial` | `--white` | `--slate-900` |
| `--surface-neutral-primary-initial` | `--white` | `--slate-800` |
| `--surface-neutral-secondary-initial` | `--gray-100` | `--slate-700` |
| `--text-neutral-primary-initial` | `--gray-800` | `--slate-50` |
| `--text-neutral-secondary-initial` | `--gray-500` | `--gray-500` |
| `--border-neutral-primary-initial` | `--gray-300` | `--gray-700` |
| `--icon-neutral-primary-initial` | `--slate-950` | `--slate-50` |

Theme selection by context:
- **Customer-facing web**: light (default)
- **Internal ops/admin**: dark
- **Data dashboards**: dark

## 3. Typography

### Font Families

- **Primary (all UI):** `Inter`, `system-ui`, `sans-serif`
- **Code:** `PT Mono`, `ui-monospace`, `monospace`

### Type Scale (from `tokens/typography.json`)

| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `display-l` | 56px (3.5rem) | 600 | 64px | Hero headlines (marketing, splash) |
| `display-m` | 48px (3rem) | 600 | 52px | Hero headlines (medium) |
| `display-s` | 36px (2.25rem) | 600 | 44px | Hero headlines (small) / KPI numbers |
| `headline-l` | 32px (2rem) | 600 | 40px | Page title |
| `headline-m` | 28px (1.75rem) | 600 | 36px | Section header, modal title |
| `headline-s` | 24px (1.5rem) | 600 | 32px | Card title, subsection |
| `title-l` | 22px (1.375rem) | 600 | 28px | Large label, form group title |
| `title-m` | 16px (1rem) | 600 | 24px | Default title, button label |
| `title-s` | 14px (0.875rem) | 600 | 20px | Small title, emphasized table header |
| `body-l` | 16px (1rem) | 400 | 24px | Default paragraph text |
| `body-m` | 14px (0.875rem) | 400 | 20px | Secondary text, descriptions |
| `body-s` | 12px (0.75rem) | 400 | 16px | Legal text, footnotes, metadata |
| `label-l` | 16px (1rem) | 500 | 24px | Form label (emphasized) |
| `label-m` | 14px (0.875rem) | 500 | 20px | Default form label, chip text |
| `label-s` | 12px (0.75rem) | 500 | 16px | KPI label (uppercase-tracked), table header |
| `code-l` | 16px (1rem) | 400 | 24px | Code block |
| `code-m` | 14px (0.875rem) | 400 | 20px | Inline code, transaction hash |
| `code-s` | 12px (0.75rem) | 400 | 16px | Numeric IDs in tables |

Letter spacing: `0em` throughout. No expanded or condensed tracking (except `label-s` which uses `0.02em` for uppercase eyebrows).

### Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Normal | 400 | Body text |
| Medium | 500 | Labels |
| Semibold | 600 | Display, headline, title |
| Bold | 700 | Semantic headings (h2–h6) |
| Extrabold | 800 | h1 only |

### Usage Rules

- Page titles, card titles, nav items, tab labels, button labels: **Title Case**.
- Body copy, descriptions, helper text, error messages: **Sentence case**.
- Metadata eyebrow labels only: **ALL CAPS** `label-s`.
- IBANs and account numbers: `code-l` in PT Mono, grouped in 4-digit blocks.
- Currency amounts: tabular numerics. Number before symbol with thin-space thousands: `1 200.50 €`.
- Use typography classes (`display-l`, `body-m`, etc.), never raw `text-sm`/`font-bold`.

## 4. Spacing

### Spacing Scale (from `tokens/spacing.json`)

| Token | Value | Common usage |
|-------|-------|-------------|
| `0` | 0 | — |
| `0.5` | 2px (0.125rem) | — |
| `1` | 4px (0.25rem) | Chip padding-y |
| `1.5` | 6px (0.375rem) | — |
| `2` | 8px (0.5rem) | Inline gap |
| `2.5` | 10px (0.625rem) | Chip padding-x, button padding-sm |
| `3` | 12px (0.75rem) | Inline gap, button padding-sm |
| `4` | 16px (1rem) | Card padding-sm, button padding-md |
| `5` | 20px (1.25rem) | Page padding (mobile) |
| `6` | 24px (1.5rem) | Card padding, form field gap |
| `8` | 32px (2rem) | Page padding (desktop), section gap |
| `10` | 40px (2.5rem) | Page padding (desktop alt) |
| `12` | 48px (3rem) | — |
| `16` | 64px (4rem) | — |
| `20` | 80px (5rem) | — |

### Border Radius (from `tokens/spacing.json`)

| Token | Value | Usage |
|-------|-------|-------|
| `rounded` | 4px | **Button, Badge, Chip, Input, Modal buttons** (most common) |
| `rounded-md` | 6px | Input, button (source default) |
| `rounded-lg` | 8px | Card, Alert, Modal, Drawer, RadioCard |
| `rounded-xl` | 12px | Dashboard tiles (hero cards) |
| `rounded-full` | 9999px | Avatar, Switch knob, Pill-chip |

Note: `@paysera/ui` does not override Tailwind's default border-radius values.

### Shadows (from `tokens/shadows.json`)

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-sm` | `0 1px 2px 0 rgba(0,0,0,0.05)` | Pressed/subtle container |
| `shadow-default` | `0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1)` | Raised cards, dashboard tiles |
| `shadow-md` | `0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1)` | Dropdown menus, select surfaces |
| `shadow-lg` | `0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -4px rgba(0,0,0,0.1)` | Popovers, tooltips, hover lifts |
| `shadow-xl` | `0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1)` | Modals, drawers |
| `shadow-2xl` | `0 25px 50px -12px rgba(0,0,0,0.25)` | Full-screen overlays, auth cards |
| `shadow-inner` | `inset 0 2px 4px 0 rgba(0,0,0,0.05)` | Inset wells: search focus, code blocks |

Dark theme: use `sm-light` / `base-light` variants with white glow instead of darker drop-shadow.

### Elevation hierarchy

| Level | Shadow | Usage |
|-------|--------|-------|
| 1 (base) | `none` | Page background |
| 2 (raised) | `default` | Cards, panels, table rows |
| 3 (overlay) | `md` | Dropdowns, selects, menus |
| 4 (modal) | `xl` | Full-bleed dialogs, drawers |
| 5 (transient) | `lg` | Toasts (Snackbar), tooltips |

### Density

- Default content density: comfortable (16px vertical rhythm).
- Tables and lists: compact (row sizes sm/md/lg with h-8/h-10/h-12).
- Dashboard cards: 24px internal padding, 16px gap between cards.
- Form fields: 48px height (md/default), 56px (lg), 32px (sm).
- Minimum touch target: 44px for mobile, 32px for desktop.

## 5. Layout & Composition

### Page Structure

Standard authenticated layout:
- **Topbar**: 64px height, white background, solid bottom border (`border-neutral-primary-initial`). Left: app switcher grid icon + Paysera Banking logo. Right: user avatar (32px circle) + name + ID.
- **Sidebar**: 240px width, white background, right border. Nav items: icon + label, 44px height, 16px left padding. Active item: `surface-action-secondary-pressed` background with `text-action-primary-initial` text and left accent.
- **Content area**: Fluid, max-width 1400px (dashboard) or 640px (forms, centered). 32px padding from sidebar edge, 24px top padding below breadcrumbs.
- **Wizard topbar** (for multi-step flows): Close/X icon left, centered flow title, non-interactive user entity right.

### Grid (from `tokens/spacing.json`)

| Target | Columns | Gutter |
|--------|---------|--------|
| Desktop | 12 | 24px |
| Tablet | 8 | 16px |
| Mobile | 4 | 16px |

Dashboard cards: CSS Grid, `minmax(320px, 1fr)`, 16px gap.
Detail views: 2-column (list/master on left, detail on right) at desktop, stacking at tablet.

### Responsive Breakpoints (from `tokens/spacing.json`)

| Name | Min width | Target |
|------|-----------|--------|
| `sm` | 640px | Small tablets, large phones landscape |
| `md` | 768px | Tablets |
| `lg` | 1024px | Laptops, small desktops |
| `xl` | 1280px | Standard desktops |
| `2xl` | 1536px | Large desktops, 4K scaled |

**Mobile-first** — default layout assumes mobile, progressively enhanced.

### Container max-widths

| Context | Max-width |
|---------|-----------|
| Dashboard content | 1400px |
| Form (centered) | 640px |
| Long-form reading | 720px |

### Collapsing patterns (from `RULES.md`)

- Data tables → card list below `md`
- Multi-column forms → single column below `md`
- Side-by-side charts → stacked below `lg`
- Fixed sidebar nav → bottom tab bar or drawer below `md`
- Modal → bottom sheet below `sm`

### Navigation

- Sidebar nav items: Accounts, Cards, Transfers, Checkout, Currency, Settings.
- Breadcrumbs: forbidden on first-level pages (opened from sidebar). Required on second-level and deeper.
- Tabs: used within pages for sub-sections (e.g. Digital / Physical card groups).

## 6. Components

### Buttons (6 variants from `Button.theme.js`)

| Variant | Background | Text | Border | Notes |
|---------|-----------|------|--------|-------|
| Primary | `surface-action-primary-initial` (#0f62fe) | `text-inversed-primary-initial` (white) | None | Main CTA. Hover: `surface-action-primary-hover` |
| Secondary | `surface-action-tertiary-initial` (#020617, slate-950!) | `text-inversed-primary-initial` (white) | None | **Dark filled, NOT blue-outlined** |
| Tertiary | Transparent | `text-neutral-primary-initial` | 1px `border-action-secondary-initial` | Bordered, outlined |
| Ghost | Transparent | `text-neutral-primary-initial` | None | Minimal, hover: `surface-action-secondary-hover` |
| Critical | Transparent | `text-critical-primary-initial` | 1px `border-critical-primary-initial` | **NOT red-filled**. Outline only |
| Text | Transparent | `text-action-primary-initial` | None | Link-style button |

Sizes: `lg` (h-12 px-4) / `md` (h-10 px-3) / `sm` (h-8 px-2).
Border radius: `rounded` (4px). Text: `label-m` (14px medium).
Labels: verbs naming the consequence — "Continue", "Pay 557.00 €". Never "Submit", never "OK".

### Cards (from `@paysera/ui/components/card`)

| Variant | Shadow | Border | Usage |
|---------|--------|--------|-------|
| `default` | `shadow-default` | None | Dashboard tiles |
| `outlined` | None | `border-neutral-secondary-initial` | Forms, nested containers |
| `interactive` | Hover elevation | Visible | Clickable cards |

Radius: `rounded-xl` (12px) for dashboard tiles, `rounded-lg` (8px) for forms.
Padding: `6` (24px) standard, `4` (16px) on small screens.

### Form Inputs (from `Input.theme.js`)

Label-on-top structure (floating-label is the long-term signature but temporarily simplified):
- Container: bordered `<label>` with `border-action-secondary-initial`, `rounded-md`
- Inside: `h-12 px-3 flex flex-col justify-center`
- Top: `<span class="label-s">Label</span>`
- Bottom: `<input class="body-m bg-transparent">`
- Focus: `outline-2 outline-offset-1`, border remains same family
- Error: `border-2 border-critical-primary-initial` + `text-critical-primary-initial` helper
- Disabled: `bg-surface-action-primary-disabled` + `text-neutral-secondary-initial`

### Select / Dropdown (from `Dropdown.theme.js`)

- Same input container dimensions as inputs
- Chevron: `chevron-down` 16px right-aligned
- Dropdown panel: `bg-surface-neutral-primary-initial`, `shadow-md`, `rounded-sm`, `min-w-[300px]`
- Selected item: `bg-surface-action-secondary-pressed` + checkmark on right
- Disabled item: `bg-surface-neutral-secondary-disabled text-neutral-secondary-initial`

### Radio & Checkbox

- Both: `h-4 w-4 border-neutral-primary-initial text-action-primary-initial`
- RadioCard: card with radio on right, selected = `border-action-primary-initial` (1px colour change only, not border-2)

### Switch / Toggle (from `Switch.theme.js`)

- Track: `h-5 w-10 rounded-full`
- **OFF state: `surface-action-tertiary-initial` (slate-950, DARK!)** — NOT light gray
- ON state: `surface-action-primary-initial` (blue)
- Critical variant: `surface-critical-primary-initial` (always red)
- Handle: `h-3.5 w-3.5 bg-surface-neutral-primary-initial` (white circle)

### Tables (from `Table.theme.js`)

- Header row: `bg-surface-neutral-secondary-initial` (gray-100), `label-m text-neutral-primary-initial` (**dark text, not muted**)
- Body row: `bg-surface-neutral-primary-initial`, hover: `bg-surface-action-secondary-hover`
- Selected row: `bg-surface-action-secondary-pressed` (blue-100)
- Cell padding: `px-4 py-3.5` (default lg), `body-m text-neutral-primary-initial`
- Row sizes: sm (h-8 py-1.5) / md (h-10 py-2.5) / lg (h-12 py-3.5, **default**)

### Pagination (from `Pagination.theme.js`)

- Page button: `h-8 min-w-8 px-2 rounded label-m`
- **Active: `bg-surface-action-secondary-pressed text-neutral-primary-initial`** (light blue-100, NOT filled primary!)
- Inactive: `border border-neutral-secondary-initial text-neutral-primary-initial`

### CursorPagination

- Two icon-only tertiary buttons `w-10 h-10 rounded`
- For append-only/time-ordered data. No page numbers.

### Status Indicators (StatusTag from `StatusTag.theme.js`)

- **No pill background**. Coloured icon + dark label text only.
- Icon variant colours via `text-{variant}-primary-initial`
- Label: `text-neutral-primary-initial` (dark, always)

### Alert (from `Alert.theme.js`)

- **4px left accent** border, not full border
- `bg-surface-{variant}-secondary-initial border-{variant}-primary-initial`
- Layout: icon + content + close button
- Variants: info / success / warning / critical

### Snackbar / Toast

- **Alert-style** (NOT fully filled): `bg-surface-neutral-primary-initial + border-l-4 border-{variant}-primary-initial`
- Coloured icon via `text-{variant}-primary-initial`
- Position: bottom-right. Auto-dismiss 4s.

### Tooltip

- `bg-surface-action-tertiary-initial` (**slate-950, NOT medium gray**) + `text-inversed-primary-initial`
- `label-s rounded shadow-sm`

### Modal / Dialog

- Overlay: `bg-black/50`
- Panel: `bg-surface-neutral-primary-initial rounded-lg shadow-xl`
- Header/footer border: `border-neutral-primary-initial` (gray-300, not secondary)
- Primary action right, secondary (cancel) left in footer

### Drawer

- Overlay: `bg-black/40`
- `absolute right-0 top-0 h-full w-full max-w-md`

### Breadcrumbs (from `Breadcrumbs.theme.js`)

- Link: `label-m text-action-primary-initial hover:underline`
- Active (last): `text-neutral-primary-initial pointer-events-none`
- Divider: `chevron-right` in `text-neutral-secondary-initial`
- **Forbidden on first-level pages**. Required on second-level and deeper.

### Sidebar Navigation

- Width: 240px
- Items: 44px height, icon (20px) + label (`label-m`), 16px left padding
- Active: `bg-surface-action-secondary-pressed`, `text-action-primary-initial`, left accent border
- Hover: `bg-surface-neutral-primary-hover`

### Stepper (from `Stepper.theme.js`)

Step icons use Lucide (NOT numbered circles):
- COMPLETED: `check-circle-2` + `text-action-primary-initial`
- CURRENT: `circle-dot` + `text-action-primary-initial`
- INCOMPLETE: `circle` + `text-neutral-primary-initial`

Progress bar below steps (`h-0.5 bg-surface-action-primary-initial`). No connector lines between steps.

### Badge

- `rounded` (4px), **not a pill**
- Subtle: `bg-surface-{variant}-secondary-initial text-{variant}-primary-initial`

### Chip (from `Chip.theme.js`)

- `h-8 px-3 rounded-full bg-transparent border border-action-secondary-initial`
- Selected: `border-2 border-action-primary-initial`

### EmptyState (from `EmptyState.theme.js`)

- Uses real Paysera 120×120 PNGs: `nothing-found.png`, `something-wrong.png`, `restricted-access.png`, `internet-connection.png`
- Description: `body-m text-neutral-primary-initial` (not muted!)

### Avatar

- Circular. Sizes: 32px (topbar), 40px (lists), 64px (profile).
- Without photo: `bg-surface-action-primary-initial`, white initials in `label-m`.

### Iconography

- Lucide icons pinned to `@0.469.0`
- Sizes: xs(12) / sm(14) / md(16) / base(20) / lg(24) / xl(32) / 2xl(40)
- 43 approved icons mapped in `ICON-MAP.md`

## 7. Motion & Interaction

### Transitions

- Duration: 0.15s–0.25s. Never longer than 0.3s for UI transitions.
- Easing: `ease`. Never bounce, spring, or elastic.
- Properties: `background-color`, `border-color`, `color`, `box-shadow`, `opacity`, `transform`.

### Hover States

- Buttons: darken background by one step (primary → `surface-action-primary-hover`)
- Cards (clickable): add `shadow-sm` or `shadow-default`
- Links: underline on hover
- Table rows: `surface-action-secondary-hover`
- Sidebar items: `surface-neutral-primary-hover`

### Focus States

- Keyboard focus: `outline-2 outline-offset-1` using `focus-outline-neutral-primary-initial` (blue-600)
- Use `outline`, not `ring`
- Use `focus-visible` to hide on mouse click only
- Never remove focus outlines

### Loading States

- Skeleton: `surface-neutral-secondary-disabled` with subtle pulse animation (1.5s ease-in-out infinite)
- Spinner: `w-5 h-5`, `text-action-primary-initial` color, `0.8s linear infinite` rotation
- Spinner sizes: small (w-4 h-4) / medium (w-5 h-5) / large (w-6 h-6)
- Button loading: spinner replaces label, button stays same width, disabled

### Reduced Motion

- Respect `prefers-reduced-motion: reduce`. Disable all animations except opacity fade.
- Skeleton pulse: replace with static fill.

## 8. Voice & Brand

### Copy Style

- You-voice. "You" for the user, "we" sparingly.
  - "We'll send tickets to this email"
  - "Please verify your identity to continue"

### Capitalization

- **Title Case** for: headings, button labels, nav items, tab labels, card titles, page titles, form-field labels.
  - Capitalize all main words; lowercase articles/conjunctions/prepositions of 3 letters or fewer.
  - Examples: "Active Loans", "Bank Cards", "Create New Project", "Pay 557.00 €"
- **Sentence case** for: body copy, helper text, descriptions, error messages.
- **ALL CAPS**: only for `label-s` metadata eyebrows. Never for buttons, headings, or nav.

### Labels & Buttons

- Labels are nouns: Email, First Name, Country.
- Required fields use `*`.
- Buttons are verbs naming the consequence: "Continue", "Pay 557.00 €", "Delete Account".
- Never "Submit", never "OK".

### Tone

- Helper text is factual, not aspirational. "Only 3 tickets remaining", not "Hurry, selling fast!"
- Errors are specific and remedial: "Your card was declined. Please check your details and try again."
- No exclamation marks in product UI (rare success toast exception: "Payment sent!").
- No emoji anywhere in product copy.

### Formatting

- **Currency**: number before symbol, thin-space thousands separator, always 2 decimals. `129.00 €`, `1 200.50 €`. Never `€129` or `$1,200`.
- **Dates**: ISO in tables/metadata (`2026-04-22`); human in narrative (`22 Apr 2026`).
- **IBAN**: PT Mono font, grouped in 4-digit blocks: `LT12 3456 7890 1234 5678`.

### Sub-brands

Two named sub-brands — **Paysera POS** and **Paysera Tickets** — swap the logo only. All other tokens inherit from Paysera Main. See `context/github/sub-brands.md`.

## 9. Anti-patterns

### Forbidden Colors

- No generic Tailwind palette (`bg-blue-500`, `text-gray-600`). Only semantic Paysera tokens.
- No hardcoded hex in inline styles, no `bg-[#...]` arbitrary Tailwind values.
- No warm beige / cream / peach / pink / orange-brown backgrounds.
- Don't mix brand navy (`#000099`) with action blue (`#0f62fe`) — brand navy is for marks and hero moments only.
- Don't use success green as decorative — strictly for "succeeded" states.

### Forbidden Typography

- No `text-sm` / `text-xl` / `font-bold` / `font-semibold` for semantic content — use the token scale.
- No `clamp()` fluid typography — choose a smaller style at smaller breakpoints instead.

### Forbidden Patterns

- No glassmorphism, neumorphism, faux-3D.
- No gradients as primary surface colour (only in hero sections and chart fills, subtle, single-hue).
- No `backdrop-blur` on sticky headers. Solid surface background with `border-b`.
- No bounce / spring easing. `0.15–0.25s ease` only.
- No photography or patterns as page/card/hero backgrounds. Solid surface colors only.
- No custom or simplified Paysera logos.
- No illustrations beyond supplied empty-state assets.
- No emoji in product UI copy.
- No breadcrumbs on first-level sidebar pages.
- Don't stack two primary buttons side-by-side.
- Don't stack `shadow-md` on a card inside an already-raised parent.

### Forbidden Component Shapes

- Secondary button is NOT blue-outlined. It is `surface-action-tertiary-initial` (slate-950) filled with white label.
- Critical button is NOT red-filled. It is transparent with red border and red text.
- Switch OFF is NOT light gray. It is `surface-action-tertiary-initial` (slate-950) with white handle.
- Pagination active page is NOT filled blue with white text. It is `surface-action-secondary-pressed` (blue-100) with dark text.
- StatusTag has NO pill background. It is colored icon + dark label only.
- Snackbar is NOT fully filled. It is alert-style: white bg + left border accent + colored icon.
- Tooltip is NOT medium gray. It is `surface-action-tertiary-initial` (slate-950) bg with white label.
- Table header text is NOT muted. It is `text-neutral-primary-initial` (dark).
- EmptyState description is NOT muted. It is `text-neutral-primary-initial`.
- Stepper uses Lucide icons (check-circle-2, circle-dot, circle), NOT numbered circles.

### 10 Mandatory Generation Rules (from `STACK.md`)

1. One `.html` file. No `import`, no relative paths, no multi-file layouts.
2. Tailwind only via CDN. Custom classes in `<style type="text/tailwindcss">`.
3. Semantic Paysera token classes, not hex and not raw Tailwind palette.
4. Typography via display/headline/title/body/label/code classes, not `text-xl`/`font-bold`.
5. Dark mode via `[data-theme="dark"]`, not `.dark` / `dark:`.
6. Lucide for icons. `<i data-lucide="name" class="w-4 h-4"></i>` + `lucide.createIcons()`.
7. Button variants strictly from the API: primary / secondary / tertiary / ghost / critical / text.
8. Currency: `1 250.00 €` — number before symbol, thin space, 2 decimals.
9. No emoji in product UI. Icon = Lucide.
10. Title Case for headings, buttons, nav, tabs, card titles, page titles, form labels.
