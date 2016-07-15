class nfs::server::rhel::services (
    $ensure     = running,
    $enable     = true,
    $configonly = false,
) {

    require portmap
   
    if $configonly == false {
        case $::operatingsystemmajrelease {
            '7': {
                $nfs_service = 'nfs-server'
                $nfs_lock_service = 'rpc-statd'

                # Workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1171603
                exec {"workaround rhel7 nfs-server systemd bug":
                    command => "/bin/systemctl start rpcbind.service && sleep 5",
                    unless => "/bin/systemctl is-active rpcbind-service > /dev/null",
                }
            }
            default: {
                $nfs_service = 'nfs'
                $nfs_lock_service = 'nfslock'
            }
        }

        service { $nfs_service:
            ensure     => $ensure,
            enable     => $enable,
            hasstatus  => true,
            hasrestart => true,
        }

        service { $nfs_lock_service:
            ensure     => $ensure,
            enable     => $enable,
            hasstatus  => true,
            hasrestart => true,
        }
    }
}
