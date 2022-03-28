#include <iostream>
#include <fstream>
#include "nlohmann/json.hpp"

using json = nlohmann::json;

int main(int argc, char *argv[])
{
    std::ifstream f1(argv[1]);
    std::ofstream f2(argv[2]);

    json jf1 = json::parse(f1);
    json jf2;

    if (jf2["notification"]["card"]["body"] != "")
    {
        jf2["notification"]["card"]["actions"] = {"cinny://" + jf1["message"]["room_id"].get<std::string>()};
        jf2["notification"]["card"]["summary"] = jf1["message"]["room_name"];
        jf2["notification"]["card"]["body"] = jf1["message"]["content"]["body"];
        jf2["notification"]["card"]["icon"] = "contact-group";
        jf2["notification"]["card"]["persist"] = true;
        jf2["notification"]["card"]["popup"] = true;

        jf2["notification"]["emblem-counter"]["count"] = jf1["message"]["counts"]["unread"];
        jf2["notification"]["emblem-counter"]["visible"] = true;

        jf2["notification"]["vibrate"] = true;
        jf2["notification"]["sound"] = true;

        f2 << jf2;
    }
    return 0;
}
