"""Big Brother Updates for Tronbyt / Tidbyt 64x32 displays."""

load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

BG = "#050817"
BLUE = "#147BFF"
CYAN = "#58E7FF"
GOLD = "#FFD23F"
RED = "#FF3159"
WHITE = "#FFFFFF"
MUTED = "#91A4BD"
GREY = "#5C6370"
FONT = "CG-pixel-3x5-mono"

DEMO = {
    "season": "BB",
    "week": "UPDATE",
    "hoh": "ADD HOH",
    "nominees": ["NOMINEE 1", "NOMINEE 2", "NOMINEE 3"],
    "veto": "TBD",
    "houseguests": [
        {"name": "HG 1", "photo": "", "evicted": False},
        {"name": "HG 2", "photo": "", "evicted": False},
        {"name": "HG 3", "photo": "", "evicted": True},
        {"name": "HG 4", "photo": "", "evicted": False},
        {"name": "HG 5", "photo": "", "evicted": False},
        {"name": "HG 6", "photo": "", "evicted": False},
        {"name": "HG 7", "photo": "", "evicted": False},
        {"name": "HG 8", "photo": "", "evicted": False},
    ],
}

def safe_text(value, fallback = "TBD"):
    if value == None or str(value).strip() == "":
        return fallback
    return str(value).upper()

def shorten(value, length):
    value = safe_text(value)
    if len(value) <= length:
        return value
    return value[:length - 1] + "."

def text(value, color = WHITE, font = FONT):
    return render.Text(content = value, font = font, color = color)

def centered(child, width = 64, height = 32):
    return render.Box(
        width = width,
        height = height,
        child = render.Column(
            children = [child],
            main_align = "center",
            cross_align = "center",
        ),
    )

def title_bar(label, color = BLUE):
    return render.Box(
        width = 64,
        height = 8,
        color = color,
        child = centered(text(label, BG), 64, 8),
    )

def status_screen(label, value, color, icon):
    return render.Box(
        width = 64,
        height = 32,
        color = BG,
        child = render.Column(children = [
            title_bar(icon + " " + label, color),
            render.Box(height = 2),
            centered(text(shorten(value, 18), WHITE), 64, 14),
            centered(text("BIG BROTHER", MUTED), 64, 6),
        ]),
    )

def nominees_screen(nominees):
    rows = []
    colors = [RED, GOLD, CYAN]
    for i in range(3):
        name = nominees[i] if i < len(nominees) else "TBD"
        rows.append(render.Row(children = [
            render.Box(width = 4, height = 6, color = colors[i]),
            render.Box(width = 3),
            text(shorten(name, 16), WHITE),
        ]))
    return render.Box(
        width = 64,
        height = 32,
        color = BG,
        child = render.Column(children = [title_bar("NOMINEES", RED)] + rows),
    )

def avatar(houseguest):
    name = safe_text(houseguest.get("name"), "?")
    photo = houseguest.get("photo", "")
    evicted = houseguest.get("evicted", False)
    if photo:
        response = http.get(photo)
        portrait = render.Image(src = response.body())
    else:
        portrait = centered(text(name[0], WHITE), 14, 14)
    layers = [
        render.Box(width = 14, height = 14, color = "#18213A", child = centered(portrait, 14, 14)),
    ]
    if evicted:
        layers.append(render.Box(width = 14, height = 14, color = "#8A8A8ACC"))
        layers.append(centered(text("X", RED), 14, 14))
    return render.Column(children = [
        render.Stack(children = layers),
        centered(text(shorten(name, 5), GREY if evicted else WHITE), 14, 6),
    ])

def memory_page(houseguests, start, page, total):
    people = []
    for i in range(start, min(start + 4, len(houseguests))):
        people.append(avatar(houseguests[i]))
        if i < min(start + 4, len(houseguests)) - 1:
            people.append(render.Box(width = 2))
    for _ in range(7 - len(people)):
        people.append(render.Box(width = 14))
    return render.Box(
        width = 64,
        height = 32,
        color = BG,
        child = render.Column(children = [
            title_bar("MEMORY WALL %d/%d" % (page, total), CYAN),
            render.Box(height = 2),
            render.Row(children = people),
        ]),
    )

def intro_screen(season, week):
    return render.Box(
        width = 64,
        height = 32,
        color = BG,
        child = render.Column(children = [
            centered(text("BIG", CYAN), 64, 8),
            centered(text("BROTHER", GOLD), 64, 9),
            centered(text(shorten(season + "  " + week, 18), WHITE), 64, 8),
            render.Box(width = 64, height = 3, color = BLUE),
        ]),
    )

def load_data(config):
    data_url = config.str("data_url", "").strip()
    if not data_url:
        return DEMO
    response = http.get(data_url)
    if response.status_code != 200:
        fail("Could not load Big Brother data: HTTP %d" % response.status_code)
    return json.decode(response.body())

def main(config):
    data = load_data(config)
    season = safe_text(data.get("season"), "BB")
    week = safe_text(data.get("week"), "UPDATE")
    hoh = data.get("hoh", "TBD")
    nominees = data.get("nominees", [])
    veto = data.get("veto", "TBD")
    houseguests = data.get("houseguests", [])

    frames = [
        intro_screen(season, week),
        status_screen("HEAD OF HOUSEHOLD", hoh, GOLD, "H"),
        nominees_screen(nominees),
        status_screen("POWER OF VETO", veto, CYAN, "V"),
    ]
    pages = (len(houseguests) + 3) // 4
    for page in range(pages):
        frames.append(memory_page(houseguests, page * 4, page + 1, pages))

    return render.Root(
        child = render.Animation(children = frames),
        delay = 2200,
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "data_url",
                name = "Updates JSON URL",
                desc = "Raw HTTPS URL for data.json. Leave blank to preview demo data.",
                icon = "link",
            ),
        ],
    )
