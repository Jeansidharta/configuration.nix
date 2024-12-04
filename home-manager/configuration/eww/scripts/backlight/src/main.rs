use std::process::Command;

fn handle_offset(args: &mut std::env::Args) -> u8 {
    let current_backlight: f64 = args.next().unwrap().parse().unwrap();
    let direction = args.next().unwrap();

    let backlight_offset = match &direction[..] {
        "up" => 10f64,
        "down" => -10f64,
        _ => panic!("direction is not up nor down"),
    };

    (current_backlight + backlight_offset)
        .round()
        .clamp(1.0, 100.0) as u8
}

fn handle_set(args: &mut std::env::Args) -> u8 {
    let new_backlight: f64 = args.next().unwrap().parse().unwrap();
    new_backlight.round().clamp(1.0, 100.0) as u8
}

fn main() {
    let mut args = std::env::args();

    args.next(); // skip program name
    let command = args.next().unwrap();
    let new_value = match command.as_str() {
        "set" => handle_set(&mut args),
        "offset" => handle_offset(&mut args),
        _ => panic!(),
    };

    Command::new("xbacklight")
        .args(["-set", &new_value.to_string()])
        .output()
        .unwrap();

    Command::new("eww")
        .args([
            "update",
            &format!("monitor_backlight_value={}", &new_value.to_string()),
        ])
        .output()
        .unwrap();
}
