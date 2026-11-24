# CloudByte Solutions: Linux SysAdmin Project

A Linux system administration project, built first on a local VM
and later deployed to AWS EC2. The scenario is CloudByte Solutions, a
fictional 12-person startup that needs a properly configured multi-user
Linux server: user accounts, group-based file access, automated backups,
log analysis, and system health reporting.

## Section 1: Server Foundations

Built the core of the server: four groups (`engineering`, `marketing`,
`operations`, `admins`), twelve user accounts, and a directory tree under
`/shared` with group-based access control.

### Groups and users

| Group | Members |
|---|---|
| `engineering` | alice, bob, carol, dave |
| `marketing` | emma, frank, grace |
| `operations` | henry, iris, jack, kate, leo |
| `admins` | kate, leo |

### Directory structure

| Path | Group | Mode |
|---|---|---|
| `/shared/engineering` | engineering | `770` |
| `/shared/marketing` | marketing | `770` |
| `/shared/operations` | operations | `770` |
| `/shared/company-docs` | admins | `775` |
| `/logs/reports` | admins | `775` |

### Verification

`verify-foundations.sh` checks the groups, users, directories and setup
log in one go. Run it on the VM with:

    # Track 1 (Vagrant): repo is mounted at /vagrant
    bash /vagrant/verify-foundations.sh

    # Track 2 (Lima): repo is mounted at /host inside the VM
    bash /host/verify-foundations.sh


## Section 2: File Management and Permissions

Configured setgid on the team folders so new files inherit the team's group.
Added a shared dropbox with a sticky bit to protect submissions from deletion
by other contributors. See the [permissions test report](docs/permissions-test-report.md)
for the expected and observed results.

| Path | Owner:Group | Mode | Behavior |
|---|---|---|---|
| `/shared/engineering` | `root:engineering` | `2770` | New files inherit group `engineering`. |
| `/shared/marketing` | `root:marketing` | `2770` | New files inherit group `marketing`. |
| `/shared/operations` | `root:operations` | `2770` | New files inherit group `operations`. |
| `/shared/dropbox` | `root:admins` | `1773` | Contributors can submit files but cannot list the directory. The sticky bit prevents cross-user deletion. |

### Verification

Run inside the Lima VM:

```bash
bash /host/verify-permissions.sh
```

Verified on the CloudByte VM: **18 passed, 0 failed**.