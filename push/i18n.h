#pragma once

#include <libintl.h>

#include <QString>

const QString GETTEXT_DOMAIN = "cinny.nitanmarcel";

#define _(value) gettext(value)
#define N_(value) gettext(value)
