from datetime import datetime
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.fast_data_types import Screen


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:

    # Left side: Current directory or command
    screen.cursor.fg = as_rgb(int("a6e3a1", 16))
    screen.cursor.bg = as_rgb(int("1e1e2e", 16))

    # Get the foreground process (command) or use title
    title = tab.active_fg or tab.title or "shell"
    screen.draw(f" {title} ")

    # Middle: Nix icon
    screen.cursor.fg = as_rgb(int("89dceb", 16))
    screen.draw(" ❄ ")

    # Right: Current time
    screen.cursor.fg = as_rgb(int("cdd6f4", 16))
    current_time = datetime.now().strftime("%H:%M")
    screen.draw(f"{current_time} ")

    return screen.cursor.x
