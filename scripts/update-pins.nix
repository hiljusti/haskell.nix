{ stdenv, writeScript, coreutils, glibc, git, openssh }@args:

with stdenv.lib;

let
  repo = "git@github.com:input-output-hk/haskell.nix.git";
  sshKey = "/run/keys/buildkite-haskell-nix-ssh-private";
in
  writeScript "update-pins.sh" ''
    #!${stdenv.shell}

    set -euo pipefail

    export PATH="${makeBinPath [ coreutils glibc git openssh ]}"

    source ${./git.env}

    git add *.json
    check_staged
    echo "Committing changes..."
    git commit --message "Update Hackage and Stackage"

    use_ssh_key ${sshKey}

    git push ${repo}
  ''
