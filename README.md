# Nix Python Dev

Quick start template for python project.

## Usage

## 1. Nix

```shell
# Clone this repository & cd
git clone https://github.com/Dessera/nix-python-dev
cd nix-python-dev
# Auto enable the dev shell
direnv allow
```

### Note

Some python executable cannot run correctly in nix environment because of mismatched environment, there are two ways to solve it:

- use executables in `nixpkgs`
- use `poetry run ...`

There must be a better way to solve this, but I have not found yet :(

## 2. Other Systems or Distributions

```shell
conda create -n <name> python=3.12
conda activate <name>
conda install poetry -c conda-forge
poetry install --no-root
```
