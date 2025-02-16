include gitea
# @summary
# Applies configuration for `gitea` class to system.
#
# @param configuration_sections
# INI style settings for configuring Gitea.
#
# @param owner
# The user owning gitea and its' files. Default: 'git'
#
# @param group
# The group owning gitea and its' files. Default: 'git'
#
# @param installation_directory
# Target directory to hold the gitea installation. Default: '/opt/gitea'
#
# @param repository_root
# Directory where gitea will keep all git repositories. Default: '/var/git'
#
# @param log_directory
# Log directory for gitea. Default: '/var/log/gitea'
#
# @param attachment_directory
# Directory for storing attachments. Default: '/opt/gitea/data/attachments'
#
# @param lfs_enabled
# Make use of git-lfs. Default: false
#
# @param lfs_content_directory
# Directory for storing LFS data. Default: '/opt/gitea/data/lfs'
#
# @param robots_txt
# Allows to provide a http://www.robotstxt.org/ file to restrict crawling.
#
# Authors
# -------
#
# Daniel S. Reichenbach <daniel@kogitoapp.com>
#
# Copyright
# ---------
#
# Copyright 2016-2019 Daniel S. Reichenbach <https://kogitoapp.com>
#
class gitea::config (
  Hash $configuration_sections   = $gitea::configuration_sections,
  String $owner                  = $gitea::owner,
  String $group                  = $gitea::group,
  String $installation_directory = $gitea::installation_directory,
  String $repository_root        = $gitea::repository_root,
  String $log_directory          = $gitea::log_directory,
  String $attachment_directory   = $gitea::attachment_directory,
  String $lfs_content_directory  = $gitea::lfs_content_directory,
  Boolean $lfs_enabled           = $gitea::lfs_enabled,
  String $robots_txt             = $gitea::robots_txt,
) {
  $required_settings = {
    '' => {
      'RUN_USER' => $owner,
    },
    'repository' => {
      'ROOT' => $repository_root,
    },
    'log' => {
      'MODE' => 'file',
      'ROOT_PATH' => $log_directory,
    },
    'attachment' => {
      'ENABLE' => true,
      'PATH' => $attachment_directory,
    },
    'server' => {
      'LFS_START_SERVER' => $lfs_enabled,
      'LFS_CONTENT_PATH' => $lfs_content_directory,
    },
  }

  $gitea_configuration = {
    'path'    => "${installation_directory}/custom/conf/app.ini",
    'require' => File["${installation_directory}/custom/conf"],
  }

  $template_app_ini_sections = deep_merge($required_settings, $configuration_sections)

  file { "${installation_directory}/custom":
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
  }

  -> file { "${installation_directory}/custom/conf":
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${installation_directory}/custom"],
  }

  create_ini_settings($template_app_ini_sections, $gitea_configuration)

  exec { "permissions:${installation_directory}/custom":
    command     => "chown -Rf ${owner}:${group} ${installation_directory}/custom",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  if $robots_txt != '' {
    file { "${installation_directory}/custom/robots.txt":
      mode   => '0644',
      source => $robots_txt,
    }
  }
}
