## Installation
Clone this repository, and add the following lines to your .zshrc/.bashrc file, with the paths being adjusted to match where this repository was cloned.

```
source $HOME/code/scripts/shell_includes/.env
for f in $HOME/code/scripts/shell_includes/*.sh; do source $f; done
```

## Configuration
Some scripts require API keys, these should be placed in the `.env` file. An example `.env` file can be found in `env.example`.

Once modified, run the following command
``` 
cp env.example .env
```
