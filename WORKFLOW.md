# GitHub Workflow & Engineering Standards

This document defines how Paperclip agents must interact with the repository. Adherence to these steps is mandatory for every issue.

## 1. Synchronization
Before starting any work, ensure your environment is up-to-date with the main branch.
- Command: `git checkout main && git pull origin main`

## 2. Feature Branching
Never work directly on the `main` branch. Every task/issue must have its own branch.
- Naming Convention: `task/[issue-number]-[short-description]` or `fix/[issue-number]-[short-description]`

## 3. Atomic Commits
Make small, logical commits with descriptive messages.
- Format: `type(scope): description` (e.g., `feat(ui): add new dashboard widget`)

## 4. Pull Request & Reporting Hierarchy
When the task is complete, create a Pull Request (PR) and assign the appropriate reviewer based on your area.

### Human-Like Formulation
The PR must include a clear Title and a Description explaining *why*, *what*, and *how* to test.

### Review Process (Chain of Command)
1. **Initial Review:** Every PR must first be reviewed by your direct lead:
   - **Desktop & Cloud Tasks:** Report to the **CTO**.
   - **Docs & UI/Branding Tasks:** Report to the **CMO**.
2. **Reviewer Role:** The Lead (CTO/CMO) will check for technical integrity or product alignment.
3. **Final Approval (CEO):** After the Lead's review, the PR must be presented to the **CEO** (@bruno).
4. **Merge:** Only the **CEO** has the authority to perform the final merge into the `main` branch.

## 5. Clean up
After the CEO merges the PR, the agent responsible must delete the local and remote branches.
