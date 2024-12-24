use anyhow::Result;
use xcb::{x::{Atom, EventMask, Window}, Xid};

fn get_window_title(
    conn: &xcb::Connection,
    window: Window,
    known_atoms: &KnownAtoms,
) -> Result<String> {
    let window_title = {
        let reply = conn.wait_for_reply(conn.send_request(&xcb::x::GetProperty {
            delete: false,
            window,
            property: known_atoms.net_wm_name,
            r#type: known_atoms.utf8_string,
            long_offset: 0,
            long_length: std::u32::MAX,
        }))?;
        String::from_utf8(reply.value().to_vec())?
    };
    Ok(window_title)
}

fn handle_active_window_change(
    conn: &xcb::Connection,
    root_window: Window,
    known_atoms: &KnownAtoms,
) -> Result<Option<Window>> {
    let net_active_window = {
        let reply = conn.wait_for_reply(conn.send_request(&xcb::x::GetProperty {
            delete: false,
            window: root_window,
            property: known_atoms.net_active_window,
            r#type: xcb::x::ATOM_WINDOW,
            long_offset: 0,
            long_length: std::u32::MAX,
        }))?;
        reply.value::<xcb::x::Window>().get(0).cloned()
    };
    let net_active_window = match net_active_window {
        Some(w) => if w.resource_id() == 0 { None } else { Some(w) },
        None => None,
    };
    if let Some(window) = net_active_window {
        let title = get_window_title(conn, window, known_atoms)?;
        println!("{title}");
    } else {
        println!("");
    }
    Ok(net_active_window)
}
fn subscribe_to_window_property_events(conn: &xcb::Connection, window: Window) -> Result<()> {
    let mut event_mask = xcb::x::EventMask::empty();
    event_mask.set(xcb::x::EventMask::PROPERTY_CHANGE, true);
    conn.send_and_check_request(&xcb::x::ChangeWindowAttributes {
        window,
        value_list: &[xcb::x::Cw::EventMask(event_mask)],
    })?;
    Ok(())
}

fn unsubscribe_all_events_from_window(conn: &xcb::Connection, window: Window) -> Result<()> {
    conn.send_and_check_request(&xcb::x::ChangeWindowAttributes {
        window,
        value_list: &[xcb::x::Cw::EventMask(EventMask::empty())],
    })?;
    Ok(())
}

struct KnownAtoms {
    net_active_window: Atom,
    net_wm_name: Atom,
    utf8_string: Atom,
}

fn get_atom_by_name(conn: &xcb::Connection, atom_name: &[u8]) -> Result<Atom> {
    Ok(conn
        .wait_for_reply(conn.send_request(&xcb::x::InternAtom {
            only_if_exists: true,
            name: atom_name,
        }))?
        .atom())
}

impl KnownAtoms {
    fn get_atoms(conn: &xcb::Connection) -> Result<KnownAtoms> {
        let net_active_window = get_atom_by_name(conn, b"_NET_ACTIVE_WINDOW")?;
        let net_wm_name = get_atom_by_name(conn, b"_NET_WM_NAME")?;
        let utf8_string = get_atom_by_name(conn, b"UTF8_STRING")?;

        Ok(KnownAtoms {
            net_active_window,
            net_wm_name,
            utf8_string,
        })
    }
}

fn main() -> Result<()> {
    // Initialize connection with X server
    let (conn, root_window) = {
        let (conn, screen_num) = xcb::Connection::connect(None)?;
        let setup = conn.get_setup();
        let zero_screen = setup.roots().nth(screen_num as usize).unwrap();
        let root_window = zero_screen.root();
        (conn, root_window)
    };

    subscribe_to_window_property_events(&conn, root_window)?;

    let known_atoms = KnownAtoms::get_atoms(&conn)?;
    let mut last_active_screen: Option<Window> = None;
    loop {
        let event = conn.wait_for_event()?;

        if let xcb::Event::X(xcb::x::Event::PropertyNotify(property_notify_event)) = event {
            if property_notify_event.atom() == known_atoms.net_active_window {
                if let Some(win) = last_active_screen {
                    unsubscribe_all_events_from_window(&conn, win)?;
                }
                let active_window = handle_active_window_change(&conn, root_window, &known_atoms)?;
                if let Some(win) = active_window {
                    subscribe_to_window_property_events(&conn, win)?;
                }
                last_active_screen = active_window;
            } else if property_notify_event.atom() == known_atoms.net_wm_name {
                let new_title =
                    get_window_title(&conn, property_notify_event.window(), &known_atoms)?;
                println!("{new_title}");
            }
        }
    }
}
