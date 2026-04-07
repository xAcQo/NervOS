# Pitfalls Research

**Domain:** NixOS custom distro with Hyprland + Stylix theming (NervOS)
**Researched:** 2026-04-06
**Confidence:** MEDIUM (training data only -- WebSearch/WebFetch unavailable; no live verification performed)

> **Confidence disclaimer:** All findings below are based on training data knowledge of NixOS, Hyprland, Stylix, GTK4, and related ecosystems through early 2025. WebSearch and WebFetch were unavailable during this research session. Findings are consistent with well-known community patterns but should be spot-checked against current documentation before implementation begins. Items marked LOW require validation against current upstream state.

---

## Critical Pitfalls

### Pitfall 1: Infinite Recursion in NixOS Flake Module Composition

**What goes wrong:**
NixOS module system evaluates lazily, but circular references between module options cause infinite recursion errors that produce opaque stack traces. This is the single most common cause of "my flake doesn't build" in custom NixOS configurations. The error message (`infinite recursion encountered`) gives zero indication of which option or file caused it.

**Why it happens:**
- Module A defines an option whose default value reads from module B, which reads from module A
- Using `config.something` in a module's `options` block instead of the `config` block
- Stylix and Hyprland NixOS modules both set overlapping options (e.g., both try to set GTK theme, cursor theme, or font settings), creating circular config dependencies
- Importing a module that re-imports the parent module (transitive circular imports)

**How to avoid:**
- Never reference `config.*` inside an `options` block -- only in `config` blocks
- Use `lib.mkDefault` and `lib.mkForce` to establish clear priority when Stylix and Hyprland modules set the same option. Stylix should win for theming options; Hyprland should win for compositor options
- Structure modules as: `flake.nix` -> `hosts/` -> `modules/` with clear one-directional import flow. No module should import its parent
- Test each new module addition in isolation with `nix eval` before integrating
- Keep a mental model: options flow DOWN (parent to child), never UP

**Warning signs:**
- `nix build` hangs or produces `infinite recursion encountered` with no useful location
- Adding a new module option causes seemingly unrelated breakage
- Config evaluation time grows noticeably with each new module

**Phase to address:** Phase 1 (Flake Foundation) -- get module structure right from day one. Fixing this later requires refactoring everything.

**Confidence:** HIGH -- this is the most documented NixOS pitfall; consistent across all community sources.

---

### Pitfall 2: Stylix Does Not Theme Everything You Think It Does

**What goes wrong:**
Developers assume Stylix provides complete end-to-end theming for all desktop components. It does not. Significant gaps exist, and discovering them late means building manual theming for critical components after the architecture assumes Stylix handles everything.

**Why it happens:**
Stylix generates base16 color schemes and applies them to supported targets (terminals, Waybar, GTK, Qt, some editors). But it has known gaps:
- **Rofi**: Stylix support exists but may produce layouts that look broken with certain color schemes -- custom `.rasi` templates are often needed
- **Login/display manager**: SDDM/GDM theming is partially supported but often requires manual override
- **Boot splash**: Plymouth theming is NOT managed by Stylix
- **Lock screen**: `swaylock`/`hyprlock` integration varies; Stylix may set colors but not layout/images
- **Notification daemon**: `mako`/`dunst` support exists but customization depth is limited
- **Application-specific CSS**: Electron apps, Firefox, and Chromium-based browsers ignore Stylix entirely
- **GTK4/libadwaita apps**: These use their own color scheme system (`AdwStyleManager`) and may partially or fully ignore GTK3-era theming that Stylix applies

**How to avoid:**
- Audit every visible component early: list ALL things a user sees (boot splash, login screen, lock screen, desktop, Waybar, notifications, app windows, terminal, rofi, file manager) and verify Stylix coverage for each
- Build a "theming gap" document in Phase 2 listing what Stylix covers vs. what needs manual templates
- For gaps, create Nix modules that generate config files from the same base16 palette Stylix uses -- keep one source of truth
- For GTK4/libadwaita: use `dconf` settings to set the color scheme preference (prefer-dark), and accept that libadwaita apps will use their own accent colors unless you patch their CSS

**Warning signs:**
- A component looks "default" after switching themes
- Color mismatches between Waybar and notification popups
- Lock screen ignores the active theme

**Phase to address:** Phase 2 (Theming Layer) -- but audit the gap list in Phase 1 during architecture planning.

**Confidence:** MEDIUM -- Stylix gaps are well-discussed in the community, but exact coverage may have improved since training data cutoff.

---

### Pitfall 3: Hyprland Version Pinning vs. NixOS Channel Lag

**What goes wrong:**
Hyprland develops rapidly with breaking changes between minor versions. nixpkgs-stable often ships a version 2-4 months behind upstream. Using the Hyprland flake input for latest versions while using nixpkgs-stable for everything else creates ABI mismatches, especially with `wlroots` and mesa versions.

**Why it happens:**
- Hyprland pins to a specific `wlroots` revision. If nixpkgs ships a different `wlroots`, plugins and dependent tools break
- Hyprland's NixOS module in their flake may expect options that don't exist in the nixpkgs version of the NixOS module
- GPU driver versions in nixpkgs-stable may be too old for features Hyprland's latest version expects

**How to avoid:**
- **Use the official Hyprland flake** as a flake input, NOT the nixpkgs version. This is the officially recommended approach from the Hyprland team
- Pin the Hyprland flake input to a specific commit/tag -- don't follow `main` in production
- Use `hyprland.nixosModules.default` from their flake, not the nixpkgs NixOS module
- When updating, update Hyprland and nixpkgs together, then test the ISO build before tagging a release
- Set up a CI job (GitHub Actions) that builds the full system closure on each flake lock update

**Warning signs:**
- `wlroots` version mismatch errors at build time
- Hyprland starts but crashes on launch with `signal 11` or `wl_display` errors
- Hyprland plugins fail to load after a `nix flake update`

**Phase to address:** Phase 1 (Flake Foundation) -- pin versions from the start; never use unpinned `main`.

**Confidence:** HIGH -- this is explicitly documented in Hyprland's NixOS wiki page.

---

### Pitfall 4: Real-Time Theme Switching Requires More Than Config File Swaps

**What goes wrong:**
Developers assume that swapping Stylix config and running `nixos-rebuild switch` (or `home-manager switch`) will instantly update all running applications. In reality, many components cache their theme state and require explicit reload signals or full restarts.

**Why it happens:**
- **GTK apps**: Read theme on startup. Running GTK3 apps will NOT pick up a new GTK theme until restarted. GTK4/libadwaita apps check `org.gnome.desktop.interface` dconf settings and MAY react to changes via `GSettings` signals, but this is inconsistent
- **Waybar**: Must receive `SIGUSR2` or be restarted to reload config/CSS
- **Hyprland**: Config can be reloaded with `hyprctl reload`, but some settings (monitor layout, GPU-related) require a full compositor restart
- **Terminal emulators**: Most (kitty, alacritty, foot) watch their config files and hot-reload. But color scheme changes via Stylix rewrite the config file, and the file watcher timing can be racy
- **Rofi**: Stateless -- reads config on each launch. No issue here
- **Wallpaper**: `hyprpaper`/`swaybg` must be signaled or restarted
- **Cursor theme**: Requires re-setting the `XCURSOR_THEME` env var AND restarting the compositor session for all apps to pick it up. This is a Wayland-wide issue

**How to avoid:**
- Design the Vibe Switcher to perform an ordered reload sequence, not just a config swap:
  1. Write new config files (Stylix palette, Hyprland config, Waybar CSS, etc.)
  2. Update `dconf`/`gsettings` for GTK theme, icon theme, cursor theme, color-scheme preference
  3. Send `hyprctl reload` to Hyprland
  4. Send `SIGUSR2` to Waybar (or `killall -SIGUSR2 waybar`)
  5. Restart `hyprpaper`/wallpaper daemon with new image
  6. For running GTK3 apps: accept they won't update, OR use `xdg-portal` settings to trigger partial updates
  7. Restart notification daemon with new config
- Accept that cursor theme changes require logout/login -- document this limitation
- For the "instant" feel, focus on what CAN hot-reload: Waybar, Hyprland borders/gaps/animations, terminal colors, wallpaper. These cover 80% of what the user sees

**Warning signs:**
- Theme switch leaves some components in old colors
- Cursor remains old theme after switch
- GTK file dialogs show old theme in otherwise-updated desktop

**Phase to address:** Phase 3 (Vibe Switcher) -- this is the core technical challenge of the switching system.

**Confidence:** HIGH -- these are well-known Wayland/GTK behavioral constraints.

---

### Pitfall 5: NixOS ISO Build Missing Firmware and Hardware Support

**What goes wrong:**
The built ISO boots on the developer's machine but fails on real hardware -- black screen, no WiFi, no GPU acceleration, or kernel panic. Custom NixOS ISOs notoriously ship without firmware blobs that mainstream distros include by default.

**Why it happens:**
- NixOS's default ISO profile does not include `hardware.enableAllFirmware` or non-free firmware
- WiFi chipsets (Intel, Broadcom, Realtek) need firmware blobs from `linux-firmware`
- NVIDIA GPUs need proprietary drivers which are not included by default and have a complex NixOS configuration
- The ISO installation environment and the installed system have different module sets -- testing one doesn't validate the other
- Secure Boot is not supported by default NixOS ISOs (no `lanzaboote` in the installer)

**How to avoid:**
- In the ISO config, explicitly set:
  ```nix
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true; # if allowing non-free
  nixpkgs.config.allowUnfree = true;
  ```
- Include BOTH `nvidia` and `amdgpu`/`radeon` driver support in the ISO (not just one)
- Include `broadcom-sta`, `rtl8821ce`, and common WiFi firmware packages
- Test the ISO on at least 3 different machines or VM configurations (QEMU with different virtual hardware, VirtualBox, real hardware)
- Include a fallback kernel parameter option in GRUB/systemd-boot: `nomodeset` for GPU issues
- Build the ISO in CI and test boot in QEMU as a smoke test on every commit

**Warning signs:**
- ISO boots to black screen (GPU driver issue)
- No network interfaces detected (missing firmware)
- `lspci` shows devices with no driver bound
- Installer works in VM but fails on real hardware

**Phase to address:** Phase 4 (ISO Builder) -- but plan the firmware inclusion list in Phase 1.

**Confidence:** HIGH -- this is the most common complaint about custom NixOS ISOs.

---

### Pitfall 6: GTK4 App Packaging on NixOS Is Painful

**What goes wrong:**
The GTK4 Vibe Switcher application builds locally but fails at runtime with missing schemas, missing icons, broken CSS loading, or GLib type registration errors when packaged as a Nix derivation.

**Why it happens:**
- GTK4 apps need runtime access to: GSettings schemas, icon themes, font configs, CSS provider files, and GLib introspection typelibs
- Nix's isolated build environment doesn't set `XDG_DATA_DIRS`, `GI_TYPELIB_PATH`, `GSETTINGS_SCHEMA_DIR`, or `GTK_PATH` correctly unless explicitly wrapped
- `wrapGAppsHook4` (for GTK4) must be used instead of `wrapGAppsHook` (GTK3) -- using the wrong one causes subtle failures
- If the app uses `libadwaita`, it needs to be in `buildInputs` AND the wrapper must set up the right paths
- CSS files and asset files (images, sounds) must be installed to the correct `share/` paths and referenced via `GResource` bundles or absolute Nix store paths, NOT relative paths

**How to avoid:**
- Use `wrapGAppsHook4` in `nativeBuildInputs` for the derivation
- Bundle all CSS, icons, and assets into a GResource XML compiled with `glib-compile-resources`
- Use `meson` as the build system (it's the standard for GTK4 projects and handles schema compilation, resource bundling, and desktop file installation)
- Test the packaged derivation with `nix build` early and often -- don't develop solely with `cargo run` or `python ./app.py` and package later
- For Rust+GTK4 (`gtk4-rs`): use `buildRustPackage` with `wrapGAppsHook4` -- there are working examples in nixpkgs to reference

**Warning signs:**
- App runs with `cargo run` but not after `nix build`
- `GLib-GIO-ERROR: No GSettings schemas are installed` at runtime
- Missing icons or CSS styles in the packaged version
- Segfault on launch due to missing typelib

**Phase to address:** Phase 3 (Vibe Switcher) -- but prototype the Nix derivation in Phase 1 to validate the packaging pipeline early.

**Confidence:** MEDIUM -- GTK4 Nix packaging is well-known to be tricky, but specifics of `wrapGAppsHook4` behavior may have improved.

---

### Pitfall 7: NVIDIA GPU Support on Hyprland Is a Minefield

**What goes wrong:**
Hyprland works well on AMD and Intel GPUs. On NVIDIA, users encounter: screen tearing, flickering, crashes, no VRR, broken screen sharing, and window artifacts. This is not a NervOS problem to solve but a reality to plan for.

**Why it happens:**
- NVIDIA's proprietary driver has incomplete Wayland support
- `wlroots`-based compositors (Hyprland) depend on DMA-BUF and explicit sync protocols that NVIDIA only partially implements
- Environment variables must be set correctly: `LIBVA_DRIVER_NAME=nvidia`, `GBM_BACKEND=nvidia-drm`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`, `WLR_NO_HARDWARE_CURSORS=1`
- Kernel modesetting must be enabled: `nvidia-drm.modeset=1` and `nvidia-drm.fbdev=1`
- Hyprland added explicit sync support (around v0.40+) which significantly improved NVIDIA, but it requires driver version 555+ and specific kernel patches

**How to avoid:**
- Create a dedicated NixOS module `nvidia.nix` that:
  - Detects NVIDIA hardware (or is toggled by user)
  - Sets all required environment variables
  - Enables kernel modesetting
  - Configures the correct driver version (555+ minimum)
  - Sets `hardware.nvidia.modesetting.enable = true`
  - Sets `hardware.nvidia.open = true` for newer GPUs (RTX 20 series+) where the open kernel module is better
- Document NVIDIA as "supported with known limitations" -- do NOT promise parity with AMD
- Test the ISO with NVIDIA specifically -- it's a different code path
- Include a "GPU Setup" section in the installer or first-boot wizard

**Warning signs:**
- Black screen after Hyprland starts (no modesetting)
- Cursor invisible or in wrong position (`WLR_NO_HARDWARE_CURSORS` not set)
- Screen tearing during window movement
- `wlr_renderer` errors in Hyprland log

**Phase to address:** Phase 1 (Flake Foundation) for the module, Phase 4 (ISO) for hardware detection.

**Confidence:** HIGH -- NVIDIA Wayland issues are extensively documented by Hyprland and NixOS communities.

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding theme values instead of deriving from base16 palette | Faster initial theme creation | Every new theme requires manual color specification for every component; no consistency guarantee | Never -- always derive from palette |
| Using `nixos-rebuild switch` for theme switching | Simple, works | 10-30 second rebuild time destroys the "instant switch" experience; blocks the system during rebuild | Only during early development; production must use file-swap + signal approach |
| Skipping Home Manager and putting everything in system config | Fewer modules to manage | User-level config (themes, dotfiles) mixed with system config; multi-user support impossible; testing requires root | Never for theming -- Home Manager is the correct layer |
| Using shell scripts instead of a proper GTK4 app for switching | Faster to prototype | No GUI for non-technical users; no state management; no preview capability; violates core product promise | Only as a Phase 1 prototype, must be replaced by Phase 3 |
| Following Hyprland `main` branch | Latest features | Random breakage on flake update; no stability guarantee; users can't file meaningful bug reports | Never in a distro -- always pin to releases |
| Storing theme assets (wallpapers, sounds) in the Nix store only | Pure, reproducible | Large binary assets bloat the Nix store and closure size; slow rebuilds; ISO size balloons | Acceptable for fonts/icons; use a separate data directory for wallpapers/sounds |

## Integration Gotchas

Common mistakes when connecting NervOS subsystems.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Stylix + Hyprland | Letting both set cursor/font and getting conflicts | Stylix owns cursor/font; Hyprland config references Stylix-generated values via `config.stylix.*` |
| Stylix + GTK4 | Assuming Stylix CSS applies to libadwaita | Use `dconf` `color-scheme` setting for dark/light; accept libadwaita accent colors are limited |
| Hyprland + XWayland | Assuming all apps are native Wayland | Many apps (Steam, Electron, some Java) run through XWayland; test theme rendering in both |
| PipeWire + Soundscape | Playing sounds with `aplay`/`paplay` directly | Use PipeWire's `pw-play` or a proper audio library; handle audio device not-ready at login |
| Waybar + Hyprland IPC | Polling Hyprland state on a timer | Use Hyprland's IPC socket for event-driven updates; polling wastes CPU and has latency |
| ISO + Calamares/nixos-install | Assuming `nixos-install` handles everything | Must copy flake config, set up boot loader, handle encrypted partitions, configure user -- each is a separate failure point |

## Performance Traps

Patterns that work in development but fail in production.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Excessive Hyprland animations | Smooth on developer's high-end GPU; stuttery on integrated graphics | Default to conservative animation settings; provide a "performance" toggle; test on Intel UHD 630 or similar low-end GPU | On any iGPU or NVIDIA with compositor overhead |
| Large wallpaper files (8K+) | Slow theme switch, high VRAM usage | Ship wallpapers at 4K max; generate lower-res variants for multi-monitor setups | When user has 2+ monitors or <4GB VRAM |
| Nix evaluation time growth | `nixos-rebuild` takes 30+ seconds just to evaluate | Keep module tree shallow; avoid `builtins.readDir` in hot paths; use `flake.nix` inputs sparingly | When module count exceeds ~50 or flake inputs exceed ~10 |
| Sound system startup race | Ambient soundscape starts before PipeWire is ready; audio glitch or error | Use systemd service dependency (`After=pipewire.service`); retry with backoff | On every cold boot; PipeWire takes 1-3 seconds to initialize |
| GTK4 app startup time | Vibe Switcher takes 2-3 seconds to show window | Preload/cache the app; use a lightweight tray icon that's always running; lazy-load theme previews | On machines with slow disk or many installed themes |
| Full NixOS rebuild on theme switch | 10-30 second delay per switch | Theme switching should NOT trigger `nixos-rebuild`; use runtime config file swaps and reload signals | Always -- this is architecturally wrong for real-time switching |

## UX Pitfalls

Common user experience mistakes in anime-themed distros.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Theming is inconsistent across apps | User sees EVA colors in terminal but default gray in file manager -- breaks immersion completely | Audit every visible app; maintain a "theme coverage matrix" showing which apps are themed and which are not |
| Sound system is annoying | Ambient sounds loop obviously or notification sounds are loud/jarring/weeby to the point of embarrassment | Sound design matters: seamless loops with crossfade, subtle notification tones, easy mute toggle, volume independent of system volume |
| Fonts are unreadable for aesthetics | Cool-looking anime font used for body text is illegible at small sizes | Aesthetic fonts for headers/titles only; use a clean monospace (JetBrains Mono, Fira Code) for terminals and a readable sans-serif (Inter, Noto) for UI text |
| Theme switching loses user state | User has windows arranged, switching themes causes windows to rearrange or apps to restart | Theme switch must preserve window layout; Hyprland's `hyprctl reload` does this if config structure is maintained |
| Installer assumes Linux knowledge | User can't complete installation without terminal commands | Provide a graphical installer (Calamares) or a very guided TUI; automate disk partitioning with sane defaults |
| No way to revert a broken theme | User customizes a theme, breaks it, can't get back | Every theme switch should snapshot the previous state; provide a "reset to default" option |
| Anime aesthetic feels juvenile/superficial | Custom distro looks like a wallpaper pack, not a real OS | Integrate theming DEEPLY: boot splash, login screen, system sounds, fonts, icon themes, Waybar modules all match. Consistency > flash |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Theme completeness:** Often missing lock screen, login screen, or boot splash theming -- verify all 7 visual touchpoints (boot splash, login, desktop, lock screen, notifications, app chrome, terminal)
- [ ] **Font fallback:** Theme fonts look great for English but break for CJK characters (critical for anime-themed OS where users may have Japanese text) -- verify `fontconfig` fallback chain includes Noto CJK
- [ ] **Dark mode propagation:** Desktop is dark-themed but GTK4 apps show light backgrounds -- verify `gsettings set org.gnome.desktop.interface color-scheme prefer-dark` is set
- [ ] **Audio device handling:** Soundscape works with headphones but not speakers (or vice versa) -- verify PipeWire default sink handling
- [ ] **Multi-monitor:** Theme looks good on one monitor but wallpaper stretches/tiles wrong on dual-monitor setup -- verify per-monitor wallpaper handling in `hyprpaper`
- [ ] **HiDPI:** Theme looks perfect at 1080p but is tiny/broken at 4K -- verify Hyprland scaling settings and GTK4 app scaling
- [ ] **ISO size:** ISO builds successfully but is 6GB+ because of included assets -- verify closure size; target <4GB
- [ ] **First boot experience:** OS installs fine but first boot drops to TTY because Hyprland auto-start isn't configured -- verify display manager or autologin + Hyprland autostart
- [ ] **Keyboard layout:** Installer defaults to US keyboard; user with other layout can't type password -- verify keyboard layout selection in installer

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Infinite recursion in modules | MEDIUM | Binary search: comment out half the modules, rebuild, narrow down the circular reference. Use `nix eval --show-trace` for the full evaluation trace |
| Stylix theming gap discovered late | LOW | Write a standalone Nix module that reads the base16 palette and generates the missing config; doesn't require restructuring |
| Hyprland version mismatch after update | LOW | Roll back `flake.lock` to previous known-good state: `git checkout HEAD~1 -- flake.lock && nix flake lock --update-input nixpkgs` |
| GTK4 app packaging failure | MEDIUM | Start from a known-working GTK4 Nix derivation in nixpkgs (e.g., `gnome-text-editor`) and adapt; don't build packaging from scratch |
| ISO missing firmware for user's hardware | LOW | Ship a "hardware support" module the user can toggle; provide a FAQ/troubleshooting page for common hardware issues |
| Theme switch leaves components stale | LOW | Add a "force refresh" button that restarts all themed services; document which components need login/logout to fully update |
| NVIDIA GPU issues | HIGH | This is fundamentally an upstream issue. Provide clear docs, env var auto-detection, and a "safe mode" boot option with `nomodeset` |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Infinite recursion in modules | Phase 1: Flake Foundation | `nix flake check` passes; `nix build` completes in <60 seconds for empty config |
| Stylix theming gaps | Phase 2: Theming Layer | Visual audit of all 7 touchpoints with screenshot comparison |
| Hyprland version pinning | Phase 1: Flake Foundation | Flake input pinned to specific Hyprland release tag; CI builds pass |
| Real-time theme switching race conditions | Phase 3: Vibe Switcher | Switch 10 times rapidly; all components update within 3 seconds; no stale colors |
| ISO firmware gaps | Phase 4: ISO Builder | Boot test on 3 different hardware configs (AMD, Intel, NVIDIA VM) |
| GTK4 packaging | Phase 3: Vibe Switcher | `nix build .#vibe-switcher` produces working binary; test on clean NixOS install |
| NVIDIA support | Phase 1 + Phase 4 | Dedicated NVIDIA test in CI (QEMU with virtual GPU at minimum); documented env vars |
| Sound system race conditions | Phase 2: Theming Layer | Cold boot test: sounds play correctly within 5 seconds of desktop appearing |
| Theme inconsistency across apps | Phase 2: Theming Layer | Theme coverage matrix with pass/fail for each app; >90% coverage |
| Font fallback for CJK | Phase 2: Theming Layer | Render Japanese text in terminal and GTK4 app; no tofu (missing glyph boxes) |
| ISO size bloat | Phase 4: ISO Builder | ISO closure size <4GB; `nix path-info -rsSh` on ISO derivation |
| First boot drops to TTY | Phase 4: ISO Builder | Fresh install from ISO auto-boots to Hyprland desktop without manual intervention |

## Sources

- NixOS module system documentation (nixos.org/manual) -- HIGH confidence for module composition pitfalls
- Hyprland Wiki: Nix page (wiki.hyprland.org/Nix/) -- HIGH confidence for Hyprland-NixOS integration
- Hyprland Wiki: NVIDIA page (wiki.hyprland.org/Nvidia/) -- HIGH confidence for GPU-specific issues
- Stylix GitHub repository (github.com/danth/stylix) -- MEDIUM confidence (could not verify current issue state)
- NixOS Discourse and Reddit r/NixOS community discussions -- MEDIUM confidence for community-reported patterns
- GTK4 documentation (docs.gtk.org) -- HIGH confidence for GTK4 behavior
- Wayland protocol specifications -- HIGH confidence for cursor/theme propagation limitations
- Training data synthesis of NixOS custom distro projects (LainOS, etc.) -- LOW confidence for distro-specific patterns

**Note:** All sources are from training data (knowledge cutoff early 2025). Current Stylix module coverage, Hyprland NixOS module compatibility, and NVIDIA explicit sync status should be re-verified before Phase 1 implementation begins.

---
*Pitfalls research for: NervOS (NixOS + Hyprland + Stylix custom distro)*
*Researched: 2026-04-06*
