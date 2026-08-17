load("http.star", "http")
load("json.star", "json")
load("render.star", "render")

BG = "#071015"
GREEN = "#00d084"
LIGHT_GREEN = "#8fffd0"
WHITE = "#ffffff"
MUTED = "#87a09b"
RED = "#ff5874"
FONT = "CG-pixel-3x5-mono"

def _number(value):
    if type(value) == "int" or type(value) == "float":
        return int(value)
    if type(value) == "string":
        cleaned = value.replace(",", "").replace(" ", "")
        if cleaned.isdigit():
            return int(cleaned)
    return None

def _from_dict(data):
    if type(data) != "dict":
        return None

    # MakerWorld has used several spellings/locations for this public stat.
    for key in ["downloadCount", "downloads", "download_count", "totalDownloads", "totalDownloadCount"]:
        if key in data:
            found = _number(data[key])
            if found != None:
                return found

    for key in ["data", "profile", "user", "statistics", "stats", "counts"]:
        if key in data and type(data[key]) == "dict":
            nested = data[key]
            for stat_key in ["downloadCount", "downloads", "download_count", "totalDownloads", "totalDownloadCount"]:
                if stat_key in nested:
                    found = _number(nested[stat_key])
                    if found != None:
                        return found
    return None

def _fetch_downloads(profile_id):
    urls = [
        "https://api.bambulab.com/v1/design-user-service/user/profile/%s" % profile_id,
        "https://api.bambulab.com/v1/design-user-service/user/%s" % profile_id,
        "https://makerworld.com/api/v1/design-user-service/user/profile/%s" % profile_id,
        "https://makerworld.com/api/v1/design-user-service/user/%s" % profile_id,
    ]
    last_error = "MakerWorld unavailable"
    for url in urls:
        response = http.get(url, headers = {"Accept": "application/json"})
        if response.status_code == 200:
            payload = json.decode(response.body())
            total = _from_dict(payload)
            if total != None:
                return total, ""
            last_error = "Download stat not found"
        else:
            last_error = "MakerWorld error %s" % response.status_code
    return None, last_error

def _download_icon():
    return '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="22"><path d="M7 1h4v10l3-3 3 3-8 8-8-8 3-3 3 3z" fill="#00d084"/><path d="M2 20h14v2H2z" fill="#8fffd0"/></svg>'

def _format_total(value):
    # Commas make large totals much easier to read on the tiny display.
    text = str(value)
    groups = []
    while len(text) > 3:
        groups.insert(0, text[-3:])
        text = text[:-3]
    groups.insert(0, text)
    return ",".join(groups)

def _screen(total, display_name):
    name = display_name if display_name else "MAKERWORLD"
    return render.Box(
        width = 64,
        height = 32,
        color = BG,
        child = render.Row(
            main_align = "center",
            cross_align = "center",
            children = [
                render.Box(
                    width = 20,
                    height = 32,
                    child = render.Image(src = _download_icon(), width = 18, height = 22),
                ),
                render.Column(
                    width = 43,
                    main_align = "center",
                    cross_align = "start",
                    children = [
                        render.Text(content = "DOWNLOADS", font = FONT, color = GREEN),
                        render.Marquee(
                            width = 42,
                            child = render.Text(content = _format_total(total), font = FONT, color = WHITE),
                        ),
                        render.Marquee(
                            width = 42,
                            child = render.Text(content = name.upper(), font = FONT, color = MUTED),
                        ),
                    ],
                ),
            ],
        ),
    )

def _message(title, detail, color):
    return render.Box(
        width = 64,
        height = 32,
        color = BG,
        child = render.Column(
            main_align = "center",
            cross_align = "center",
            children = [
                render.Text(content = title, font = FONT, color = color),
                render.Marquee(
                    width = 60,
                    child = render.Text(content = detail, font = FONT, color = WHITE),
                ),
            ],
        ),
    )

def main(config):
    profile_id = str(config.get("profile_id", "")).strip()
    display_name = str(config.get("display_name", "")).strip()

    if not profile_id:
        return render.Root(
            child = _message("SETUP NEEDED", "ADD MAKERWORLD USERNAME", GREEN),
        )

    total, error = _fetch_downloads(profile_id)
    if total == None:
        return render.Root(
            child = _message("CAN'T UPDATE", error, RED),
        )

    return render.Root(child = _screen(total, display_name))
