# @summary
# Manages a Gitea installation on various Linux/BSD operating systems.
#
# @param package_ensure
# Decides if the `gitea` binary will be installed. Default: 'present'
#
# @param dependencies_ensure
# Should dependencies be installed? Defaults to 'present'.
#
# @param dependencies
# List of OS family specific dependencies.
#
# @param manage_user
# Should we manage provisioning the user? Default: true
#
# @param manage_group
# Should we manage provisioning the group? Default: true
#
# @param manage_home
# Should we manage provisioning the home directory? Default: true
#
# @param owner
# The user owning gitea and its' files. Default: 'git'
#
# @param group
# The group owning gitea and its' files. Default: 'git'
#
# @param home
# Qualified path to the users' home directory. Default: empty
#
# @param proxy
# Download via specified proxy. Default: empty
#
# @param base_url
# Download base URL. Default: Github. Can be used for local mirrors.
#
# @param version
# Version of gitea to install. Default: '1.1.0'
#
# @param checksum
# Checksum for the binary.
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
# @param configuration_sections
# INI style settings for configuring Gitea.
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
# @param robots_txt
# Allows to provide a http://www.robotstxt.org/ file to restrict crawling.
#
# Examples
# --------
#
# @example
#    class { 'gitea':
#    }
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
class gitea (
  Enum['present','absent'] $package_ensure,
  Enum['latest','present','absent'] $dependencies_ensure,
  Array[String] $dependencies,

  Boolean $manage_user,
  Boolean $manage_group,
  Boolean $manage_home,
  String $owner,
  String $group,
  Optional[String] $home,

  Optional[String] $proxy,
  String $base_url,
  String $version,
  String $checksum,
  String $checksum_type,
  String $installation_directory,
  String $repository_root,
  String $log_directory,
  String $attachment_directory,
  Boolean $lfs_enabled,
  String $lfs_content_directory,

  Hash $configuration_sections,

  Boolean $manage_service,
  String $service_template,
  String $service_path,
  String $service_provider,
  String $service_mode,

  String $robots_txt,
) {
  contain gitea::begin
  contain gitea::packages
  contain gitea::user
  contain gitea::install
  contain gitea::config
  contain gitea::service
  contain gitea::end

  Class['gitea::begin']
  -> Class['gitea::packages']
  -> Class['gitea::user']
  -> Class['gitea::install']
  -> Class['gitea::config']
  -> Class['gitea::service']
  ~> Class['gitea::end']
}
