# Don’t High Five audio

## Music

All five user-supplied MP3 files are included unchanged. Playback chooses a random first track, plays every track once in a shuffled bag, then reshuffles without an immediate repeat across the boundary. Two players make a 1.4 second equal-power transition. The streamlined Settings page has separate music and sound-effects sliders, both defaulting to 50%. Music has a further ×0.25 bus gain, giving 12.5% at the default before per-track matching. Sound effects use ordinary linear gain. Zero fully mutes either bus. Preferences save automatically. Pause additionally ducks music by 6 dB and silences movement effects. The older Audio page and master toggle remain regression fixtures, not normal menu navigation.

FFmpeg's [loudness analysis](https://ffmpeg.org/ffmpeg-filters.html#loudnorm) measured the original tracks. Playback gain matches their integrated loudness to approximately −18 LUFS before the music volume control; files were not re-encoded. `assets/audio/music/playlist.json` records measurements and gains.

| Track | Duration | Original integrated LUFS | Playback gain |
| --- | --- | --- | --- |
| Arcade Hantise | 4:59 | −13.73 | −4.27 dB |
| Glitch Protocol | 2:59 | −15.87 | −2.13 dB |
| Hypnotic Groove | 4:20 | −13.74 | −4.26 dB |
| Neon Glitch | 3:18 | −14.28 | −3.72 dB |
| Nocturnal Arcade | 4:59 | −14.42 | −3.58 dB |

## Effects library

57 prebuilt 48 kHz mono WAV assets replace the old runtime sine/noise placeholders. There are four variants each of glove fire, attachment, recall, launch, jump, bounce, landing, stone brake, portal, launch pad, pickup and UI sounds; five carpet footsteps; and four continuous layers for wind, tension, reeling and room air. The UI samples are available for future interface polish; gameplay uses the action categories.

Selected recordings from Kenney's [Impact Sounds](https://kenney.nl/assets/impact-sounds), [Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds) and [Interface Sounds](https://kenney.nl/assets/interface-sounds) form the physical layers. All three packs are CC0; their notices are in `licenses/`. The generator adds filtered air, elastic pitch curves, low impact body and restrained pickup tones. Original selected recordings are included under `art/audio/kenney/` for reproducibility.

One-shot endpoints taper to zero; a weighted correction removes the mean introduced by that taper. Samples peak at −7 dBFS or lower, with quieter footsteps and confirmation sounds. Periodic noise/oscillators create full-length ambient loops. Runtime playback avoids consecutive identical variants and varies pitch slightly. Three voices per category bound overlapping playback. Speed increases wind, stretched arms increase tension tone, and held reeling adds the spool layer.

Separate buses and a master limiter follow [Godot's audio bus workflow](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html). This is a more deliberate prototype mix, not a claim of professional mastering or listening approval. The effects currently play as local-player feedback; remote-player spatial audio and acoustic room/occlusion modelling remain future work. Human audition against the music is still needed to judge fatigue, tonal balance and how prominent the tension layer should be.

## Rebuild and evidence

`python art/build_audio.py` requires NumPy and FFmpeg on PATH. It rebuilds all WAVs and remeasures music. Add `--effects-only` to keep existing music analysis. No downloads or service accounts are needed to rebuild from this package.

`assets/audio/sfx/manifest.json` contains durations, peak/RMS measurements and loop flags. `.local/reports/audio-audit.json` records independent PCM checks and byte-for-byte matches against the supplied MP3 originals. All effects passed 48 kHz, peak headroom and negligible DC checks. Engine tests verify track advancement near the actual end, overlapping crossfade decks, twelve complete no-repeat shuffle cycles, sample variation, loops, pause and master mute.

The user supplied the music for this project. On 2026-09-21 the user confirmed permission to redistribute all five tracks and explicitly authorized their inclusion in this public repository and download. This is project distribution permission, not a blanket third-party reuse license; the CC0 notices apply to Kenney's effects, not these songs.
