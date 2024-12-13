use std::process::Command;

#[derive(PartialEq)]
pub enum Bars {
    Solid,
    Split,
}

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

pub fn get_open_bar() -> Option<Bars> {
    let output = String::from_utf8(
        Command::new("eww")
            .args(["active-windows", "--no-daemonize"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap();

    if output.contains("top_bar_solid") {
        Some(Bars::Solid)
    } else if output.contains("top_bar_split") {
        Some(Bars::Split)
    } else {
        None
    }
}

pub fn close_all_bars() {
    Command::new("eww")
        .args(["close", "top_bar_split", "--no-daemonize"])
        .output()
        .unwrap();
    Command::new("eww")
        .args(["close", "top_bar_solid", "--no-daemonize"])
        .output()
        .unwrap();
}

pub fn use_solid_bar() {
    if get_open_bar() == Some(Bars::Solid) {
        return;
    }
    Command::new("eww")
        .args(["close", "top_bar_split", "--no-daemonize"])
        .output()
        .unwrap();
    Command::new("eww")
        .args(["open", "top_bar_solid", "--no-daemonize"])
        .output()
        .unwrap();
}

pub fn use_split_bar() {
    if get_open_bar() == Some(Bars::Split) {
        return;
    }
    Command::new("eww")
        .args(["close", "top_bar_solid", "--no-daemonize"])
        .output()
        .unwrap();
    Command::new("eww")
        .args(["open", "top_bar_split", "--no-daemonize"])
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
