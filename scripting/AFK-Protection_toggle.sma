/*  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
*                                                                                       *
*   Plugin: "AFK Protection: Toggle"                                                    *
*                                                                                       *
*   Official plugin support: https://dev-cs.ru/threads/10726/                           *
*   Official repository: https://github.com/Nord1cWarr1or/AFK-Protection-Toggle         *
*                                                                                       *
*   Contacts of the author: Telegram: @NordicWarrior                                    *
*                                                                                       *
*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
*                                                                                       *
*   Плагин: "Защита АФК: Переключение"                                                  *
*                                                                                       *
*   Официальная поддержка плагина: https://dev-cs.ru/threads/10726/                     *
*   Официальный репозиторий: https://github.com/Nord1cWarr1or/AFK-Protection-Toggle     *
*                                                                                       *
*   Связь с автором: Telegram: @NordicWarrior                                           *
*                                                                                       *
*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */

#include <amxmodx>
#include <nvault>
#include <afk_protection>

new const PLUGIN_VERSION[] = "1.0.0";

const NVAULT_PRUNE_DAYS = 14;       // How many days before a player's state will be removed from vault

new const VAULT_NAME[] = "AFK-Protection";

new g_iVaultHandle = INVALID_HANDLE;

public plugin_init()
{
    register_plugin("AFK Protection: Toggle", PLUGIN_VERSION, "Nordic Warrior");

    register_clcmd("say /afk", "cmdToggleAFK");

    g_iVaultHandle = nvault_open(VAULT_NAME);

    if(g_iVaultHandle != INVALID_HANDLE)
    {
        nvault_prune(g_iVaultHandle, 0, get_systime() - 86400 * NVAULT_PRUNE_DAYS);
    }

    register_dictionary("afk_protection_addon.txt");
}

public cmdToggleAFK(const id)
{
    new bool:bCurrentState = apr_get_player_status(id);

    new szAuthID[MAX_AUTHID_LENGTH];
    get_user_authid(id, szAuthID, charsmax(szAuthID));

    if(bCurrentState)
    {
        apr_set_player_status(id, false);

        if(g_iVaultHandle != INVALID_HANDLE)
        {
            nvault_remove(g_iVaultHandle, szAuthID);
        }
        client_print_color(id, print_team_blue, "%l", "AFKPROTECTION_ADDON_CHAT_STATE_OFF");
    }
    else
    {
        apr_set_player_status(id, true);

        if(g_iVaultHandle != INVALID_HANDLE)
        {
            nvault_set(g_iVaultHandle, szAuthID, "1");
        }
        client_print_color(id, print_team_red, "%l", "AFKPROTECTION_ADDON_CHAT_STATE_ON");  
    }

    return PLUGIN_HANDLED;
}

public client_authorized(id, const szAuthID[])
{
    if(g_iVaultHandle == INVALID_HANDLE)
        return;
    
    if(nvault_get(g_iVaultHandle, szAuthID))
    {
        apr_set_player_status(id, true);
        nvault_touch(g_iVaultHandle, szAuthID);
    }
}

public OnConfigsExecuted()
{
    register_cvar("AFKProtection_Toggle_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED);
}

public plugin_end()
{
    if(g_iVaultHandle != INVALID_HANDLE)
    {
        nvault_close(g_iVaultHandle);
    }
}