![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/renao/CheckMate/run-pester-tests.yml?branch=main)
[![codecov](https://codecov.io/gh/renao/CheckMate/branch/main/graph/badge.svg)](https://codecov.io/gh/renao/CheckMate)

# CheckMate

CheckMate is a simplistic approach to run a wide variety of checks in my daily business.

It was originally created to run those checks on a big number (200+) of repositories in their CI pipelines.

## Operating principle

CheckMate needs a `checks/` directory right aside the `CheckMate.ps1` script.
Every `ps1` file inside this directory will be executed by CheckMate.

Therefor CheckMate hands over the base path of the test object, examplewise the root folder of a git repository.

On the other hand CheckMate expects the script to return some kind of useful message and an exit code the level of success. Like in every pipeline tool I know the exit code `0` indicates a succesful check, every other exit code has to be examined.

This repository contains some example-wise checks, so perhaps it is easier for you to adapt by adapting checks by that code.

---

## Prerequisites

CheckMate is created to be simplistic by itself - nevertheless it gives you the possibilties to extend it with complex checks yourself.

So CheckMate only needs to be run in a **PowerShell Core 7+**.

---

## Usage

You can run `CheckMate.ps1` without adding any additional parameter:

```powershell
./CheckMate.ps1
```

CheckMate will fall back to its current directory a test object and generate a report file by itself.

You can change this by using the corresponding parameters:

```powershell
./CheckMate.ps1 -repoPath "." -ReportPath "CheckResults.md"
```

## License

CheckMate is licensed under the [MIT License](LICENSE).