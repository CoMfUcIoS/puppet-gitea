include gitea
# @summary
# Installs gitea, and sets up the directory structure required to run Gitea.
#
# @param package_ensure
# Decides if the `gitea` binary will be installed. Default: 'present'
#
# @param owner
# The user owning gitea and its' files. Default: 'git'
#
# @param group
# The group owning gitea and its' files. Default: 'git'
#
# @param proxy
# Download via specified proxy. Default: empty
# @param base_url
# Download base URL. Default: Github. Can be used for local mirrors.
#
# @param version
# Version of gitea to install. Default: '1.17.3'
#
# @param checksum
# Checksum for the binary.
# Default: '38c4e1228cd051b785c556bcadc378280d76c285b70e8761cd3f5051aed61b5e'
#
# @param checksum_type
# Type of checksum used to verify the binary being installed. Default: 'sha256'
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
# @param manage_service
# Should we manage a service definition for Gitea?
#
# @param service_template
# Path to service template file.
#
# @param service_path
# Where to create the service definition.
#
# @param service_provider
# Which service provider do we use?
#
# @param service_mode
# File mode for the created service definition.
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
class gitea::install (
  Enum['present','absent'] $package_ensure = $gitea::package_ensure,
  String $owner                  = $gitea::owner,
  String $group                  = $gitea::group,

  Optional[String] $proxy        = $gitea::proxy,
  String $base_url               = $gitea::base_url,
  String $version                = $gitea::version,
  String $checksum               = $gitea::checksum,
  String $checksum_type          = $gitea::checksum_type,
  String $installation_directory = $gitea::installation_directory,
  String $repository_root        = $gitea::repository_root,
  String $log_directory          = $gitea::log_directory,
  String $attachment_directory   = $gitea::attachment_directory,
  Boolean $lfs_enabled           = $gitea::lfs_enabled,
  String $lfs_content_directory  = $gitea::lfs_content_directory,

  Boolean $manage_service        = $gitea::manage_service,
  String $service_template       = $gitea::service_template,
  String $service_path           = $gitea::service_path,
  String $service_provider       = $gitea::service_provider,
  String $service_mode           = $gitea::service_mode,
) {
  file { $repository_root:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${repository_root}"],
  }

  -> file { $installation_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${installation_directory}"],
  }

  -> file { "${installation_directory}/data":
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
  }

  -> file { $attachment_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${attachment_directory}"],
  }

  -> file { $lfs_content_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${lfs_content_directory}"],
  }

  -> file { $log_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${log_directory}"],
  }

  if ($package_ensure) {
    $kernel_down=downcase($facts['kernel'])

    case $facts['os']['architecture'] {
      /(x86_64)/: {
        $arch = 'amd64'
      }
      /(x86)/: {
        $arch = '386'
      }
      default: {
        $arch = $facts['os']['architecture']
      }
    }

    $source_url="${base_url}/${version}/gitea-${version}-${kernel_down}-${arch}"

    remote_file { 'gitea':
      ensure        => $package_ensure,
      path          => "${installation_directory}/gitea",
      source        => $source_url,
      proxy         => $proxy,
      checksum      => $checksum,
      checksum_type => $checksum_type,
      notify        => [
        Exec["permissions:${$installation_directory}/gitea"],
        Service['gitea']
      ],
    }
  }

  exec { "permissions:${installation_directory}":
    command     => "chown -Rf ${owner}:${group} ${installation_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${$installation_directory}/gitea":
    command     => "chmod +x ${$installation_directory}/gitea",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${repository_root}":
    command     => "chown -Rf ${owner}:${group} ${repository_root}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${log_directory}":
    command     => "chown -Rf ${owner}:${group} ${log_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${attachment_directory}":
    command     => "chown -Rf ${owner}:${group} ${attachment_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${lfs_content_directory}":
    command     => "chown -Rf ${owner}:${group} ${lfs_content_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  if ($manage_service) {
    file { "service:${service_path}":
      path    => $service_path,
      content => template($service_template),
      mode    => $service_mode,
    }
  }
}
