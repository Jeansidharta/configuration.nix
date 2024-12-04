use std::fs;

mod desktop_entry;

struct DesktopEntry {}

fn main() {
    let mut args = std::env::args();
    args.next().unwrap(); // program name;
    let search = args.next().unwrap_or(String::new()).to_lowercase(); // program name;
    let should_open = args.next().unwrap_or(String::new()) == "open"; // program name;

    let entries = fs::read_dir("/home/sidharta/desktop-entries").unwrap();
    let names: Vec<String> = entries
        .filter_map(|entry| {
            let entry = entry.ok()?;
            if !entry.file_type().ok()?.is_file() {
                return None;
            }
            let file_name = entry.file_name().to_string_lossy().to_string();
            if std::path::PathBuf::from(file_name.clone())
                .extension()
                .map(|t| t.to_string_lossy())
                == Some(".desktop".into())
            {
                return None;
            }
            Some(file_name)
        })
        .filter(|entry_name| entry_name.to_lowercase().contains(&search))
        .collect();

    if should_open {
        let a = names.get(0).unwrap();
        // toml::asdf;
    } else {
        println!("{}", serde_json::to_string(&names).unwrap());
    }
}
