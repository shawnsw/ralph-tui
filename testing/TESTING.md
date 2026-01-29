# Ralph-TUI Manual Testing Guide

This guide describes a **repeatable, idempotent** method for manually testing Ralph-TUI's end-to-end workflow, including the parallel task execution feature.

## Quick Start

```bash
# One-time setup
cd testing
./setup-test-workspace.sh

# Run the test
cd test-workspace
ralph-tui run --prd ../test-prd.json

# If something goes wrong, stop and reset
./reset-test.sh

# Run again
ralph-tui run --prd ../test-prd.json
```

## Test Architecture

### What Gets Tested

The test PRD (`test-prd.json`) creates a **dependency graph** that exercises:

```
TEST-001 (P1) ─────┐
                   ├──▶ TEST-004 (P2) ─────┐
TEST-002 (P1) ─────┘                       │
                                           ├──▶ TEST-005 (P3)
TEST-003 (P2) ────────────────────────────┘
```

| Task | Priority | Dependencies | Purpose |
|------|----------|--------------|---------|
| TEST-001 | P1 (high) | None | Independent task, can run in parallel |
| TEST-002 | P1 (high) | None | Independent task, can run in parallel |
| TEST-003 | P2 (medium) | None | Independent task, can run in parallel |
| TEST-004 | P2 (medium) | TEST-001, TEST-002 | Tests dependency resolution |
| TEST-005 | P3 (low) | TEST-003, TEST-004 | Final aggregation task |

### State That Gets Reset

| State Type | Location | Reset Method |
|------------|----------|--------------|
| Task completion | `test-prd.json` | All `passes` → `false` |
| Session state | `.ralph-tui/session.json` | Deleted |
| Session lock | `.ralph-tui/lock.json` | Deleted |
| Progress context | `.ralph-tui/progress.md` | Deleted |
| Iteration logs | `.ralph-tui/iterations/` | Directory cleared |
| Generated files | `output-*.txt`, `merged-*.txt`, `summary.txt` | Deleted |
| Git state | `.git/` | Optional: `git reset --hard test-start` |

## Detailed Workflow

### 1. Initial Setup (One Time)

```bash
cd /path/to/ralph-tui/testing
./setup-test-workspace.sh
```

This creates:
- `test-workspace/` - A fresh git repo for testing
- Initial commit with README and .gitignore
- Git tag `test-start` for easy hard reset

### 2. Running a Test

```bash
cd test-workspace

# Option A: Using installed ralph-tui
ralph-tui run --prd ../test-prd.json

# Option B: Using development build
cd /path/to/ralph-tui
bun run dev -- run --prd testing/test-prd.json
```

### 3. Observing the Workflow

Watch for these stages:

1. **Task Selection**: Ralph should select TEST-001 or TEST-002 first (both P1, no deps)
2. **Prompt Building**: Check the prompt includes task details and acceptance criteria
3. **Agent Execution**: Watch the agent create the output files
4. **Completion Detection**: Agent should emit `<promise>COMPLETE</promise>`
5. **Task Update**: PRD file should update `passes: true`
6. **Next Task**: Cycle repeats with dependency awareness

### 4. Testing Specific Scenarios

#### Parallel Task Execution
When parallel execution is implemented, TEST-001, TEST-002, and TEST-003 should be eligible to run simultaneously since they have no dependencies on each other.

To verify:
- Check that multiple tasks are selected in the same iteration
- Verify agents are spawned concurrently
- Confirm all three complete before TEST-004 starts

#### Dependency Resolution
TEST-004 should **not** be selected until both TEST-001 and TEST-002 are complete:
- If you see TEST-004 start while TEST-001 or TEST-002 are incomplete → **Bug!**

#### Error Recovery
To test error handling:
1. Start a test run
2. Kill the agent mid-execution (Ctrl+C on the agent process)
3. Run `ralph-tui resume`
4. Verify the task that was interrupted is retried

### 5. Resetting for Re-test

**Soft Reset** (keeps git history):
```bash
cd /path/to/ralph-tui/testing
./reset-test.sh
```

**Hard Reset** (full clean slate):
```bash
cd test-workspace
git reset --hard test-start
git clean -fd
cd ..
./reset-test.sh
```

## Files Reference

| File | Purpose |
|------|---------|
| `testing/test-prd.json` | Test PRD with 5 tasks and dependencies |
| `testing/setup-test-workspace.sh` | Creates fresh test workspace |
| `testing/reset-test.sh` | Resets all state for re-testing |
| `testing/test-workspace/` | The actual test git repo (created by setup) |
| `testing/TESTING.md` | This documentation |

## What Repo Should I Test On?

**Use the test workspace** (`testing/test-workspace/`) for systematic testing. This is:
- **Isolated**: Won't affect any real projects
- **Idempotent**: Can be fully reset
- **Controlled**: Known initial state
- **Git-enabled**: Can test commit behavior

For testing with **real-world complexity**, you can also:
1. Clone any open source project to a temp directory
2. Create a `prd.json` with actual feature tasks
3. Run ralph-tui against it
4. Delete the temp directory when done

## Troubleshooting

### Test won't start
```bash
# Check for stale lock
cat test-workspace/.ralph-tui/lock.json

# Remove if stale
rm test-workspace/.ralph-tui/lock.json
```

### Task status won't reset
```bash
# Manually verify PRD
cat testing/test-prd.json | jq '.userStories[].passes'

# Force reset with jq
jq '.userStories |= map(.passes = false)' testing/test-prd.json > tmp.json && mv tmp.json testing/test-prd.json
```

### Agent keeps failing
Check the iteration logs:
```bash
ls -la test-workspace/.ralph-tui/iterations/
cat test-workspace/.ralph-tui/iterations/*.log | tail -100
```

### Git state is corrupted
```bash
cd test-workspace
git status
git reset --hard test-start
git clean -fd
```

## CI/Automated Testing

For automated testing in CI, you can run:

```bash
# Setup
./testing/setup-test-workspace.sh

# Run headless with max iterations
ralph-tui run --prd testing/test-prd.json --headless --iterations 10

# Verify completion
jq '.userStories | all(.passes)' testing/test-prd.json
# Should output: true

# Verify output files exist
test -f testing/test-workspace/summary.txt && echo "PASS" || echo "FAIL"
```

## Contributing

When adding new test scenarios:

1. Add new user stories to `test-prd.json`
2. Update this documentation
3. Consider adding automated verification to `reset-test.sh`
4. Ensure new scenarios maintain idempotency
