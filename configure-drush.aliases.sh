#!/usr/bin/env bash
cp -u ./docker.aliases.drushrc.php /root/.drush/
drush @docker.local status
