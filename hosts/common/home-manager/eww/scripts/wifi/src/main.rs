use serde::Serialize;
use std::cmp::Ordering;
use std::collections::HashSet;
use std::env::args;
use std::process::Command;

use local_ip_address::{local_ip, local_ipv6};

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
struct NetworkItem {
    bssid: String,
    ssid: String,
    network_type: String,
    channel: String,
    speed: String,
    bars: String,
    security: String,
    is_selected: bool,
    signal_strength: u8,
    signal_strength_color: String,
}

#[derive(Debug, Serialize, Default)]
struct NetworkInfo {
    ipv4: Option<std::net::IpAddr>,
    ipv6: Option<std::net::IpAddr>,
    items: Vec<NetworkItem>,
    selected: Option<NetworkItem>,
}

impl Ord for NetworkItem {
    fn cmp(&self, other: &Self) -> Ordering {
        other.signal_strength.cmp(&self.signal_strength)
    }
}

impl PartialOrd for NetworkItem {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        other.signal_strength.partial_cmp(&self.signal_strength)
    }
}

fn make_color(signal_strength: u8) -> String {
    let max_transform_val = 0xff as f64;
    let proportional_val: u8 = ((signal_strength as f64) / 100.0 * max_transform_val) as u8;
    let inverse_proportional_val: u8 =
        (((100 - signal_strength) as f64) / 100.0 * max_transform_val) as u8;
    format!("#{inverse_proportional_val:02x}{proportional_val:02x}00")
}

fn list(refresh: bool) {
    let nmcli = String::from_utf8(
        Command::new("nmcli")
            .args([
                "-t",
                "device",
                "wifi",
                "list",
                "--rescan",
                if refresh { "yes" } else { "no" },
            ])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap();

    let mut ssid_map: HashSet<String> = HashSet::new();
    let mut network_info: NetworkInfo = NetworkInfo::default();
    network_info.items = nmcli
        .lines()
        .map(|line| {
            let is_selected = line.starts_with('*');
            let bssid = line[2..24].to_string();
            let line = &line[25..];
            let mut items = line.split(':');
            let ssid = items.next().unwrap().to_string();
            let network_type = items.next().unwrap().to_string();
            let channel = items.next().unwrap().to_string();
            let speed = items.next().unwrap().to_string();
            let signal_strength: u8 = items.next().unwrap().to_string().parse().unwrap();
            let bars = items.next().unwrap().to_string();
            let security = items.next().unwrap_or("").to_string();

            let item = NetworkItem {
                bssid,
                ssid,
                network_type,
                channel,
                speed,
                bars,
                security,
                signal_strength_color: make_color(signal_strength),
                signal_strength,
                is_selected,
            };

            if is_selected {
                _ = network_info.selected.insert(item.clone());
            }
            item
        })
        .filter(|item| {
            if item.ssid.is_empty() {
                return false;
            };
            if ssid_map.contains(&item.ssid) {
                false
            } else {
                ssid_map.insert(item.ssid.clone());
                true
            }
        })
        .collect::<Vec<NetworkItem>>();

    network_info.items.sort();
    network_info.ipv4 = local_ip().ok();
    network_info.ipv6 = local_ipv6().ok();

    println!("{}", serde_json::to_string(&network_info).unwrap());
}

fn connect(ssid: &str, pass: &str) -> bool {
    Command::new("nmcli")
        .args(["device", "wifi", "connect", ssid, "password", pass])
        .output()
        .unwrap()
        .status
        .success()
}

fn main() {
    let mut args = args();
    args.next();
    let command = args.next().unwrap_or(String::from("list"));

    match &command[..] {
        "list" => list(args.next().is_some_and(|v| v == "refresh")),
        "connect" => println!(
            "{}",
            connect(&args.next().unwrap()[..], &args.next().unwrap()[..])
        ),
        _ => panic!("Invalid command"),
    }
}
