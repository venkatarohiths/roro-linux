# CI Build Artifacts

Roro Linux now has a GitHub Actions pipeline that builds the x86_64 tiny profile on Ubuntu.

## Workflow
- `.github/workflows/buildroot-x86_64.yml`

## Trigger
- Pushes to `main` that change configs/scripts/workflow
- Manual run via `workflow_dispatch`

## Output
- Buildroot image artifacts uploaded as `roro-linux-x86_64-tiny`
- Manifest/smoke docs attached when present

## Why this matters
Even if local Windows host lacks WSL/QEMU, we still produce real Linux build artifacts in CI.
