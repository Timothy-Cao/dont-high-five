# Orbital warning and adjustable fog — 2026-09-22

The 2.8-second warning is a pulsing ground disc matching the complete 18 m damage radius. Its outer rim remains visible between pulses. The active 180 m energy cylinder is fully opaque, capped, and animated with red/gold moving streaks. It stays opaque throughout the four-second damaging phase; residual light and filaments fade afterward. Cover rules, damage and the quieter -11 dB orbital audio are unchanged.

Settings now includes a saved **Fog distance** slider, 50–250 m in 5 m steps. Lower values make fog thicker. Default 100 m corresponds to base exponential density 0.0230, about 28% denser than the previous 0.018. Distance means approximate 90% base High Fiver obscuration, not a hard clipping boundary. Existing Watcher visibility, training and temporary vision multipliers still apply. Workshop editing retains its separate thin haze; playtesting uses the chosen setting.

Verification: settings 28/28, orbital 24/24, carry/night 23/23 and combat/power 44/44 assertions passed (119 total). Source audit passed with 158 static references. Engine-rendered 2560×1440 fixtures reviewed for the warning, opaque column and Settings layout. No desktop control or interactive game session was used. Existing certificate-store and teardown warnings remain; headless orbital cleanup also reports a dummy-renderer null-material warning. No script or shader errors occurred in the rendered fixture.

The warning is a flat, depth-tested horizontal plane: it can be interrupted by raised terrain, ramps and cover. Terrain-conforming projection remains a future refinement.

- [Warning footprint](screenshots/orbital-solid-warning.png)
- [Opaque active column](screenshots/orbital-solid-column.png)
- [Fog settings](screenshots/fog-settings.png)
