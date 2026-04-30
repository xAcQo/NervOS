# Phase 4: EVA Unit Profiles - Context

**Gathered:** 2026-04-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Three pilot profiles — Shinji (Unit-01), Rei (Unit-00), Asuka (Unit-02) — fully implemented as distinct visual *worlds*, not palette swaps. Identity is applied across Stylix, caelestia shell surfaces (bar/launcher/lock/notifications), Hyprland (animations, gaps, borders, rounding), Kitty, and wallpapers.

NOTE: The roadmap was authored before Phase 2.1, which superseded Waybar/Rofi/mako/hyprlock with the caelestia unified shell. Per-component theming targets in this phase are: Stylix base16 → caelestia + Hyprland + Kitty + wallpaper provisioning.

Out of scope: runtime profile switching daemon (Phase 6), Pilot Selection GUI (Phase 7), MAGI Dashboard (Phase 8), per-profile sounds (Phase 5).

</domain>

<decisions>
## Implementation Decisions

### Profile architecture

- **One module per pilot.** Each pilot is a self-contained module file: `modules/profiles/{nerv,shinji,rei,asuka}.nix`. Each module sets its Stylix palette, Hyprland gaps/borders/animations, Kitty colors, and per-pilot caelestia overrides. Identity is readable in one file per pilot.
- **NixOS specialisations now, kept for Phase 6.** Each pilot is registered as a `specialisation` in the host config. Reachable via boot menu or `nixos-rebuild switch --specialisation rei`. Phase 6's switcher will toggle the active specialisation symlink at runtime instead of rebuilding — this future-proofs the work.
- **Per-pilot caelestia settings live inside `modules/home/caelestia.nix` via conditionals.** Centralised — caelestia.nix reads the active pilot identity (via `config.nervos.activePilot` or specialisation-set value) and emits the matching `programs.caelestia.settings` block (font, wallpaperDir, accent colors, bar density). Acceptable because caelestia is one module; if it grows messy, refactor to a shared parameterised helper later.
- **Naming: pilot name as ID, unit number in metadata.** Files and the `nervos.activePilot` option use pilot names (`"shinji"`, `"rei"`, `"asuka"`, `"nerv"`). Each profile module exposes a `meta = { unit = "01"; pilot = "Shinji"; codename = "..."; };` attrset for downstream consumers (Phase 7 GUI cards, Phase 8 MAGI labels).

### Color & visual identity

- **Roadmap hex as anchor, refine in implementation.** Use the roadmap values as starting points (Shinji #1A0A2E bg / #4AF626 accent, Rei #080C1A / #20F0FF, Asuka #1A0000 / #FF2020), but tune saturation/lightness during implementation for legibility on real screens. Asuka #FF2020 in particular may be harsh for body text and likely needs a small desaturation pass.
- **Generate full base16 palette via matugen.** Feed the per-pilot wallpaper or anchor color into `matugen` (Material You derivation) to produce the 16 base16 slots. Reuses the same tool Phase 6 needs for runtime palette regeneration; consistent palette feel across pilots.
- **All dark for v1, leave room for light variants.** Every pilot ships `polarity = "dark"`. Document in Phase 4 plans that a future light variant per pilot is possible (keep the palette derivation step factored so it can flip), but do not build it now.
- **Accent reaches borders + bar text + selected items.** Accent color shows on Hyprland active window border, caelestia bar item highlights/text, kitty text-selection background, focused UI cursors. Background and body text remain on the base16 base00–base07 ramp. Avoids legibility traps from saturated chrome on Asuka red and Shinji green.

### Motion & spatial personality

- **Wider per-pilot spatial range than the roadmap.** Push contrast harder than the roadmap's literal numbers:
  - NERV Command: 4px gaps, 2px border (Phase 3 baseline)
  - Shinji: 8px gaps, 2px border, slight rounding (organic)
  - Rei: 16px gaps, 1px hairline border (airy/clinical)
  - Asuka: 1px gaps, 3px thicker border (aggressive/dense)
- **Animation curves verbatim from roadmap intent.** Per-pilot Hyprland `animation` definitions:
  - NERV: sharp ease-out, ~150ms
  - Shinji: cubic bezier with overshoot/bounce, ~300ms
  - Rei: slow ease, ~500ms (melancholic)
  - Asuka: snap, ~80ms (aggressive)
- **Window rounding varies by pilot.** NERV/Asuka sharp (`rounding = 0`), Shinji slight (`rounding = 4` — organic), Rei minimal (`rounding = 2` — clinical curve). Reinforces spatial personality.
- **Caelestia bar density tuned per pilot.** Use caelestia's `appearance.padding` (or equivalent) to differentiate: Asuka dense/tight padding, Rei sparse/wide padding with minimal items shown, Shinji medium organic, NERV reference baseline. Specific numeric values to be set during planning after reading caelestia config schema.

### Wallpaper & font per pilot

- **Curated rotating set per pilot.** 3–6 wallpapers per pilot. Caelestia cycles within the active pilot's directory. Resolves to `~/Pictures/wallpapers/{pilot}/` — `paths.wallpaperDir` in caelestia settings flips per active pilot.
- **Sources tracked under `assets/wallpapers/{pilot}/`.** Already-validated pattern from Phase 3 (gitignored `Neon Genesis Evangelion (Pics)/` blocks flake builds; tracked `assets/wallpapers/` works). Each pilot gets its own subdirectory: `assets/wallpapers/{nerv,shinji,rei,asuka}/`. Provisioned to `~/Pictures/wallpapers/{pilot}/` via per-pilot `home.file` blocks.
- **Per-pilot display font.** Each pilot gets its own sans display font reinforcing mood. Mono surface stays on JetBrains Mono Nerd Font Mono (consistent terminal/code feel). Suggested directions (locked during planning):
  - NERV Command: MatissePro-EB (already shipped Phase 3)
  - Shinji: organic humanist sans (e.g., a humanist grotesque)
  - Rei: minimal geometric (e.g., a thin geometric sans)
  - Asuka: condensed aggressive (e.g., a condensed/italic high-contrast sans)
- **Curate from NGE dir only for v1.** Wallpaper sources are pulled (copied) from the existing local `Neon Genesis Evangelion (Pics)/` library into the tracked `assets/wallpapers/{pilot}/` subdirs. AI-generated supplements and custom NERV terminal/LCL ambience renders are deferred — not in Phase 4 scope.

### Claude's Discretion

- Exact gap/border numbers within the "wider range" envelope (e.g., is Rei 14 or 16? Asuka 1 or 2?) — fine-tune during implementation against on-screen testing.
- Specific `bezier` control points for each pilot's animation curves — pick during planning from canonical Hyprland easing examples.
- Numeric saturation/lightness tweaks to the roadmap anchor colors.
- Specific font choices per pilot (within the mood directions above) — research candidate fonts during phase-research step.
- Caelestia bar `appearance.padding` numeric values per pilot.

</decisions>

<specifics>
## Specific Ideas

- **Architecture echo:** Phase 4 should make Phase 6 (runtime switcher) trivial. The fact that pilots are NixOS specialisations with stable filesystem layouts means Phase 6 can flip the active specialisation symlink + run a minimal reload sequence rather than re-deriving palettes at runtime.
- **Rei feels coldly clinical, not cute.** Wider gaps, hairline borders, slow motion, sparse bar — institutional emptiness. Don't soften with warmth.
- **Asuka feels combat-ready.** Tight gaps, thick borders, hard snap animations, dense bar — every pixel saying "ready to fight". Saturation is OK; legibility test is "can you read body text on red base00?".
- **Shinji is the most organic.** Slight rounding, overshoot bounce, medium gaps — the palette should feel like LCL.
- **Don't over-design Phase 4.** The goal is to *prove the architecture scales from one (NERV) to four pilots*. If a decision is between "make Asuka feel more aggressive" vs "validate the pattern works across all four", validate first, then polish.

</specifics>

<deferred>
## Deferred Ideas

- **Light variant per pilot** — palette derivation factored to allow flipping `polarity`, but no light pilot ships in Phase 4. Future polish.
- **AI-generated / custom NERV-terminal-style wallpapers** — Phase 4 ships canonical NGE frames only. AI/custom art is a future curation pass.
- **Per-pilot bar layout differences beyond density** (e.g., Asuka shows different modules than Rei) — defer to Phase 6 when the runtime switcher exists and bar reloads are fast enough to iterate.
- **Profile-specific keybinds** — out of scope; keybinds remain pilot-agnostic in Phase 4. Pilot-specific keybinds are a Phase 6 consideration if needed.
- **A 5th custom-build-your-own pilot slot** — interesting but not in roadmap; backlog.

</deferred>

---

*Phase: 04-eva-unit-profiles*
*Context gathered: 2026-04-30*
