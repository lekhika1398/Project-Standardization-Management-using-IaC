#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "[1/6] Checking required files"
required_files=(
  "main.tf"
  "providers.tf"
  "variables.tf"
  "outputs.tf"
  "backend.tf"
  ".github/workflows/terraform-governance.yml"
  "policies/tagging/definition.json"
  "policies/naming/definition.json"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required file: $file"; exit 1; }
done

echo "[2/6] Validating policy JSON files"
python3 - <<'PY'
import json,glob
files=sorted(glob.glob('policies/*/definition.json'))
if not files:
    raise SystemExit('No policy definition.json files found under policies/*')
for path in files:
    with open(path, 'r', encoding='utf-8') as fh:
        json.load(fh)
print(f'Validated {len(files)} policy JSON file(s)')
PY

echo "[3/6] Validating workflow YAML"
python3 - <<'PY'
import yaml
with open('.github/workflows/terraform-governance.yml', 'r', encoding='utf-8') as fh:
    yaml.safe_load(fh)
print('Workflow YAML is valid')
PY

echo "[4/6] Root variable/reference consistency check"
python3 - <<'PY'
import re

declared=set()
with open('variables.tf', 'r', encoding='utf-8') as fh:
    txt=fh.read()
for m in re.finditer(r'variable\s+"([^"]+)"', txt):
    declared.add(m.group(1))

refs=set()
for path in ['main.tf','providers.tf','outputs.tf','backend.tf']:
    with open(path, 'r', encoding='utf-8') as fh:
        t=fh.read()
    refs.update(re.findall(r'var\.([A-Za-z0-9_]+)', t))

missing=sorted(refs-declared)
if missing:
    raise SystemExit(f'Missing variable declaration(s): {missing}')
print(f'Variable consistency OK (declared={len(declared)}, referenced={len(refs)})')
PY

if command -v terraform >/dev/null 2>&1; then
  echo "[5/6] Terraform format check"
  terraform fmt -check -recursive

  echo "[6/6] Terraform init (no backend) and validate"
  terraform init -backend=false -input=false >/dev/null
  terraform validate
else
  echo "[5/6] Terraform not found, skipping terraform fmt"
  echo "[6/6] Terraform not found, skipping terraform init/validate"
fi

echo "Preflight checks completed successfully"
