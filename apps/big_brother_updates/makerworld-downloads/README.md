# MakerWorld Downloads for Tronbyt

Shows the live total-download count from a public MakerWorld creator profile on a 64×32 Tidbyt/Tronbyt display.

## What you enter

- **MakerWorld username or ID:** enter the public username without `@` (for example, `NAPES9`). A numeric ID also works.
- **Display name:** optional short text shown at the bottom.

Example profile URL:

`https://makerworld.com/en/@YourName`

The app needs only your public username. Never enter your MakerWorld password or Bambu access token.

## Install in Tronbyt

1. Unzip this folder into your Tronbyt apps directory.
2. Restart the Tronbyt server/app service if the app does not appear immediately.
3. Open Tronbyt Manager and add **MakerWorld Downloads**.
4. Enter your MakerWorld username without the `@` sign and save. For your profile, enter `NAPES9`.
5. Tronbyt will rerender it on its normal app refresh schedule, so the displayed count updates automatically.

## Test render

From inside this folder, if Pixlet is installed:

```bash
pixlet render app.star profile_id=NAPES9 display_name=NAPES
```

This should create `app.webp` for previewing.

## Notes

MakerWorld does not currently provide an official creator-statistics API. This app reads MakerWorld's public profile JSON endpoints and checks multiple known field names. If MakerWorld changes those undocumented endpoints, the display will show `CAN'T UPDATE` instead of retaining a misleading count.
