from __future__ import annotations

import shutil
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "examples" / "connectors"))

AGENT_KEY = "test-default-key-0123456789"
READER_KEY = "test-reader-key-0123456789"
ORPHAN_KEY = "test-orphan-key-0123456789"

BASE_ENV = {
    "PACT_SOURCE__ZENDESK__DOMAIN": "acme.zendesk.com",
    "PACT_SOURCE__ZENDESK__API_KEY": "fd-key",
    "PACT_SOURCE__JIRA__SITE": "acme.atlassian.net",
    "PACT_SOURCE__JIRA__EMAIL": "bot@acme.test",
    "PACT_SOURCE__JIRA__API_TOKEN": "jira-token",
    "PACT_SOURCE__JIRA__PROJECTS": "OPS",
    "PACT_SOURCE__WRIKE__TOKEN": "wrike-token",
    "PACT_AGENT__DEFAULT__KEY": AGENT_KEY,
    "PACT_RELOAD_SECONDS": "0",
}


@pytest.fixture
def config_dir(tmp_path: Path) -> Path:
    """A writable copy of the repository's example config folder."""
    target = tmp_path / "config"
    shutil.copytree(ROOT / "config", target)
    return target


@pytest.fixture
def env(config_dir: Path) -> dict[str, str]:
    return {**BASE_ENV, "PACT_CONFIG_DIR": str(config_dir)}
