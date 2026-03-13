<?php
/*
Plugin Name: LiteSpeed Cache (MU)
Description: LiteSpeed Cache forced as a Must-Use plugin and auto-configured for Valkey.
Version: 1.1
Author: Dokploy Integration
*/

/**
 * Auto-configure LiteSpeed Cache for Valkey (Redis)
 * These constants override any settings in the database.
 */
if ( ! defined( 'LITESPEED_CONF' ) ) {
    define( 'LITESPEED_CONF', getenv('LITESPEED_CACHE_OBJECT_CONF') !== 'false' );
}
if ( ! defined( 'LITESPEED_CONF__OBJECT' ) ) {
    define( 'LITESPEED_CONF__OBJECT', getenv('LITESPEED_CACHE_OBJECT_ENABLE') !== 'false' );
}
if ( ! defined( 'LITESPEED_CONF__OBJECT__KIND' ) ) {
    define( 'LITESPEED_CONF__OBJECT__KIND', (int)(getenv('LITESPEED_CACHE_OBJECT_KIND') ?: 1) ); // 1 = Redis
}
if ( ! defined( 'LITESPEED_CONF__OBJECT__HOST' ) ) {
    define( 'LITESPEED_CONF__OBJECT__HOST', getenv('VALKEY_HOST') ?: 'valkey' );
}
if ( ! defined( 'LITESPEED_CONF__OBJECT__PORT' ) ) {
    define( 'LITESPEED_CONF__OBJECT__PORT', (int)(getenv('VALKEY_PORT') ?: 6379) );
}

if (defined('WP_PLUGIN_DIR') && file_exists(WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php')) {
    require_once WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php';
}
