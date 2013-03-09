<?php
$user = posix_getpwuid(posix_geteuid());
echo $user['name'];
?>
