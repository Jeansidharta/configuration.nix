use std::{
    io::Read,
    process::{Command, Stdio},
};

use utils::{
    close_all_bars, detect_monitors, select_bar_according_to_gaps,
    select_bar_according_to_gaps_and_state, use_solid_bar,
};

mod utils;

fn main() {
    let mut bspc = Command::new("bspc")
        .args([
            "subscribe",
            "desktop_layout",
            "node_state",
            "desktop_focus",
            "node_add",
            "node_remove",
        ])
        .stdout(Stdio::piped())
        .spawn()
        .unwrap()
        .stdout
        .unwrap();

    select_bar_according_to_gaps_and_state();

    let main_monitor = detect_monitors()
        .into_iter()
        .find(|monitor| monitor.name == "HDMI-1")
        .expect("Could not find main monitor");

    let mut buf = [0u8; 4096];
    loop {
        let bytes_read = bspc.read(&mut buf).unwrap();
        let line = String::from_utf8(buf[..bytes_read].to_vec()).unwrap();
        line.lines().for_each(|line| {
            if line.is_empty() {
                return;
            }
            let mut event_args = line.split_whitespace();
            match event_args.next().unwrap() {
                "node_state" => 'blk: {
                    let monitor_id = event_args.next().unwrap();
                    if monitor_id != main_monitor.id {
                        break 'blk;
                    }
                    let _desktop_id = event_args.next().unwrap();
                    let _node_id = event_args.next().unwrap();
                    let state = event_args.next().unwrap();
                    let on_or_off = event_args.next().unwrap();

                    if state == "fullscreen" {
                        if on_or_off == "on" {
                            close_all_bars();
                        } else {
                            select_bar_according_to_gaps_and_state();
                        }
                    }
                }
                "desktop_layout" => 'blk: {
                    let monitor_id = event_args.next().unwrap();
                    if monitor_id != main_monitor.id {
                        break 'blk;
                    }
                    let _desktop_id = event_args.next().unwrap();
                    let layout = event_args.next().unwrap();
                    match layout {
                        "tiled" => {
                            select_bar_according_to_gaps();
                        }
                        "monocle" => use_solid_bar(),
                        _ => panic!("What kind of layout is this??"),
                    }
                }
                "desktop_focus" => 'blk: {
                    let monitor_id = event_args.next().unwrap();
                    if monitor_id != main_monitor.id {
                        break 'blk;
                    }
                    select_bar_according_to_gaps_and_state();
                }
                "node_add" => 'blk: {
                    let monitor_id = event_args.next().unwrap();
                    if monitor_id != main_monitor.id {
                        break 'blk;
                    }
                    let _desktop_id = event_args.next().unwrap();
                    let _parent_node_id = event_args.next().unwrap();
                    let _new_node_id = event_args.next().unwrap();
                    select_bar_according_to_gaps_and_state();
                }
                "node_remove" => 'blk: {
                    let monitor_id = event_args.next().unwrap();
                    if monitor_id != main_monitor.id {
                        break 'blk;
                    }
                    let _desktop_id = event_args.next().unwrap();
                    let _node_id = event_args.next().unwrap();
                    select_bar_according_to_gaps_and_state();
                }
                _ => (),
            }
        })
    }
}
