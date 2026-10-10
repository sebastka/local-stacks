<?php
// Per-server logins. The image's PMA_USER and PMA_PASSWORD give every server
// in PMA_HOSTS the same one; this gives server <n> PMA_USER_<n> and
// PMA_PASSWORD_<n> instead, as bin/gen-configs writes them to .env. Servers
// without a PMA_USER_<n> keep the image's behaviour.
for ($n = 1; isset($cfg['Servers'][$n]); $n++) {
    $user = getenv("PMA_USER_$n");
    if ($user === false) {
        continue;
    }
    $cfg['Servers'][$n]['auth_type'] = 'config';
    $cfg['Servers'][$n]['user'] = $user;
    $cfg['Servers'][$n]['password'] = (string) getenv("PMA_PASSWORD_$n");
}
