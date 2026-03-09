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

// 3. Define the Adminer logic
// We define a fallback class to prevent Fatal Error if the single-file version
// hasn't fully registered the global 'Adminer' class at this exact moment.
if (!class_exists('Adminer')) {
    class Adminer { }
}

function adminer_object() {
    class AdminerSoftware extends Adminer {
        /**
         * Automatically provide database credentials from WordPress constants
         */
        function credentials() {
            return [DB_HOST, DB_USER, DB_PASSWORD];
        }

        /**
         * Automatically select the WordPress database
         */
        function database() {
            return DB_NAME;
        }

        /**
         * Bypass the login form and authenticate using WP credentials
         */
        function login($login, $password) {
            return true;
        }

        /**
         * Hide the login form entirely since we are auto-logged in
         */
        function loginForm() {
            return true; 
        }

        function name() {
            return 'WP Database Manager';
        }

        function head() {
            $design = $_ENV['ADMINER_DESIGN'] ?? getenv('ADMINER_DESIGN');
            if ($design) {
                echo '<link rel="stylesheet" type="text/css" href="https://www.adminer.org/static/download/' . htmlspecialchars($design) . '/adminer.css">';
            }
            return true;
        }
    }
    return new AdminerSoftware;
}

// 4. Include the core Adminer file
include('/usr/local/src/adminer/adminer.php');
