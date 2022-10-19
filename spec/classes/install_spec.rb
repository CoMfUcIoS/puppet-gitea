require 'spec_helper'

describe 'gitea::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        let :params do
          {
            package_ensure: 'present',
            base_url: 'https://dl.gitea.io/gitea',
            version: '1.17.3',
            checksum: '38c4e1228cd051b785c556bcadc378280d76c285b70e8761cd3f5051aed61b5e',
            checksum_type: 'sha256',
            owner: 'git',
            group: 'git',
            installation_directory: '/opt/gitea',
            repository_root: '/var/git',
            log_directory: '/var/log/gitea',
            attachment_directory: '/opt/gitea/data/attachments',
            lfs_enabled: false,
            lfs_content_directory: '/opt/gitea/data/lfs',
            manage_service: true,
            service_template: 'gitea/systemd.erb',
            service_path: '/lib/systemd/system/gitea.service',
            service_provider: 'systemd',
            service_mode: '0644',
          }
        end

        it { is_expected.to contain_remote_file('gitea') }
        it { is_expected.to contain_file('/opt/gitea') }
        it { is_expected.to contain_file('/opt/gitea/data') }
        it { is_expected.to contain_file('/opt/gitea/data/attachments') }
        it { is_expected.to contain_file('/opt/gitea/data/lfs') }
        it { is_expected.to contain_file('/var/log/gitea') }
        it { is_expected.to contain_file('/var/git') }
        it { is_expected.to contain_file('service:/lib/systemd/system/gitea.service') }
        it { is_expected.to contain_exec('permissions:/opt/gitea') }
        it { is_expected.to contain_exec('permissions:/opt/gitea/gitea') }
        it { is_expected.to contain_exec('permissions:/opt/gitea/data/attachments') }
        it { is_expected.to contain_exec('permissions:/opt/gitea/data/lfs') }
        it { is_expected.to contain_exec('permissions:/var/log/gitea') }
        it { is_expected.to contain_exec('permissions:/var/git') }
      end
    end
  end
end
