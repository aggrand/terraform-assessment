# Terraform Assessment Modules
submitted by Raiden Worley

## Setting up Pre-commit Hooks
This repo uses pre-commit. It is recommended to install pre-commit using your package manager of choice then run the following from the repo root:

``` shell
pre-commit install
```

## Code Layout
There are two main subdirectories in this project: `modules` and `live`. The former contains building blocks. The latter contains the configuration for environments. In a real project I would want these in separate repos so that we can use semantic versioning on the modules for better stability and reusability. For simplicity and convenience in this project I kept them together in this repo.

## More Notes
I assumed for the moment that we'll only deploy to one region. The `live` configurations could be expanded to more regions, and a real app would probably want to do this, but the exact nature of that expansion would depend heavily on the app and how it functions, whether we'd want an "active-active" approach, how we'd deal with latency between regions, etc. In such a case we'd probably create separate modules under `live` for each region.
