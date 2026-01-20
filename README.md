# Magit Notes

Small, practical notes for day-to-day Magit usage in this Emacs setup.

## Daily Flow

- `C-x g` to open Magit status for the current repo.
- `s`/`u` to stage/unstage hunks; `S` to stage all.
- `c c` to commit; edit message, then `C-c C-c` to finish.
- `f` to fetch, `p` to push, `F` to pull.

## Handy Niche Moves

- Edit and stage a hunk: `e` on a hunk, tweak lines, `C-c C-c` to stage.
- Stash unstaged only: `Z z` then `k` (keep index).
- Create fixup commit: `c f`, then autosquash with `r a`.
- Diff a range: `D r` (e.g., `origin/main..HEAD`).
- Log a file: open the file, then `L` for file log.
- Use worktrees: `W` to create/open a worktree for parallel tasks.

## Conflict Resolution

- `smerge-mode` is your friend in conflict buffers.
- `n`/`p` to jump conflicts, `a`/`b`/`C`/`R` to keep variants.
- Back in Magit, `s` to stage resolved hunks.

## Cherry-Picking

Practical ways to bring commits across branches without leaving Magit.

### Basic cherry-pick

1) Open Magit status in the target branch.
2) Use `l` to open the log, navigate to the commit.
3) Press `A` to apply (cherry-pick), confirm.
4) If conflicts occur, resolve in the file, `s` to stage, then `C-c C-c` to continue.

### Cherry-pick a range

- In log, mark the first commit with `m`.
- Move to the last commit, then `A` to apply the range.
- Magit will prompt to apply the marked range in order.

### Cherry-pick with edits

- Use `A` on a commit, then edit the commit message when prompted.
- If you want to adjust the patch, use `A` then open the commit buffer, edit files, stage hunks, `C-c C-c`.

### Abort or skip

- `A` opens the apply popup; from there choose abort if needed.
- If a commit is empty after conflicts, skip it when Magit offers the choice.

## Stacked Branch Rebases

Ways to keep a small stack of dependent branches clean and up to date.

### Keep the base branch updated

1) Checkout the base (e.g., `main`), then `f` fetch.
2) `F` to pull, or `b b` to switch and `F` to update.

### Rebase a stack in order

Assume branches `feat-1` -> `feat-2` -> `feat-3`, each based on the previous.

1) Checkout `feat-1`, run `r i` and rebase onto `main`.
2) Checkout `feat-2`, `r i` and rebase onto `feat-1`.
3) Checkout `feat-3`, `r i` and rebase onto `feat-2`.

### Rebase with autosquash

- Create fixups on each branch with `c f`.
- On rebase, use `r a` to start interactive rebase with autosquash.

### When conflicts repeat

- Resolve on the earliest branch in the stack first.
- Use `r` to continue, then move to the next branch.
- Consider `git rerere` if you see the same conflict repeatedly.

## Tips

- Keep Magit status open in a dedicated window layout.
- Prefer staging hunks instead of full files to keep commits tight.
- Use `l` in status for a quick repo log, and `l r` for ranges.
