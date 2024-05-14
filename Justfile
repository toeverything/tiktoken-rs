set positional-arguments
set dotenv-load := true

help:
    @just --list --unsorted

clean:
    cargo clean

build:
    cargo build
alias b := build

run *args:
    cargo run -- "$@"
alias r := run

release:
    cargo build --release

install:
    cargo install --path .

test *args:
    cargo test --features async-openai --features dhat-heap {{args}}
alias t := test

bench *args:
    cargo +nightly bench {{args}}

lint:
    cargo +nightly fmt --all -- --check
    cargo +nightly clippy --all-features --all-targets -- -D warnings --allow deprecated

fix:
    cargo +nightly fix --allow-dirty --allow-staged
    cargo +nightly clippy --all-features --all-targets --fix --allow-dirty --allow-staged -- -D warnings --allow deprecated
    cargo +nightly fmt --all
alias f := fix


# Bump version. level=major,minor,patch
version level:
    git diff-index --exit-code HEAD > /dev/null || ! echo You have untracked changes. Commit your changes before bumping the version.
    cargo set-version --bump {{level}}
    cargo update # This bumps Cargo.lock
    VERSION=$(toml get tiktoken-rs/Cargo.toml package.version) && \
        git commit -am "Bump version {{level}} to $VERSION" && \
        git push origin HEAD
    git push

release-patch: lint build test
    just version patch

release-minor: lint build test
    just version minor

release-major: lint build test
    just version major
