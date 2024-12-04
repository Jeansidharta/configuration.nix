use std::{
    io::Read,
    process::{Command, Stdio},
};

fn get_volume() -> String {
    String::from_utf8(
        Command::new("pamixer")
            .args(["--get-volume"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap()
    .trim()
    .to_string()
}

fn is_muted() -> bool {
    String::from_utf8(
        Command::new("pamixer")
            .args(["--get-mute"])
            .output()
            .unwrap()
            .stdout,
    )
    .unwrap()
    .trim()
        == "true"
}

fn print_info() {
    let is_muted = is_muted();
    let volume = get_volume();
    println!(r#"{{"volume": {volume}, "is_muted": {is_muted}}}"#)
}

fn main() {
    print_info();
    let mut pactl = Command::new("pactl")
        .args(["subscribe"])
        .stdout(Stdio::piped())
        .spawn()
        .unwrap()
        .stdout
        .unwrap();

    let mut buf = [0u8; 4096];
    loop {
        let bytes_read = pactl.read(&mut buf).unwrap();
        let buf = &buf[..bytes_read];
        let string = String::from_utf8(buf.to_vec()).unwrap();
        string.lines().for_each(|line| {
            if line.contains("change") && line.contains("sink") {
                print_info();
            }
        })
    }
}
