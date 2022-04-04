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

#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QObject>
#include <QQuickView>
#include <QtQuickControls2/QQuickStyle>

#include "qhttpserver.hpp"
#include "qhttpserverconnection.hpp"
#include "qhttpserverrequest.hpp"
#include "qhttpserverresponse.hpp"

#include <map>
#include <stdlib.h>

std::map<std::string, std::string> mimes;

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QGuiApplication *app = new QGuiApplication(argc, (char **)argv);
    QQuickStyle::setStyle("Suru");
    app->setApplicationName("cinny.nitanmarcel");

    mimes[".html"] = "text/html";
    mimes[".css"] = "text/css";
    mimes[".js"] = "application/javascript";
    mimes[".wasm"] = "application/wasm";
    mimes[".woff2"] = "application/font-woff2";
    mimes[".png"] = "image/png";
    mimes[".icon"] = "image/x-icon";

    qhttp::server::QHttpServer server;
    server.listen(QHostAddress::LocalHost, 19999,
                  [](qhttp::server::QHttpRequest *req, qhttp::server::QHttpResponse *res)
                  {
                      QString docname = "./target/" + (req->url().toString()==("/") ?("/index.html"):req->url().toString());
                      if (!QFile(docname).exists())
                          docname = QString("./target/index.html");
                      QFile doc(docname);
                      doc.open(QFile::ReadOnly);

                      res->addHeader("Content-Length", QString::number(doc.size()).toUtf8());
                      res->addHeader("Connection", "keep-alive");

                      auto doc_str = docname.toStdString();
                      auto doc_ext = doc_str.substr(doc_str.find_last_of('.'));
                      if (mimes.count(doc_ext) > 0)
                          res->addHeader("Content-Type", mimes[doc_ext].data());
                      else
                          res->addHeader("Content-Type", "application/octet-stream");
                      res->setStatusCode(qhttp::TStatusCode::ESTATUS_OK);
                      res->end(doc.readAll());
                  });

    QQuickView *view = new QQuickView();
    view->setSource(QUrl("qrc:/Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();
    return app->exec();
}
