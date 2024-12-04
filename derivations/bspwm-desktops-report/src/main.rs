use anyhow::Result;
use serde::Serialize;
use std::io::Read;
use std::process::Command;
use std::process::Stdio;

#[derive(Debug)]
enum ReportItem {
    FocusedMonitor(String),
    UnfocusedMonitor(String),
    OccupiedFocusedDesktop(String),
    OccupiedUnfocusedDesktop(String),
    FreeFocusedDesktop(String),
    FreeUnfocusedDesktop(String),
    UrgentFocusedDesktop(String),
    UrgentUnfocusedDesktop(String),
    LayoutOfFocusedDesktop(String),
    StateOfFocusedNode(String),
    ActiveFlagsOfFocuesdNode(String),
}

#[derive(Debug, Serialize)]
struct Desktop {
    name: String,
    is_focused: bool,
    is_urgent: bool,
    is_free: bool,
}

#[derive(Debug, Serialize)]
struct Monitor {
    name: String,
    name_first_letter: char,
    is_focused: bool,
    desktops: Vec<Desktop>,
}

impl Monitor {
    fn new_focused(name: String) -> Monitor {
        Monitor {
            name_first_letter: name.chars().next().unwrap_or('~').to_ascii_uppercase(),
            name,
            is_focused: true,
            desktops: vec![],
        }
    }

    fn new_unfocused(name: String) -> Monitor {
        Monitor {
            is_focused: false,
            ..Monitor::new_focused(name)
        }
    }
}

fn main() -> Result<()> {
    let mut bspc = Command::new("bspc")
        .args(["subscribe", "report"])
        .stdout(Stdio::piped())
        .spawn()?
        .stdout
        .unwrap();

    loop {
        let mut buf = [0u8; 4096];
        let ammount_read = bspc.read(&mut buf)?;
        let line = String::from_utf8(buf[..ammount_read].to_vec())?;
        line.split('W').for_each(|line| {
            let line = line.trim();
            if line.is_empty() {
                return;
            }

            let mut monitors: Vec<Monitor> = vec![];
            line.split(':')
                .map(|section| {
                    let mut chars = section.chars();

                    match chars.next().unwrap() {
                        'M' => ReportItem::FocusedMonitor(chars.collect()),
                        'm' => ReportItem::UnfocusedMonitor(chars.collect()),
                        'O' => ReportItem::OccupiedFocusedDesktop(chars.collect()),
                        'o' => ReportItem::OccupiedUnfocusedDesktop(chars.collect()),
                        'F' => ReportItem::FreeFocusedDesktop(chars.collect()),
                        'f' => ReportItem::FreeUnfocusedDesktop(chars.collect()),
                        'U' => ReportItem::UrgentFocusedDesktop(chars.collect()),
                        'u' => ReportItem::UrgentUnfocusedDesktop(chars.collect()),
                        'L' => ReportItem::LayoutOfFocusedDesktop(chars.collect()),
                        'T' => ReportItem::StateOfFocusedNode(chars.collect()),
                        'G' => ReportItem::ActiveFlagsOfFocuesdNode(chars.collect()),
                        _ => panic!("Unknown format report item"),
                    }
                })
                .map(|report_item| match report_item {
                    ReportItem::FocusedMonitor(name) => monitors.push(Monitor::new_focused(name)),
                    ReportItem::UnfocusedMonitor(name) => {
                        monitors.push(Monitor::new_unfocused(name))
                    }
                    ReportItem::OccupiedFocusedDesktop(name) => {
                        monitors.last_mut().unwrap().desktops.push(Desktop {
                            name,
                            is_focused: true,
                            is_urgent: false,
                            is_free: false,
                        })
                    }
                    ReportItem::OccupiedUnfocusedDesktop(name) => {
                        monitors.last_mut().unwrap().desktops.push(Desktop {
                            name,
                            is_focused: false,
                            is_urgent: false,
                            is_free: false,
                        })
                    }
                    ReportItem::FreeFocusedDesktop(name) => {
                        monitors.last_mut().unwrap().desktops.push(Desktop {
                            name,
                            is_focused: true,
                            is_urgent: false,
                            is_free: true,
                        })
                    }
                    ReportItem::FreeUnfocusedDesktop(name) => {
                        monitors.last_mut().unwrap().desktops.push(Desktop {
                            name,
                            is_focused: false,
                            is_urgent: false,
                            is_free: true,
                        })
                    }
                    ReportItem::UrgentFocusedDesktop(name) => {
                        monitors.last_mut().unwrap().desktops.push(Desktop {
                            name,
                            is_focused: true,
                            is_urgent: true,
                            is_free: false,
                        })
                    }
                    ReportItem::UrgentUnfocusedDesktop(name) => {
                        monitors.last_mut().unwrap().desktops.push(Desktop {
                            name,
                            is_focused: false,
                            is_urgent: true,
                            is_free: false,
                        })
                    }

                    ReportItem::LayoutOfFocusedDesktop(_) => {}
                    ReportItem::StateOfFocusedNode(_) => {}
                    ReportItem::ActiveFlagsOfFocuesdNode(_) => {}
                })
                .count();

            monitors.sort_by(|a, b| b.name.cmp(&a.name));
            println!("{}", serde_json::to_string(&monitors).unwrap());
        });
    }
}
