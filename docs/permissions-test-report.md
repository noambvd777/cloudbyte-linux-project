# CloudByte Permissions Test Report: Section 2

Date: 2026-11-24

| User | Action | Expected | Observed |
|---|---|---|---|
| cloudcourse | Enter `/shared/engineering` without sudo | Denied | `Permission denied`. The chained `touch` did not run. |
| alice | Create `fresh-from-alice.txt` in `/shared/engineering` | Allowed; group `engineering` | Created with owner `alice` and group `engineering`. |
| root (via sudo) | Search the three team folders for files with their team group | Every file matches its team group | All files matched, confirmed by `verify-permissions.sh`. |
| emma | Create `emma-note.txt` in `/shared/dropbox` | Allowed | File created with owner `emma`. |
| bob | Create `bob-note.txt` in `/shared/dropbox` | Allowed | File created with owner `bob`. |
| emma | List `/shared/dropbox` | Denied | `Permission denied`. |
| emma | Read `/shared/dropbox/bob-note.txt` by its full path | Allowed with file mode `644` | Bob's note was printed. |
| emma | Delete `/shared/dropbox/bob-note.txt` | Denied | `Operation not permitted`. Bob's note remained in place. |
| kate | List `/shared/dropbox` and read both notes | Allowed | Both filenames and both messages were displayed. |

## Notes

- Setgid (`2770`) makes new files inherit the team directory's group. Existing files were updated with `chgrp`.
- The sticky bit on `/shared/dropbox` prevented Emma from deleting Bob's submission.
- Dropbox users cannot list submissions. A user who knows a filename can still read the file if its permissions allow it, as Bob's `644` note demonstrated.

## Automated verification

Ran `bash /host/verify-permissions.sh` inside the Lima VM.

**Result: 18 passed, 0 failed.**
