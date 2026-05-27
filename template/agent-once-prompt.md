You are working on issue #__ISSUE_NUMBER__ ONLY. Do not work on any other issue.

1. Fetch the issue: `gh issue view __ISSUE_NUMBER__ --json number,title,body`

2. Read the entire issue body carefully. Pay attention to:
   - What to build
   - Acceptance criteria
   - Files to modify
   - New files to create

3. Implement the solution:
   - Follow the acceptance criteria exactly
   - Modify only the files listed in "Existing files to modify"
   - Create only the files listed in "New files"
   - Do not add scope creep

4. Run tests, type checks, and lint:
   - Fix any failures
   - Ensure all acceptance criteria are met

5. Commit with message: `fixes #__ISSUE_NUMBER__`

6. Leave a comment on the issue summarizing what was done:
   `gh issue comment __ISSUE_NUMBER__ --body "..."`
   Do NOT close the issue and do NOT change its labels.
   The orchestrator handles closing and label transitions.

7. Output `<promise>COMPLETE</promise>` when done

If you encounter errors or blockers, fix them and retry. Do not give up.
