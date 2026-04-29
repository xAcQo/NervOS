---
phase: 03-typography-nerv-command-profile
plan: 02
type: summary
date: 2026-04-30
status: complete
---

# Plan 03-02: NGE Wallpaper + Caelestia Font Wiring

## Outcome

Phase 3 visual identity completed on NervOS VM. Caelestia bar and launcher now render `MatissePro-EB` as the sans display font and `JetBrainsMono Nerd Font Mono` as the mono surface font. NGE wallpapers are provisioned into `~/Pictures/wallpapers/` and Stylix's source wallpaper is a real 1920x1080 NGE image.

## Files Modified

- `assets/wallpaper.jpg` — replaced 420KB placeholder with real 1920x1080 NGE image (`4-21012F64SA53.jpg`, 1.6MB)
- `assets/wallpapers/4-21012F64SA53.jpg` — added (tracked, sourced from `Neon Genesis Evangelion (Pics)/`)
- `assets/wallpapers/nge-numbers-interfaces.jpg` — added (renamed from upstream `numbers-interfaces-anime-neon-genesis-evangelion-wallpaper-preview.jpg`)
- `modules/home/caelestia.nix` — added `appearance.font.family.{sans,mono}` and `home.file` wallpaper provisioning
- `hosts/nervos/default.nix` — renamed user `pilot` → `styx` (matches VM reality), added NOPASSWD sudo for `nixos-rebuild`
- `modules/home/default.nix` — `home.username/homeDirectory` → `styx`
- `flake.nix` — `home-manager.users.pilot` → `home-manager.users.styx`

## Decisions

- **Wallpapers must live under tracked git paths.** First attempt referenced the gitignored `Neon Genesis Evangelion (Pics)/` directory directly; flake builds use `nix flake` source which only sees tracked files, so it failed with `Path '...' does not exist in Git repository`. Fix: copy required wallpapers into `assets/wallpapers/` (already tracked).
- **Nix path-with-spaces idiom.** First attempt used `../../"Neon Genesis Evangelion (Pics)"/"file.jpg"` which throws `path has a trailing slash`. Even after switching to `path + string` form, the gitignore issue blocked the build. Final form is plain path literals against `assets/wallpapers/` — no spaces, no string concat needed.
- **NOPASSWD scoped to nixos-rebuild only.** Did not blanket disable wheel password (`security.sudo.wheelNeedsPassword = false`); used `security.sudo.extraRules` to allow only the two `nixos-rebuild` paths (`/run/current-system/sw/bin/` and `/nix/var/nix/profiles/system/bin/`) without password. Enables remote SSH rebuilds without TTY.
- **Username `styx` adopted.** VM-local WIP commit (Apr 16) had renamed `pilot` → `styx`; keeping `styx` consistent across the flake is simpler than reverting the VM. Pilot-name flavor returns later via Phase 6 specialisations.
- **Font family `material` left at default.** Overriding the material icon font breaks Material Symbols Rounded glyph rendering in caelestia.

## Verification Results

Run on VM at 2026-04-30 after `sudo nixos-rebuild switch --flake .#nervos`:

- `fc-list | grep -i matisse` → `MatissePro-EB.otf: MatissePro\-EB:style=Regular` ✓
- `fc-list | grep -i jetbrains` → JetBrainsMono Nerd Font Mono present ✓
- `ls ~/Pictures/wallpapers/` → `4-21012F64SA53.jpg`, `nge-numbers-interfaces.jpg` ✓
- `cat ~/.config/caelestia/shell.json` → `"sans":"MatissePro-EB","mono":"JetBrainsMono Nerd Font Mono"` ✓
- `sudo -n /run/current-system/sw/bin/nixos-rebuild --help` → succeeds without password ✓
- Rebuild output: `Done. The new configuration is /nix/store/xch6v4krpnj1d3xr20i1p6yp6klcvlwj-nixos-system-nervos-26.05.20260414.4bd9165` ✓

Human visual checkpoint pending — bar/launcher font and wallpaper visible on the running session require eyeball confirmation in VMware.

## Pitfalls Captured

- Nix flakes only see git-tracked files. Anything referenced from a `.nix` module must be either inside the git tree or fetched via a flake input. Gitignored asset directories are invisible to flake builds.
- `path + string` is required when path components contain spaces, but you still cannot reference paths inside a gitignored subtree.
- `sudo -n true` does NOT validate a `NOPASSWD` rule scoped to a specific command. Always test the exact command path the rule allows.
- `security.sudo.extraRules` interleaves with the default wheel rule; later-matching rules win, so a NOPASSWD rule for a specific command path overrides the wheel-needs-password default for that command only.

## Carry-Forward to Phase 4+

- Wallpaper rotation policy (caelestia cycle order, fade timing) not yet configured — defaults in use.
- Caelestia color theming still untouched (Phase 6 — matugen + per-pilot specialisations).
- The 80KB preview JPEG is low-resolution (728x410). Replace with a proper 1920x1080 sibling when curating the final pilot wallpaper set in Phase 6.
- Remote rebuild flow now works: `ssh -i ~/.ssh/nervos_vm styx@192.168.236.128 'cd ~/NervOS && git pull --rebase origin main && sudo -n nixos-rebuild switch --flake .#nervos'`.
