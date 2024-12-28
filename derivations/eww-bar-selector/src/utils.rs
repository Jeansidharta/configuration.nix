use std::process::Command;

#[derive(Debug)]
pub struct Monitor {
    pub id: String,
    pub name: String,
}

pub fn is_desktop_empty() -> bool {
    String::from_utf8(
        Command::new("bspc")
            .args(["query", "--nodes", "-d", "focused"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap()
    .trim()
    .is_empty()
}

pub fn detect_monitors() -> Vec<Monitor> {
    let ids = String::from_utf8(
        Command::new("bspc")
            .args(["query", "--monitors"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap();

    let names = String::from_utf8(
        Command::new("bspc")
            .args(["query", "--monitors", "--names"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap();

    ids.lines()
        .zip(names.lines())
        .map(|(id, name)| Monitor {
            id: id.to_string(),
            name: name.to_string(),
        })
        .collect()
}

pub fn close_all_bars() {
    Command::new("eww")
        .args(["update", "show_bar=false"])
        .output()
        .unwrap();
}

pub fn use_solid_bar() {
    Command::new("eww")
        .args(["update", "show_background=true", "show_bar=true"])
        .output()
        .unwrap();
}

pub fn use_split_bar() {
    Command::new("eww")
        .args(["update", "show_background=false", "show_bar=true"])
        .output()
        .unwrap();
}

#[derive(Debug)]
pub enum Layout {
    Monocle,
    Tiled,
    Fullscreen,
}

pub fn get_current_desktop_layout() -> Layout {
    let res = String::from_utf8(
        Command::new("bspc")
            .args(["query", "-d", "focused", "-n", "focused", "-T"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap();

    if res.contains("\"state\":\"fullscreen\"") {
        return Layout::Fullscreen;
    }

    let res = String::from_utf8(
        Command::new("bspc")
            .args(["query", "-d", "focused", "-T"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap();

    if res.contains("\"layout\":\"monocle\"") {
        Layout::Monocle
    } else if res.contains("\"layout\":\"tiled\"") {
        Layout::Tiled
    } else {
        panic!("No layout found");
    }
}

pub fn has_gaps() -> bool {
    let res = Command::new("bspc")
        .args(["query", "-d", "focused", "-T"])
        .output()
        .unwrap()
        .stdout;
    let res = String::from_utf8(res).unwrap();

    res.contains("\"windowGap\":30")
}

pub fn select_bar_according_to_gaps() {
    if has_gaps() {
        use_split_bar();
    } else {
        use_solid_bar()
    }
}

pub fn select_bar_according_to_gaps_and_state() {
    if is_desktop_empty() {
        use_split_bar();
        return;
    }
    match get_current_desktop_layout() {
        Layout::Tiled => select_bar_according_to_gaps(),
        Layout::Monocle => use_solid_bar(),
        Layout::Fullscreen => close_all_bars(),
    }
}
