<?php
/**
 * Adminer Auth Wrapper
 * Only allows WordPress Administrators to access the database management tool.
 */

// 1. Load WordPress Environment
$wp_load_path = __DIR__ . '/wp-load.php';
if (!file_exists($wp_load_path)) {
    die('WordPress environment not found.');
}
require_once($wp_load_path);

// 2. Check for Administrator Permissions
if (!current_user_can('manage_options')) {
    // If not logged in, redirect to login page
    if (!is_user_logged_in()) {
        auth_redirect();
    } else {
        // Logged in but not an admin
        wp_die('Access Denied. You do not have sufficient permissions to access the database manager.', 'Forbidden', ['response' => 403]);
    }
}

// 3. Define the Adminer login defaults (Optional - pre-fills the server field)
function adminer_object() {
    class AdminerSoftware extends Adminer {
        function login($login, $password) {
            return true; // Still requires the DB password, but handles the UI better
        }
        function name() {
            return 'WP Database Manager';
        }
    }
    return new AdminerSoftware;
}

// 4. Include the core Adminer file
include('/usr/local/src/adminer/adminer.php');
