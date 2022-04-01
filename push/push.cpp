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
    json js1 = json::parse(f1);
    json js2;

    std::string mtype = js1["message"]["type"].get<std::string>();
    std::string summary = "";
    std::string body = "";
    std::string icon = "";

    int unread_count = 0;
    bool alert = false;
    bool popup = false;

    if (js1["message"]["room_name"] != nullptr)
    {
        summary = js1["message"]["room_name"];
    }
    else
    {
        summary = js1["message"]["sender_display_name"];
    }
    if (mtype == "m.room.encrypted") {
        body = N_("New Message");
    }
    else {
        body = js1["message"]["sender_display_name"].get<std::string>() + ": " + js1["message"]["content"]["body"].get<std::string>();
    }

    if (js1["message"]["room_name"] == nullptr) {
        icon = "contact";
    }
    else {
        icon = "contact-group";
    }

    if (js1["message"]["devices"][0]["tweaks"]["sound"].get<std::string>() != "") {
        alert = true;
    }

    if(summary != "" && body != ""){
        popup = true;
    }

    unread_count = js1["message"]["counts"]["unread"];

    js2["notification"]["card"]["actions"] = {"cinny://" + js1["message"]["room_id"].get<std::string>()};
    js2["notification"]["card"]["summary"] = summary;
    js2["notification"]["card"]["body"] = body;
    js2["notification"]["card"]["icon"] = icon;
    js2["notification"]["card"]["persist"] = popup;
    js2["notification"]["card"]["popup"] = popup;

    js2["notification"]["emblem-counter"]["count"] = unread_count;
    js2["notification"]["emblem-counter"]["visible"] = unread_count > 0;

    js2["notification"]["sound"] = alert;
    js2["notification"]["vibrate"] = alert;
    f2 << js2;

    return 0;
}
