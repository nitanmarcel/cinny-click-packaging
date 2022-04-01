/*
 * Copyright (C) 2022  Marcel Alexandru Nitan
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * cinny is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QString>
#include <QByteArray>

#include "backend.h"

Backend::Backend() {

}

QString Backend::getIndexPath() {
    QDir applicationCwd = QDir::currentPath();
    QDir targetPath = QDir::cleanPath(applicationCwd.path() + QDir::separator() + QString("target"));
    return QString("file://") + targetPath.filePath("index.html");
}

void Backend::removeDownload(QString path) {
    QFile file(path.replace(QString("file://"), QString("")));
    if (file.exists()) {
        file.remove();
    }
}

QString Backend::saveBase64File(QString fileBase64, QString fileName) {
    QString path("/home/phablet/.cache/cinny.nitanmarcel" + QString(QDir::separator()) + fileName);
    QFile file(path);
    file.open(QIODevice::WriteOnly);
    file.write(QByteArray::fromBase64(fileBase64.toLocal8Bit()));
    file.close();
    return path;
}
