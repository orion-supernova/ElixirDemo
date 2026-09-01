# Media sources

Every GIF here is cut from one recording:

**`Simulator Screen Recording - iPhone 17 - 2026-09-01 at 14.14.04.mov`**
— 78.225 s, 1206 × 2622, VFR averaging ~69.7 fps, iPhone 17 simulator, app
version 2.4. Not in this repo; it lives on the author's Desktop.

## Cut list

Timestamps are seconds into that recording.

| File | Start | Length | Width | What it shows |
|---|---|---|---|---|
| `hydration.gif` | 2.6 | 8.4 s | 340 | The hydration orb at 0 %, then a Sip, 500 ml and 750 ml logged; it fills to 63 % |
| `history.gif` | 11.8 | 2.2 s | 300 | Water Ritual History — the weekly bar chart and the per-day log |
| `themes.gif` | 17.6 | 5.4 s | 300 | Theme Realm: RPG → Cyberpunk → Clean, whole app repainting |
| `reminders.gif` | 24.9 | 5.4 s | 300 | Reminder Budget (0 of 64), then dashboard mode and the water reminder window |
| `mastery.gif` | 31.8 | 2.2 s | 300 | Scrolling up to the Ritual Master profile, Level 1 *Initiate* |
| `add-ritual.gif` | 36.4 | 7.2 s | 300 | Add Ritual opening; typing "Vitamin D" |
| `units.gif` | 44.0 | 3.9 s | 300 | The dosage unit menu |
| `appearance.gif` | 51.8 | 6.2 s | 300 | Icon grid and colour swatches |
| `schedule.gif` | 58.0 | 5.6 s | 300 | Frequency → Every Other Day, start day, time, Save, success |
| `rituals-list.gif` | 68.3 | 5.6 s | 300 | All Rituals, and a swipe revealing delete |
| `dashboard.gif` | 73.7 | 4.4 s | 300 | The dashboard with the saved ritual, week strip and hydration bar |

`icon.png` is `ElixirDemo/Assets.xcassets/AppIcon.appiconset/applogo.png`
resized to 512 × 512. Note that the file in the asset catalog is JPEG data
under a `.png` name; this copy is a real PNG so nothing has to sniff it.

## What was left out, and why

- **Nothing was cut to hide anything.** A luma sweep at 10 fps over the whole
  recording (`signalstats` YAVG) came back with no sustained dip — no
  permission dialogs, no modals, no dimming overlays anywhere in the 78
  seconds. The variation in the trace, 39.6 to 70.6, tracks theme changes and
  screen transitions.
- **Dead air between the shots.** The recording is one continuous session, so
  the gaps between clips are scrolling, back-navigation and idle screens.
- **The status bar carries a `‹ Couple Zone` return affordance**, because the
  simulator build was launched from another of the author's apps. It is about
  three pixels tall at the width these render, so it stays.

## Regenerating

```bash
ffmpeg -y -i in.mov -ss <start> -t <length> -filter_complex \
  "[0:v]fps=13,scale=<width>:-1:flags=lanczos[c];\
   [c]split[s0][s1];[s0]palettegen=stats_mode=diff[p];\
   [s1][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" out.gif
```

**Use `-ss` after `-i`, not a `trim` filter.** On this file `trim=2.6` lands
about a second late — ffmpeg seeks to a keyframe first and the filter's clock
starts there — which silently shifts every timestamp you derive from it. The
first cut of `hydration.gif` opened at 1 % instead of 0 % for exactly that
reason. `-ss` after `-i` decodes and discards, and is frame-accurate here.

If you re-record: the dialogs and grace periods will not land at these
timestamps again. Re-derive them with a per-second contact sheet
(`fps=1,scale=140:-1,tile=8x5`) rather than reusing this table.
