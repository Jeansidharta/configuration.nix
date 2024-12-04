use std::{
    io::Read,
    process::{Command, Stdio},
};

fn main() {
    let mut file = Command::new("playerctl")
        .args(["--follow", "metadata", "mpris:artUrl"])
        .stdout(Stdio::piped())
        .spawn()
        .unwrap()
        .stdout
        .unwrap();

    let mut buf = [0u8; 4096];
    loop {
        let bytes_read = file.read(&mut buf).unwrap();
        if bytes_read == 0 {
            continue;
        }
        let buf = &buf[..bytes_read];
        let line = String::from_utf8(buf.to_vec()).unwrap();
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let line = line.strip_prefix("file://").unwrap();
        println!("{line}");
    }
}
