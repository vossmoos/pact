import pytest

from pact_mcp.settings import Settings, SettingsError, agent_env_name


def test_sources_and_agents_from_env():
    settings = Settings.from_env(
        {
            "PACT_SOURCE__FRESHDESK__DOMAIN": "acme.freshdesk.com",
            "PACT_SOURCE__FRESHDESK__API_KEY": "k",
            "PACT_SOURCE__SUPPORT_EU__TYPE": "freshdesk",
            "PACT_SOURCE__SUPPORT_EU__DOMAIN": "acme-eu.freshdesk.com",
            "PACT_AGENT__SUPPORT_BOT__KEY": "x" * 32,
        }
    )
    by_name = {s.name: s for s in settings.sources}
    assert by_name["freshdesk"].type == "freshdesk"
    assert by_name["support_eu"].type == "freshdesk"
    assert by_name["support_eu"].values == {"domain": "acme-eu.freshdesk.com"}
    assert settings.agent_keys == {"SUPPORT_BOT": "x" * 32}
    assert agent_env_name("support-bot") == "SUPPORT_BOT"


@pytest.mark.parametrize(
    "env",
    [
        {"PACT_AGENT__BOT__KEY": "short"},
        {"PACT_AGENT__A__KEY": "x" * 20, "PACT_AGENT__B__KEY": "x" * 20},
        {"PACT_AGENT__BOT__TOKEN": "x" * 20},
        {"PACT_OIDC__ISSUER": "https://idp.example.com"},
        {"PACT_SOURCE__FRESHDESK": "x"},
    ],
)
def test_invalid_env_is_rejected(env):
    with pytest.raises(SettingsError):
        Settings.from_env(env)
