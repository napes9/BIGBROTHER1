# Big Brother Updates for Tronbyt

Designed for a flashed Gen 1 Tidbyt / Tronbyt 64×32 display.

## What it shows

- Animated Big Brother intro
- Current Head of Household
- Three nominees
- Power of Veto winner
- Animated memory wall in groups of four
- Grey overlay and red X on evicted houseguests

## Add it to Tronbyt Manager

1. Put this folder in a GitHub repository. Keep the `apps/big_brother_updates` folder structure exactly as supplied.
2. In Tronbyt Manager, open **Settings** and paste your repository URL into **Custom App Repo**.
3. Save, refresh the app list, and choose **Big Brother Updates**.
4. Paste the raw GitHub URL for `data.json` into **Updates JSON URL**.
5. Add the app to your Tidbyt rotation.

Example raw URL:

`https://raw.githubusercontent.com/YOUR-NAME/YOUR-REPO/main/data.json`

## Add memory-wall pictures

Make each picture a tiny square WebP or PNG—ideally **14×14 pixels**. Upload the pictures to your GitHub repository, then replace each `photo` value in `data.json` with its raw GitHub URL. A blank photo URL uses a letter tile instead.

## Post an update

Edit only `data.json` on GitHub:

- Change `hoh` when a new HOH wins.
- Put the three people on the block in `nominees`.
- Change `veto` after the veto competition.
- Set `"evicted": true` beside an evicted houseguest.
- Update `week` whenever the week changes.

Tronbyt will download the latest file the next time it renders the app. The computer used to create the app does **not** need to stay on.

## Preview / check locally (optional)

```powershell
pixlet check apps/big_brother_updates/big_brother_updates.star
pixlet serve apps/big_brother_updates/big_brother_updates.star
```

Then open `http://localhost:8080` and leave **Updates JSON URL** blank to see the built-in demo.

