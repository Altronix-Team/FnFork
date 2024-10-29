# FnFork (FNF Fork)

Friday Night Funkin' fork creation tool inspired by [PaperMC paperweight](https://github.com/PaperMC/paperweight).

## How to use?

1. Create `fnfork.properties` file. For now, this like contains this required fields
```
{
    "codeRepoURL": "https://github.com/FunkinCrew/Funkin.git",
    "codeCommitHash": "c0b15ec066940fcb8cb8acbd76a1ba7f1ba1c1a7",
    "dirForCode": "source"
}
```

2. Next run:
    - `./FnFork.exe applyPatches`  on Windows to clone FNF and apply patches from `patches` dir
    - `./FnFork applyPatches`  on Linux to clone FNF and apply patches from `patches` dir

3. If you made commits in your code and want to save them, run:
    - `./FnFork.exe rebuildPatches`  on Windows to save your patches to `patches` dir
    - `./FnFork rebuildPatches`  on Linux to save your patches to `patches` dir


## Credits
- AltronMaxX - Main programmer
