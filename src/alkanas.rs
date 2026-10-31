use base::config::keys;
use hbb_common::config;

// custom.txt must be signed with RustDesk's key, so these are applied here instead.
// The permanent password is hidden, not locked: the Alkanas installer and
// updater rotate it with --password.
pub fn apply_builtin_settings() {
    let mut builtin = config::BUILTIN_SETTINGS.write().unwrap();
    for k in [
        keys::OPTION_HIDE_SERVER_SETTINGS,
        keys::OPTION_HIDE_PROXY_SETTINGS,
        keys::OPTION_HIDE_WEBSOCKET_SETTINGS,
        keys::OPTION_HIDE_SECURITY_SETTINGS,
        keys::OPTION_HIDE_STOP_SERVICE,
        keys::OPTION_HIDE_POWERED_BY_ME,
        keys::OPTION_DISABLE_CHANGE_ID,
    ] {
        builtin.insert(k.to_owned(), "Y".to_owned());
    }
    drop(builtin);

    // The baked-in defaults alone leave custom-rendezvous-server empty, which makes
    // using_public_server() true: the "set up your own server" tip shows and relayed
    // sessions get the public-server limits.
    let mut overwrite = config::OVERWRITE_SETTINGS.write().unwrap();
    if let Some(server) = config::RENDEZVOUS_SERVERS.first() {
        overwrite.insert(
            keys::OPTION_CUSTOM_RENDEZVOUS_SERVER.to_owned(),
            server.to_string(),
        );
    }
    overwrite.insert(keys::OPTION_KEY.to_owned(), config::RS_PUB_KEY.to_owned());
}
