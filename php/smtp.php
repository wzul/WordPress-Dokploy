<?php
/**
 * Plugin Name: SMTP Relay Configuration
 * Description: Automatically routes all WordPress emails through the mail-relay sidecar without any plugin.
 */

add_action('phpmailer_init', function($phpmailer) {
    $phpmailer->isSMTP();
    $phpmailer->Host       = 'mail-relay';
    $phpmailer->Port       = 25;
    $phpmailer->SMTPAuth   = false;
    $phpmailer->SMTPSecure = ''; // No encryption needed for internal Docker network
});
