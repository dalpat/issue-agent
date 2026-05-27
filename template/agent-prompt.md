You are working on this repo. Pick exactly ONE open GitHub issue, implement it, and commit.

1. Ensure the label `picked by agent` exists. Create it if missing.

2. Fetch open issues: `gh issue list --json number,title,body,labels,assignees,linkedPullRequests`

3. Identify the parent issue (usually labeled `PRD`, `epic`, or `parent`, or has sub-issues linked). Do NOT close the parent issue.

4. Pick ONE child issue to work on (skip the parent and any issue labeled `picked by agent`):
   - Prefer unblocked issues first
   - Pick by priority: critical > high > medium > low
   - Label it immediately: `gh issue edit <number> --add-label "picked by agent"`
   - Do NOT pick issues blocked by an OPEN issue

5. Implement ONLY that issue. No scope creep. Run tests, type checks, lint. Fix failures.

6. Append progress to `.agent/progress.md` (create if missing).

7. Commit: `fixes #N`. Only one feature per commit.

8. Close the issue with a comment. Change its label to `completed by agent`.

9. After closing, run `gh issue list --state open --json number,title` one more time. Count the remaining child issues.

10. **If and ONLY if zero child issues remain open, output `<promise>COMPLETE</promise>`.**
    **If any child issues are still open, do NOT output COMPLETE. Just stop normally.**
