#include <iostream>
#include <fstream>
#include "nlohmann/json.hpp"
#include "i18n.h"

using json = nlohmann::json;

int main(int argc, char *argv[])
{
    setlocale(LC_ALL, "");
    textdomain(GETTEXT_DOMAIN.toStdString().c_str());

    std::ifstream f1(argv[1]);
    std::ofstream f2(argv[2]);
    json jf1 = json::parse(f1);
    json jf2;

    std::string mtype = jf1["message"]["type"].get<std::string>();
    bool popup = (jf1["message"]["devices"][0]["tweaks"]["sound"].get<std::string>() != "");
    int unread_count = jf1["message"]["counts"]["unread"];
    if (mtype == "m.room.message")
    {
        jf2["notification"]["card"]["summary"] = (jf1["message"]["room_name"] != nullptr) ? jf1["message"]["room_name"] : jf1["message"]["sender_display_name"];
        jf2["notification"]["card"]["body"] = jf1["message"]["sender_display_name"].get<std::string>() + ": " + jf1["message"]["content"]["body"].get<std::string>();
        jf2["notification"]["card"]["icon"] = "contact-group";
    }
    if (mtype == "m.room.encrypted")
    {
        jf2["notification"]["card"]["summary"] = (jf1["message"]["room_name"] != nullptr) ? jf1["message"]["room_name"] : jf1["message"]["sender_display_name"];
        jf2["notification"]["card"]["body"] = N_("New message");
    }
    if (popup)
    {

        jf2["notification"]["vibrate"] = true;
        jf2["notification"]["sound"] = true;
        jf2["notification"]["card"]["persist"] = true;
        jf2["notification"]["card"]["popup"] = true;
        jf2["notification"]["card"]["icon"] = "contact-group";
        jf2["notification"]["card"]["actions"] = {"cinny:\/\/" + jf1["message"]["room_id"].get<std::string>()};
    }
    jf2["notification"]["emblem-counter"]["count"] = unread_count;
    jf2["notification"]["emblem-counter"]["visible"] = (unread_count > 0);

    f2 << jf2;
    return 0;
}
