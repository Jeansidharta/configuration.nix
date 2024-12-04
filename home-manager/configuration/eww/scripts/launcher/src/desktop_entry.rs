struct DesktopEntry {}

impl<'de> serde::Deserialize<'de> for DesktopEntry {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        todo!()
    }
}
