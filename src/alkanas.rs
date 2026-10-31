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
        keys::OPTION_HIDE_HELP_CARDS,
        keys::OPTION_DISABLE_CHANGE_ID,
    ] {
        builtin.insert(k.to_owned(), "Y".to_owned());
    }
}
