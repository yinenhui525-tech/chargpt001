#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/run_easysteer_experiment.sh [--repo-url URL] [--workdir DIR] [--env-name NAME] [--source PATH]

Options:
  --repo-url URL   Git repo URL for EasySteer.
  --workdir DIR    Working directory used for setup.
  --env-name NAME  Conda environment name.
  --source PATH    Local EasySteer source (directory / .tar.gz / .zip).
                   If provided, network clone is skipped.
USAGE
}

REPO_URL="https://github.com/ZJU-REAL/EasySteer.git"
WORKDIR="${HOME}/easysteer_run"
ENV_NAME="easysteer"
LOCAL_SOURCE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-url)
      REPO_URL="$2"; shift 2 ;;
    --workdir)
      WORKDIR="$2"; shift 2 ;;
    --env-name)
      ENV_NAME="$2"; shift 2 ;;
    --source)
      LOCAL_SOURCE="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1 ;;
  esac
done

printf "[1/6] Preparing workspace: %s\n" "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

printf "[2/6] Getting EasySteer source...\n"
if [[ -n "$LOCAL_SOURCE" ]]; then
  if [[ ! -e "$LOCAL_SOURCE" ]]; then
    echo "ERROR: --source path does not exist: $LOCAL_SOURCE"
    exit 4
  fi

  rm -rf EasySteer
  if [[ -d "$LOCAL_SOURCE" ]]; then
    cp -a "$LOCAL_SOURCE" EasySteer
  elif [[ "$LOCAL_SOURCE" == *.tar.gz || "$LOCAL_SOURCE" == *.tgz ]]; then
    mkdir -p EasySteer
    tar -xzf "$LOCAL_SOURCE" -C EasySteer --strip-components=1
  elif [[ "$LOCAL_SOURCE" == *.zip ]]; then
    if ! command -v unzip >/dev/null 2>&1; then
      echo "ERROR: unzip not found, cannot extract zip archive."
      exit 5
    fi
    mkdir -p EasySteer
    unzip -q "$LOCAL_SOURCE" -d "$WORKDIR/.easysteer_unzip_tmp"
    inner_dir="$(find "$WORKDIR/.easysteer_unzip_tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    cp -a "$inner_dir"/. EasySteer
    rm -rf "$WORKDIR/.easysteer_unzip_tmp"
  else
    echo "ERROR: Unsupported --source type. Use directory / .tar.gz / .zip"
    exit 6
  fi
else
  if ! curl -IsSf https://github.com >/dev/null 2>&1; then
    echo "ERROR: Cannot reach https://github.com from current environment."
    echo "Hint: pass --source <local-path> to run without network clone."
    exit 2
  fi

  if [[ ! -d EasySteer ]]; then
    git clone "$REPO_URL" EasySteer
  fi
fi

cd EasySteer

printf "[3/6] Checking conda...\n"
if ! command -v conda >/dev/null 2>&1; then
  echo "ERROR: conda not found. Install Miniconda/Anaconda first."
  exit 3
fi

# shellcheck disable=SC1091
source "$(conda info --base)/etc/profile.d/conda.sh"
printf "[4/6] Creating/activating env: %s\n" "$ENV_NAME"
if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  conda create -y -n "$ENV_NAME" python=3.10
fi
conda activate "$ENV_NAME"

printf "[5/6] Installing dependencies...\n"
if [[ -f requirements.txt ]]; then
  pip install -r requirements.txt
elif [[ -f setup.py || -f pyproject.toml ]]; then
  pip install -e .
else
  echo "WARNING: No requirements.txt/setup.py/pyproject.toml found."
fi

printf "[6/6] Detecting experiment entrypoint...\n"
if [[ -f scripts/train.sh ]]; then
  echo "Found scripts/train.sh"
  echo "Run: bash scripts/train.sh"
elif [[ -f train.py ]]; then
  echo "Found train.py"
  echo "Run: python train.py --help"
else
  echo "No standard train entrypoint found. Please check README."
fi

echo "Bootstrap complete."
