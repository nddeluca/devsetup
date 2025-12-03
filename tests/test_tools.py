import pytest


def test_ansible_installed_via_uv(host):
    """
    Test ansible is runnable via UV
    """
    cmd = host.run("uv run ansible --version")
    assert cmd.rc == 0, "ansible must be runnable via uv"
    assert "ansible" in cmd.stdout.lower()


@pytest.mark.parametrize("tool", ["tofu", "terragrunt"])
def test_mise_tools_installed(host, tool):
    """
    Test mise tools are executable
    """
    cmd = host.run(f"mise exec -- {tool} --version")
    assert cmd.rc == 0, f"{tool} must be available via mise"
    assert tool in cmd.stdout.lower()


def test_ansible_galaxy_callable_via_uv(host):
    """
    Also confirm ansible-galaxy itself is invokable through uv.
    This mirrors your install command.
    """
    cmd = host.run("uv run ansible-galaxy --version")
    assert cmd.rc == 0
    assert "ansible-galaxy" in cmd.stdout.lower()


def test_local_collections_dir_exists(host):
    """
    Ensures that collections are installed into the project-local path,
    not just somewhere global on the system.
    """
    local_collections_dir = ".ansible/collections/ansible_collections"

    collections_dir = host.file(local_collections_dir)
    assert collections_dir.exists, f"{local_collections_dir} should exist"
    assert collections_dir.is_directory, f"{local_collections_dir} must be a directory"


def test_ansible_cfg_exists(host):
    cfg = host.file("ansible.cfg")
    assert cfg.exists, "ansible.cfg should exist at the project root"
    assert cfg.is_file, "ansible.cfg must be a regular file"


def test_ansible_cfg_defaults_section(host):
    """
    Make sure our core defaults are present in the config file itself.
    """
    cfg = host.file("ansible.cfg").content_string

    assert "[defaults]" in cfg
    assert "collections_path = .ansible/collections" in cfg
    assert "roles_path = roles" in cfg
