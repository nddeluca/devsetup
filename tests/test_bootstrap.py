# tests/test_bootstrap.py
import platform
import pytest

"""
These bootstrap tests ensure the system is in a state
to run `make install-deps`.
"""


@pytest.mark.parametrize("tool", ["uv", "mise"])
def test_local_tools_are_installed(host, tool):
    """
    These test for the presence of locally installed tools
    under the current users home directory.

    uv, mise must be installed to ~/.local/bin
    """
    home = host.check_output("echo $HOME")
    path = f"{home}/.local/bin/{tool}"

    f = host.file(path)
    assert f.exists, f"{tool}: {path} does not exist"
    assert f.is_file, f"{tool}: {path} is not a regular file"
    assert f.mode & 0o111, f"{tool}: {path} is not executable"

    cmd = host.run(f"{path} --version")
    assert cmd.succeeded, f"{tool}: failed to run --version: {cmd.stderr}"


@pytest.mark.parametrize("binary", ["make", "git", "sudo"])
def test_binaries_available(host, binary):
    """
    The programs make, git, and sudo must exist
    """
    cmd = host.run(f"command -v {binary}")
    assert cmd.succeeded, f"{binary} is not on PATH"

    version = host.run(f"{binary} --version")
    assert version.succeeded


def test_ssh_available(host, binary="ssh"):
    """
    SSH client must be available
    """
    cmd = host.run(f"command -v {binary}")
    assert cmd.succeeded, f"{binary} is not on PATH"


def test_homebrew_if_macos(host):
    """
    If macOS -- homebrew must be installed
    """
    if platform.system() != "Darwin":
        pytest.skip("Homebrew test is macOS-only")

    # Try both default brew locations
    brew_paths = [
        "/opt/homebrew/bin/brew",  # Apple Silicon
        "/usr/local/bin/brew",  # Intel
    ]

    brew = next((p for p in brew_paths if host.file(p).exists), None)

    # Fallback to PATH if user previously installed brew
    if brew is None:
        cmd = host.run("command -v brew")
        if cmd.succeeded:
            brew = cmd.stdout.strip()

    assert brew, "brew not found"

    cmd = host.run(f"{brew} --version")
    assert cmd.succeeded
    assert "homebrew" in cmd.stdout.lower()
