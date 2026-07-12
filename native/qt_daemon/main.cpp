#include <QApplication>
#include <QMainWindow>
#include <QPushButton>
#include <QLabel>
#include <QLineEdit>
#include <QComboBox>
#include <QCheckBox>
#include <QRadioButton>
#include <QSlider>
#include <QSpinBox>
#include <QProgressBar>
#include <QProgressDialog>
#include <QTabWidget>
#include <QGroupBox>
#include <QTreeWidget>
#include <QPlainTextEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QFormLayout>
#include <QSplitter>
#include <QWidget>
#include <QTimer>
#include <QButtonGroup>
#include <QMessageBox>
#include <QFileDialog>
#include <QColorDialog>
#include <QFontDialog>
#include <QInputDialog>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include <QToolBar>
#include <QStatusBar>
#include <QTableWidget>
#include <QHeaderView>
#include <QFont>
#include <QKeyEvent>
#include <QMouseEvent>
#include <QCloseEvent>
#include <QCursor>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QThread>
#include <iostream>
#include <unordered_map>
#include <cstring>
#include <string>
#include <QDockWidget>
#include <QTextBrowser>
#include <QDoubleSpinBox>
#include <QDateTimeEdit>
#include <QLCDNumber>
#include <QCalendarWidget>
#include <QDial>
#include <QStackedWidget>

QApplication* g_app = nullptr;
std::unordered_map<int, QWidget*> g_widgets;
std::unordered_map<int, QLayout*> g_layouts;
std::unordered_map<int, QTimer*> g_timers;
std::unordered_map<int, QButtonGroup*> g_groups;
std::unordered_map<int, int> g_group_button_counts;
std::unordered_map<int, QMenu*> g_menus;
std::unordered_map<int, QAction*> g_actions;
int g_next_id = 1;
bool g_running = true;

std::unordered_set<int> g_mouse_events_enabled;
std::unordered_set<int> g_key_events_enabled;
std::unordered_set<int> g_close_events_enabled;

void send_json(const QJsonObject& obj);

class EventFilter : public QObject {
    Q_OBJECT
public:
    bool eventFilter(QObject* obj, QEvent* event) override {
        QWidget* w = qobject_cast<QWidget*>(obj);
        if (!w) return false;
        int wid = -1;
        for (auto& p : g_widgets) {
            if (p.second == w) { wid = p.first; break; }
        }
        if (wid < 0) return false;

        if (event->type() == QEvent::Close && g_close_events_enabled.count(wid)) {
            auto* ce = static_cast<QCloseEvent*>(event);
            ce->ignore();
            send_json({{"event", "close"}, {"id", wid}});
            return true;
        }
        if (event->type() == QEvent::MouseButtonPress && g_mouse_events_enabled.count(wid)) {
            auto* me = static_cast<QMouseEvent*>(event);
            QString btn;
            switch (me->button()) {
                case Qt::LeftButton: btn = "left"; break;
                case Qt::RightButton: btn = "right"; break;
                case Qt::MiddleButton: btn = "middle"; break;
                default: btn = "other"; break;
            }
            send_json({{"event", "mouse_pressed"}, {"id", wid}, {"button", btn},
                       {"x", me->position().x()}, {"y", me->position().y()}});
        }
        if (event->type() == QEvent::MouseButtonDblClick && g_mouse_events_enabled.count(wid)) {
            auto* me = static_cast<QMouseEvent*>(event);
            QString btn;
            switch (me->button()) {
                case Qt::LeftButton: btn = "left"; break;
                case Qt::RightButton: btn = "right"; break;
                case Qt::MiddleButton: btn = "middle"; break;
                default: btn = "other"; break;
            }
            send_json({{"event", "mouse_double_clicked"}, {"id", wid}, {"button", btn}});
        }
        if (event->type() == QEvent::Enter && g_mouse_events_enabled.count(wid)) {
            send_json({{"event", "mouse_enter"}, {"id", wid}});
        }
        if (event->type() == QEvent::Leave && g_mouse_events_enabled.count(wid)) {
            send_json({{"event", "mouse_leave"}, {"id", wid}});
        }
        if (event->type() == QEvent::KeyPress && g_key_events_enabled.count(wid)) {
            auto* ke = static_cast<QKeyEvent*>(event);
            send_json({{"event", "key_pressed"}, {"id", wid}, {"key", ke->key()},
                       {"text", ke->text()}, {"modifiers", (int)ke->modifiers()}});
        }
        if (event->type() == QEvent::KeyRelease && g_key_events_enabled.count(wid)) {
            auto* ke = static_cast<QKeyEvent*>(event);
            send_json({{"event", "key_released"}, {"id", wid}, {"key", ke->key()},
                       {"text", ke->text()}, {"modifiers", (int)ke->modifiers()}});
        }
        return false;
    }
};

EventFilter* g_event_filter = nullptr;

void send_json(const QJsonObject& obj) {
    QJsonDocument doc(obj);
    QByteArray data = doc.toJson(QJsonDocument::Compact);
    std::cout << data.toStdString() << std::endl;
    std::cout.flush();
}

void send_event(const std::string& type, int id = 0, const std::string& text = "") {
    QJsonObject obj;
    obj["event"] = QString::fromStdString(type);
    if (id > 0) obj["id"] = id;
    if (!text.empty()) obj["text"] = QString::fromStdString(text);
    send_json(obj);
}

void send_value_event(const std::string& type, int id, int value) {
    QJsonObject obj;
    obj["event"] = QString::fromStdString(type);
    obj["id"] = id;
    obj["value"] = value;
    send_json(obj);
}

void send_checked_event(const std::string& type, int id, bool checked) {
    QJsonObject obj;
    obj["event"] = QString::fromStdString(type);
    obj["id"] = id;
    obj["checked"] = checked;
    send_json(obj);
}

void process_command(const QJsonObject& cmd) {
    QString name = cmd["name"].toString();

    if (name == "create_app") {
        static char* argv[] = {strdup("qt_daemon"), nullptr};
        static int argc = 1;
        g_app = new QApplication(argc, argv);
        send_event("app_created");
    }
    else if (name == "create_window") {
        int id = g_next_id++;
        QWidget* w = new QWidget();
        g_widgets[id] = w;
        send_event("widget_created", id);
    }
    else if (name == "create_button") {
        int id = g_next_id++;
        QString text = cmd["text"].toString();
        QPushButton* btn = new QPushButton(text);
        g_widgets[id] = btn;
        QObject::connect(btn, &QPushButton::clicked, [id]() {
            send_event("clicked", id);
        });
        send_event("widget_created", id);
    }
    else if (name == "create_label") {
        int id = g_next_id++;
        QString text = cmd["text"].toString("");
        QLabel* lbl = new QLabel(text);
        g_widgets[id] = lbl;
        send_event("widget_created", id);
    }
    else if (name == "create_lineedit") {
        int id = g_next_id++;
        QString placeholder = cmd["placeholder"].toString("");
        QLineEdit* le = new QLineEdit();
        if (!placeholder.isEmpty()) le->setPlaceholderText(placeholder);
        g_widgets[id] = le;
        QObject::connect(le, &QLineEdit::returnPressed, [id, le]() {
            send_event("return_pressed", id, le->text().toStdString());
        });
        QObject::connect(le, &QLineEdit::textChanged, [id, le]() {
            send_event("text_changed", id, le->text().toStdString());
        });
        send_event("widget_created", id);
    }
    else if (name == "create_combobox") {
        int id = g_next_id++;
        QComboBox* cb = new QComboBox();
        g_widgets[id] = cb;
        if (cmd.contains("items")) {
            QJsonArray items = cmd["items"].toArray();
            for (const auto& item : items) cb->addItem(item.toString());
        }
        QObject::connect(cb, QOverload<int>::of(&QComboBox::currentIndexChanged), [id, cb](int index) {
            send_event("index_changed", id, cb->currentText().toStdString());
            send_value_event("value_changed", id, index);
        });
        send_event("widget_created", id);
    }
    else if (name == "create_checkbox") {
        int id = g_next_id++;
        QString text = cmd["text"].toString();
        QCheckBox* cb = new QCheckBox(text);
        g_widgets[id] = cb;
        QObject::connect(cb, &QCheckBox::checkStateChanged, [id](Qt::CheckState state) {
            send_checked_event("check_changed", id, state == Qt::Checked);
        });
        send_event("widget_created", id);
    }
    else if (name == "create_radiobutton") {
        int id = g_next_id++;
        QString text = cmd["text"].toString();
        QRadioButton* rb = new QRadioButton(text);
        g_widgets[id] = rb;
        QObject::connect(rb, &QRadioButton::toggled, [id, rb](bool checked) {
            send_checked_event("toggled", id, checked);
        });
        send_event("widget_created", id);
    }
    else if (name == "create_buttongroup") {
        int id = g_next_id++;
        QButtonGroup* grp = new QButtonGroup();
        g_groups[id] = grp;
        QObject::connect(grp, QOverload<QAbstractButton*>::of(&QButtonGroup::buttonClicked),
            [id, grp](QAbstractButton* button) {
                QJsonObject obj;
                obj["event"] = "button_clicked";
                obj["group_id"] = id;
                obj["button_id"] = grp->id(button);
                send_json(obj);
            });
        send_event("widget_created", id);
    }
    else if (name == "add_to_buttongroup") {
        int group_id = cmd["group_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_groups.count(group_id) && g_widgets.count(widget_id)) {
            if (auto* rb = qobject_cast<QAbstractButton*>(g_widgets[widget_id])) {
                int btn_id = g_group_button_counts[group_id]++;
                g_groups[group_id]->addButton(rb, btn_id);
            }
        }
    }
    else if (name == "create_slider") {
        int id = g_next_id++;
        int min_val = cmd["min"].toInt(0);
        int max_val = cmd["max"].toInt(100);
        int value = cmd["value"].toInt(0);
        Qt::Orientation orient = cmd["orientation"].toString("horizontal") == "vertical"
            ? Qt::Vertical : Qt::Horizontal;
        QSlider* sl = new QSlider(orient);
        sl->setMinimum(min_val);
        sl->setMaximum(max_val);
        sl->setValue(value);
        g_widgets[id] = sl;
        QObject::connect(sl, &QSlider::valueChanged, [id](int value) {
            send_value_event("value_changed", id, value);
        });
        send_event("widget_created", id);
    }
    else if (name == "create_spinbox") {
        int id = g_next_id++;
        int min_val = cmd["min"].toInt(0);
        int max_val = cmd["max"].toInt(100);
        int value = cmd["value"].toInt(0);
        QSpinBox* sb = new QSpinBox();
        sb->setMinimum(min_val);
        sb->setMaximum(max_val);
        sb->setValue(value);
        if (cmd.contains("suffix")) sb->setSuffix(cmd["suffix"].toString());
        if (cmd.contains("prefix")) sb->setPrefix(cmd["prefix"].toString());
        if (cmd.contains("single_step")) sb->setSingleStep(cmd["single_step"].toInt(1));
        g_widgets[id] = sb;
        QObject::connect(sb, QOverload<int>::of(&QSpinBox::valueChanged), [id](int value) {
            send_value_event("value_changed", id, value);
        });
        send_event("widget_created", id);
    }
    else if (name == "create_progressbar") {
        int id = g_next_id++;
        int min_val = cmd["min"].toInt(0);
        int max_val = cmd["max"].toInt(100);
        int value = cmd["value"].toInt(0);
        QProgressBar* pb = new QProgressBar();
        pb->setMinimum(min_val);
        pb->setMaximum(max_val);
        pb->setValue(value);
        if (cmd.contains("format")) pb->setFormat(cmd["format"].toString());
        g_widgets[id] = pb;
        send_event("widget_created", id);
    }
    else if (name == "create_tabwidget") {
        int id = g_next_id++;
        QTabWidget* tw = new QTabWidget();
        g_widgets[id] = tw;
        QObject::connect(tw, &QTabWidget::currentChanged, [id, tw](int index) {
            send_value_event("current_changed", id, index);
        });
        send_event("widget_created", id);
    }
    else if (name == "add_tab") {
        int tabwidget_id = cmd["tabwidget_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        QString title = cmd["title"].toString("");
        if (g_widgets.count(tabwidget_id) && g_widgets.count(widget_id)) {
            if (auto* tw = qobject_cast<QTabWidget*>(g_widgets[tabwidget_id])) {
                tw->addTab(g_widgets[widget_id], title);
            }
        }
    }
    else if (name == "create_groupbox") {
        int id = g_next_id++;
        QString title = cmd["title"].toString("");
        QGroupBox* gb = new QGroupBox(title);
        g_widgets[id] = gb;
        send_event("widget_created", id);
    }
    else if (name == "create_textedit") {
        int id = g_next_id++;
        QPlainTextEdit* te = new QPlainTextEdit();
        if (cmd.contains("text")) te->setPlainText(cmd["text"].toString());
        g_widgets[id] = te;
        QObject::connect(te, &QPlainTextEdit::textChanged, [id, te]() {
            send_event("text_changed", id, te->toPlainText().toStdString());
        });
        send_event("widget_created", id);
    }
    else if (name == "create_dockwidget") {
        int id = g_next_id++;
        QDockWidget* dw = new QDockWidget(cmd.value("title").toString("Dock"));
        g_widgets[id] = dw;
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_textbrowser") {
        int id = g_next_id++;
        QTextBrowser* tb = new QTextBrowser();
        if (cmd.contains("text")) tb->setHtml(cmd["text"].toString());
        g_widgets[id] = tb;
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_doublespinbox") {
        int id = g_next_id++;
        QDoubleSpinBox* sb = new QDoubleSpinBox();
        sb->setMinimum(cmd.value("min").toDouble(0.0));
        sb->setMaximum(cmd.value("max").toDouble(100.0));
        sb->setSingleStep(cmd.value("step").toDouble(0.1));
        sb->setDecimals(cmd.value("decimals").toInt(2));
        sb->setValue(cmd.value("value").toDouble(0.0));
        if (cmd.contains("prefix")) sb->setPrefix(cmd["prefix"].toString());
        if (cmd.contains("suffix")) sb->setSuffix(cmd["suffix"].toString());
        g_widgets[id] = sb;
        QObject::connect(sb, QOverload<double>::of(&QDoubleSpinBox::valueChanged), [id](double val) {
            QJsonObject r; r["event"] = "value_changed"; r["id"] = id; r["value"] = val; send_json(r);
        });
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_datetimeedit") {
        int id = g_next_id++;
        QDateTimeEdit* dte = new QDateTimeEdit();
        dte->setCalendarPopup(cmd.value("calendar_popup").toBool(true));
        if (cmd.contains("format")) dte->setDisplayFormat(cmd["format"].toString("yyyy-MM-dd HH:mm:ss"));
        if (cmd.contains("datetime")) dte->setDateTime(QDateTime::fromString(cmd["datetime"].toString(), "yyyy-MM-dd HH:mm:ss"));
        g_widgets[id] = dte;
        QObject::connect(dte, &QDateTimeEdit::dateTimeChanged, [id](const QDateTime& dt) {
            QJsonObject r; r["event"] = "value_changed"; r["id"] = id; r["value"] = dt.toString("yyyy-MM-dd HH:mm:ss"); send_json(r);
        });
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_qlcdnumber") {
        int id = g_next_id++;
        QLCDNumber* lcd = new QLCDNumber();
        QString mode = cmd.value("mode").toString("dec");
        if (mode == "hex") lcd->setDigitCount(8);
        else if (mode == "bin") lcd->setDigitCount(16);
        else if (mode == "oct") lcd->setDigitCount(8);
        else lcd->setDigitCount(10);
        if (cmd.contains("value")) lcd->display(cmd["value"].toDouble(0.0));
        g_widgets[id] = lcd;
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_calendarwidget") {
        int id = g_next_id++;
        QCalendarWidget* cw = new QCalendarWidget();
        if (cmd.contains("date")) cw->setSelectedDate(QDate::fromString(cmd["date"].toString(), "yyyy-MM-dd"));
        QObject::connect(cw, &QCalendarWidget::clicked, [id](const QDate& date) {
            QJsonObject r; r["event"] = "value_changed"; r["id"] = id; r["value"] = date.toString("yyyy-MM-dd"); send_json(r);
        });
        g_widgets[id] = cw;
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_dial") {
        int id = g_next_id++;
        QDial* dial = new QDial();
        dial->setMinimum(cmd.value("min").toInt(0));
        dial->setMaximum(cmd.value("max").toInt(100));
        dial->setValue(cmd.value("value").toInt(0));
        dial->setNotchesVisible(cmd.value("notches").toBool(true));
        dial->setWrapping(cmd.value("wrapping").toBool(false));
        g_widgets[id] = dial;
        QObject::connect(dial, &QDial::valueChanged, [id](int val) {
            QJsonObject r; r["event"] = "value_changed"; r["id"] = id; r["value"] = val; send_json(r);
        });
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_stackedwidget") {
        int id = g_next_id++;
        QStackedWidget* sw = new QStackedWidget();
        g_widgets[id] = sw;
        QJsonObject r; r["event"] = "widget_created"; r["id"] = id; send_json(r);
    }
    else if (name == "create_vbox") {
        int id = g_next_id++;
        g_layouts[id] = new QVBoxLayout();
        send_event("layout_created", id);
    }
    else if (name == "create_hbox") {
        int id = g_next_id++;
        g_layouts[id] = new QHBoxLayout();
        send_event("layout_created", id);
    }
    else if (name == "set_layout") {
        int widget_id = cmd["widget_id"].toInt();
        int layout_id = cmd["layout_id"].toInt();
        if (g_widgets.count(widget_id) && g_layouts.count(layout_id)) {
            g_widgets[widget_id]->setLayout(g_layouts[layout_id]);
        }
    }
    else if (name == "add_widget") {
        int layout_id = cmd["layout_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_layouts.count(layout_id) && g_widgets.count(widget_id)) {
            g_layouts[layout_id]->addWidget(g_widgets[widget_id]);
        }
    }
    else if (name == "add_layout") {
        int parent_id = cmd["layout_id"].toInt();
        int child_id = cmd["child_layout_id"].toInt();
        if (g_layouts.count(parent_id) && g_layouts.count(child_id)) {
            if (auto* box = qobject_cast<QBoxLayout*>(g_layouts[parent_id])) {
                box->addLayout(g_layouts[child_id]);
            }
        }
    }
    else if (name == "set_text") {
        int id = cmd["id"].toInt();
        QString text = cmd["text"].toString();
        if (g_widgets.count(id)) {
            if (auto* btn = qobject_cast<QPushButton*>(g_widgets[id])) btn->setText(text);
            else if (auto* lbl = qobject_cast<QLabel*>(g_widgets[id])) lbl->setText(text);
            else if (auto* le = qobject_cast<QLineEdit*>(g_widgets[id])) le->setText(text);
            else if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->setPlainText(text);
        }
    }
    else if (name == "get_text") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            std::string text;
            if (auto* btn = qobject_cast<QPushButton*>(g_widgets[id])) text = btn->text().toStdString();
            else if (auto* lbl = qobject_cast<QLabel*>(g_widgets[id])) text = lbl->text().toStdString();
            else if (auto* le = qobject_cast<QLineEdit*>(g_widgets[id])) text = le->text().toStdString();
            else if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) text = te->toPlainText().toStdString();
            QJsonObject obj;
            obj["event"] = "text_result";
            obj["id"] = id;
            obj["text"] = QString::fromStdString(text);
            send_json(obj);
        }
    }
    else if (name == "set_value") {
        int id = cmd["id"].toInt();
        int value = cmd["value"].toInt();
        if (g_widgets.count(id)) {
            if (auto* sl = qobject_cast<QSlider*>(g_widgets[id])) sl->setValue(value);
            else if (auto* cb = qobject_cast<QComboBox*>(g_widgets[id])) cb->setCurrentIndex(value);
            else if (auto* sb = qobject_cast<QSpinBox*>(g_widgets[id])) sb->setValue(value);
            else if (auto* pb = qobject_cast<QProgressBar*>(g_widgets[id])) pb->setValue(value);
        }
    }
    else if (name == "get_value") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            int value = 0;
            if (auto* sl = qobject_cast<QSlider*>(g_widgets[id])) value = sl->value();
            else if (auto* cb = qobject_cast<QComboBox*>(g_widgets[id])) value = cb->currentIndex();
            else if (auto* sb = qobject_cast<QSpinBox*>(g_widgets[id])) value = sb->value();
            else if (auto* pb = qobject_cast<QProgressBar*>(g_widgets[id])) value = pb->value();
            send_value_event("value_result", id, value);
        }
    }
    else if (name == "set_checked") {
        int id = cmd["id"].toInt();
        bool checked = cmd["checked"].toBool();
        if (g_widgets.count(id)) {
            if (auto* cb = qobject_cast<QCheckBox*>(g_widgets[id])) cb->setChecked(checked);
            else if (auto* rb = qobject_cast<QRadioButton*>(g_widgets[id])) rb->setChecked(checked);
        }
    }
    else if (name == "get_checked") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            bool checked = false;
            if (auto* cb = qobject_cast<QCheckBox*>(g_widgets[id])) checked = cb->isChecked();
            else if (auto* rb = qobject_cast<QRadioButton*>(g_widgets[id])) checked = rb->isChecked();
            send_checked_event("checked_result", id, checked);
        }
    }
    else if (name == "add_items") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* cb = qobject_cast<QComboBox*>(g_widgets[id])) {
                QJsonArray items = cmd["items"].toArray();
                for (const auto& item : items) cb->addItem(item.toString());
            }
        }
    }
    else if (name == "set_tab_text") {
        int id = cmd["id"].toInt();
        int index = cmd["index"].toInt();
        QString text = cmd["text"].toString();
        if (g_widgets.count(id)) {
            if (auto* tw = qobject_cast<QTabWidget*>(g_widgets[id])) {
                tw->setTabText(index, text);
            }
        }
    }
    else if (name == "set_current_index") {
        int id = cmd["id"].toInt();
        int index = cmd["index"].toInt();
        if (g_widgets.count(id)) {
            if (auto* tw = qobject_cast<QTabWidget*>(g_widgets[id])) tw->setCurrentIndex(index);
            else if (auto* cb = qobject_cast<QComboBox*>(g_widgets[id])) cb->setCurrentIndex(index);
        }
    }
    else if (name == "add_tree_item") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* tw = qobject_cast<QTreeWidget*>(g_widgets[id])) {
                QTreeWidgetItem* item = new QTreeWidgetItem(tw);
                if (cmd.contains("text")) item->setText(0, cmd["text"].toString());
                if (cmd.contains("icon")) item->setIcon(0, QIcon(cmd["icon"].toString()));
                if (cmd.contains("children")) {
                    QJsonArray children = cmd["children"].toArray();
                    for (const auto& child : children) {
                        QTreeWidgetItem* child_item = new QTreeWidgetItem(item);
                        child_item->setText(0, child.toString());
                    }
                }
            }
        }
    }
    else if (name == "add_tree_header") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* tw = qobject_cast<QTreeWidget*>(g_widgets[id])) {
                QStringList headers;
                QJsonArray arr = cmd["headers"].toArray();
                for (const auto& h : arr) headers << h.toString();
                tw->setHeaderLabels(headers);
            }
        }
    }
    else if (name == "set_tree_item_text") {
        int id = cmd["id"].toInt();
        int row = cmd["row"].toInt();
        int col = cmd["column"].toInt(0);
        QString text = cmd["text"].toString();
        if (g_widgets.count(id)) {
            if (auto* tw = qobject_cast<QTreeWidget*>(g_widgets[id])) {
                QTreeWidgetItem* item = tw->topLevelItem(row);
                if (item) item->setText(col, text);
            }
        }
    }
    else if (name == "create_tree") {
        int id = g_next_id++;
        QTreeWidget* tw = new QTreeWidget();
        g_widgets[id] = tw;
        QObject::connect(tw, &QTreeWidget::itemClicked, [id, tw](QTreeWidgetItem* item, int column) {
            int row = tw->indexOfTopLevelItem(item);
            send_value_event("item_clicked", id, row);
        });
        QObject::connect(tw, &QTreeWidget::itemDoubleClicked, [id, tw](QTreeWidgetItem* item, int column) {
            int row = tw->indexOfTopLevelItem(item);
            send_value_event("item_double_clicked", id, row);
        });
        send_event("widget_created", id);
    }
    else if (name == "show") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) g_widgets[id]->show();
    }
    else if (name == "set_title") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id))
            g_widgets[id]->setWindowTitle(cmd["title"].toString());
    }
    else if (name == "resize") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id))
            g_widgets[id]->resize(cmd["w"].toInt(), cmd["h"].toInt());
    }
    else if (name == "create_timer") {
        int id = g_next_id++;
        int interval_ms = cmd["interval"].toInt(1000);
        QTimer* timer = new QTimer();
        timer->setInterval(interval_ms);
        g_timers[id] = timer;
        QObject::connect(timer, &QTimer::timeout, [id]() {
            send_event("timer_tick", id);
        });
        send_event("widget_created", id);
    }
    else if (name == "start_timer") {
        int id = cmd["id"].toInt();
        if (g_timers.count(id)) g_timers[id]->start();
    }
    else if (name == "stop_timer") {
        int id = cmd["id"].toInt();
        if (g_timers.count(id)) g_timers[id]->stop();
    }
    else if (name == "set_timer_interval") {
        int id = cmd["id"].toInt();
        int interval_ms = cmd["interval"].toInt(1000);
        if (g_timers.count(id)) g_timers[id]->setInterval(interval_ms);
    }
    else if (name == "create_grid") {
        int id = g_next_id++;
        int rows = cmd["rows"].toInt(1);
        int cols = cmd["columns"].toInt(1);
        QGridLayout* gl = new QGridLayout();
        gl->setContentsMargins(cmd["margin"].toInt(5), cmd["margin"].toInt(5),
                               cmd["margin"].toInt(5), cmd["margin"].toInt(5));
        gl->setSpacing(cmd["spacing"].toInt(5));
        g_layouts[id] = gl;
        send_event("layout_created", id);
    }
    else if (name == "grid_add_widget") {
        int layout_id = cmd["layout_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        int row = cmd["row"].toInt();
        int col = cmd["column"].toInt();
        int row_span = cmd["row_span"].toInt(1);
        int col_span = cmd["col_span"].toInt(1);
        if (g_layouts.count(layout_id) && g_widgets.count(widget_id)) {
            if (auto* gl = qobject_cast<QGridLayout*>(g_layouts[layout_id])) {
                gl->addWidget(g_widgets[widget_id], row, col, row_span, col_span);
            }
        }
    }
    else if (name == "grid_add_layout") {
        int layout_id = cmd["layout_id"].toInt();
        int child_id = cmd["child_layout_id"].toInt();
        int row = cmd["row"].toInt();
        int col = cmd["column"].toInt();
        if (g_layouts.count(layout_id) && g_layouts.count(child_id)) {
            if (auto* gl = qobject_cast<QGridLayout*>(g_layouts[layout_id])) {
                gl->addLayout(g_layouts[child_id], row, col);
            }
        }
    }
    else if (name == "create_form") {
        int id = g_next_id++;
        QFormLayout* fl = new QFormLayout();
        g_layouts[id] = fl;
        send_event("layout_created", id);
    }
    else if (name == "form_add_row") {
        int layout_id = cmd["layout_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        QString label = cmd["label"].toString("");
        if (g_layouts.count(layout_id) && g_widgets.count(widget_id)) {
            if (auto* fl = qobject_cast<QFormLayout*>(g_layouts[layout_id])) {
                if (label.isEmpty())
                    fl->addRow(g_widgets[widget_id]);
                else
                    fl->addRow(label, g_widgets[widget_id]);
            }
        }
    }
    else if (name == "form_add_row_widget") {
        int layout_id = cmd["layout_id"].toInt();
        int label_id = cmd["label_widget_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_layouts.count(layout_id) && g_widgets.count(label_id) && g_widgets.count(widget_id)) {
            if (auto* fl = qobject_cast<QFormLayout*>(g_layouts[layout_id])) {
                fl->addRow(g_widgets[label_id], g_widgets[widget_id]);
            }
        }
    }
    else if (name == "create_splitter") {
        int id = g_next_id++;
        Qt::Orientation orient = cmd["orientation"].toString("horizontal") == "vertical"
            ? Qt::Vertical : Qt::Horizontal;
        QSplitter* sp = new QSplitter(orient);
        g_widgets[id] = sp;
        send_event("widget_created", id);
    }
    else if (name == "splitter_add") {
        int splitter_id = cmd["splitter_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_widgets.count(splitter_id) && g_widgets.count(widget_id)) {
            if (auto* sp = qobject_cast<QSplitter*>(g_widgets[splitter_id])) {
                sp->addWidget(g_widgets[widget_id]);
            }
        }
    }
    else if (name == "splitter_set_sizes") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* sp = qobject_cast<QSplitter*>(g_widgets[id])) {
                QList<int> sizes;
                QJsonArray arr = cmd["sizes"].toArray();
                for (const auto& s : arr) sizes << s.toInt();
                sp->setSizes(sizes);
            }
        }
    }
    else if (name == "set_enabled") {
        int id = cmd["id"].toInt();
        bool enabled = cmd["enabled"].toBool(true);
        if (g_widgets.count(id)) g_widgets[id]->setEnabled(enabled);
    }
    else if (name == "set_visible") {
        int id = cmd["id"].toInt();
        bool visible = cmd["visible"].toBool(true);
        if (g_widgets.count(id)) g_widgets[id]->setVisible(visible);
    }
    else if (name == "hide") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) g_widgets[id]->hide();
    }
    else if (name == "set_tooltip") {
        int id = cmd["id"].toInt();
        QString tip = cmd["tooltip"].toString("");
        if (g_widgets.count(id)) g_widgets[id]->setToolTip(tip);
    }
    else if (name == "set_style") {
        int id = cmd["id"].toInt();
        QString css = cmd["style"].toString("");
        if (g_widgets.count(id)) g_widgets[id]->setStyleSheet(css);
    }
    else if (name == "set_geometry") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            g_widgets[id]->setGeometry(
                cmd["x"].toInt(), cmd["y"].toInt(),
                cmd["w"].toInt(), cmd["h"].toInt());
        }
    }
    else if (name == "set_fixed_size") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id))
            g_widgets[id]->setFixedSize(cmd["w"].toInt(), cmd["h"].toInt());
    }
    else if (name == "set_minimum_size") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id))
            g_widgets[id]->setMinimumSize(cmd["w"].toInt(), cmd["h"].toInt());
    }
    else if (name == "set_maximum_size") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id))
            g_widgets[id]->setMaximumSize(cmd["w"].toInt(), cmd["h"].toInt());
    }
    else if (name == "set_label_align") {
        int id = cmd["id"].toInt();
        QString align = cmd["alignment"].toString("left");
        if (g_widgets.count(id)) {
            if (auto* lbl = qobject_cast<QLabel*>(g_widgets[id])) {
                Qt::Alignment f = Qt::AlignLeft;
                if (align == "center") f = Qt::AlignCenter;
                else if (align == "right") f = Qt::AlignRight;
                lbl->setAlignment(f);
                if (cmd["word_wrap"].toBool(false)) lbl->setWordWrap(true);
            }
        }
    }
    else if (name == "set_lineedit_readonly") {
        int id = cmd["id"].toInt();
        bool ro = cmd["readonly"].toBool(true);
        if (g_widgets.count(id)) {
            if (auto* le = qobject_cast<QLineEdit*>(g_widgets[id])) le->setReadOnly(ro);
        }
    }
    else if (name == "set_lineedit_echo") {
        int id = cmd["id"].toInt();
        QString mode = cmd["mode"].toString("normal");
        if (g_widgets.count(id)) {
            if (auto* le = qobject_cast<QLineEdit*>(g_widgets[id])) {
                if (mode == "password") le->setEchoMode(QLineEdit::Password);
                else if (mode == "noecho") le->setEchoMode(QLineEdit::NoEcho);
                else le->setEchoMode(QLineEdit::Normal);
            }
        }
    }
    else if (name == "msgbox") {
        QString type = cmd["type"].toString("info");
        QString title = cmd["title"].toString("");
        QString text = cmd["text"].toString("");
        QMessageBox::Icon icon = QMessageBox::Information;
        if (type == "warning") icon = QMessageBox::Warning;
        else if (type == "critical") icon = QMessageBox::Critical;
        else if (type == "question") icon = QMessageBox::Question;
        QMessageBox box(icon, title, text);
        if (cmd["buttons"].toArray().size() > 0) {
            QMessageBox::StandardButtons btns;
            for (const auto& b : cmd["buttons"].toArray()) {
                QString bs = b.toString();
                if (bs == "ok") btns |= QMessageBox::Ok;
                else if (bs == "cancel") btns |= QMessageBox::Cancel;
                else if (bs == "yes") btns |= QMessageBox::Yes;
                else if (bs == "no") btns |= QMessageBox::No;
            }
            box.setStandardButtons(btns);
        }
        int result = box.exec();
        QJsonObject obj;
        obj["event"] = "msgbox_result";
        obj["result"] = result;
        send_json(obj);
    }
    else if (name == "file_dialog") {
        QString mode = cmd["mode"].toString("open");
        QString title = cmd["title"].toString("");
        QString dir = cmd["dir"].toString("");
        QString filter = cmd["filter"].toString("");
        QString result;
        if (mode == "save")
            result = QFileDialog::getSaveFileName(nullptr, title, dir, filter);
        else if (mode == "dir")
            result = QFileDialog::getExistingDirectory(nullptr, title, dir);
        else
            result = QFileDialog::getOpenFileName(nullptr, title, dir, filter);
        QJsonObject obj;
        obj["event"] = "file_dialog_result";
        obj["path"] = result;
        send_json(obj);
    }
    else if (name == "color_dialog") {
        int id = cmd["id"].toInt();
        QColor color = QColorDialog::getColor(
            cmd.contains("color") ? QColor(cmd["color"].toString()) : Qt::white,
            g_widgets.count(id) ? g_widgets[id] : nullptr,
            cmd.value("title").toString("Pick a Color")
        );
        QJsonObject obj;
        obj["event"] = "color_result";
        obj["color"] = color.isValid() ? color.name() : QString("");
        send_json(obj);
    }
    else if (name == "font_dialog") {
        int id = cmd["id"].toInt();
        bool ok;
        QFont font = QFontDialog::getFont(
            &ok,
            g_widgets.count(id) ? g_widgets[id] : nullptr
        );
        QJsonObject obj;
        obj["event"] = "font_result";
        obj["ok"] = ok;
        if (ok) {
            obj["family"] = font.family();
            obj["size"] = font.pointSize();
            obj["bold"] = font.bold();
            obj["italic"] = font.italic();
            obj["underline"] = font.underline();
        }
        send_json(obj);
    }
    else if (name == "input_dialog") {
        int id = cmd["id"].toInt();
        QString type = cmd.value("type").toString("text");
        QWidget* parent = g_widgets.count(id) ? g_widgets[id] : nullptr;
        bool ok;
        QString result_text;
        int result_int = 0;
        double result_double = 0.0;
        QJsonObject obj;
        obj["event"] = "input_result";

        if (type == "int") {
            result_int = QInputDialog::getInt(parent,
                cmd.value("title").toString("Input"),
                cmd.value("label").toString("Value:"),
                cmd.value("value").toInt(0),
                cmd.value("min").toInt(-2147483647),
                cmd.value("max").toInt(2147483647),
                cmd.value("step").toInt(1),
                &ok);
            obj["ok"] = ok;
            obj["value"] = result_int;
        } else if (type == "double") {
            result_double = QInputDialog::getDouble(parent,
                cmd.value("title").toString("Input"),
                cmd.value("label").toString("Value:"),
                cmd.value("value").toDouble(0.0),
                cmd.value("min").toDouble(-1e18),
                cmd.value("max").toDouble(1e18),
                cmd.value("decimals").toInt(2),
                &ok);
            obj["ok"] = ok;
            obj["value"] = result_double;
        } else if (type == "option") {
            QStringList options;
            if (cmd.contains("options")) {
                for (const auto& o : cmd["options"].toArray()) options << o.toString();
            }
            result_text = QInputDialog::getItem(parent,
                cmd.value("title").toString("Input"),
                cmd.value("label").toString("Select:"),
                options,
                cmd.value("current").toInt(0),
                false,
                &ok);
            obj["ok"] = ok;
            obj["value"] = result_text;
        } else {
            result_text = QInputDialog::getText(parent,
                cmd.value("title").toString("Input"),
                cmd.value("label").toString("Text:"),
                cmd.value("echo").toString() == "password" ? QLineEdit::Password : QLineEdit::Normal,
                cmd.value("default").toString(""),
                &ok);
            obj["ok"] = ok;
            obj["value"] = result_text;
        }
        send_json(obj);
    }
    else if (name == "progress_dialog") {
        int pid = g_next_id++;
        QProgressDialog* pd = new QProgressDialog(
            cmd.value("label").toString("Working..."),
            cmd.value("cancel").toString("Cancel"),
            cmd.value("min").toInt(0),
            cmd.value("max").toInt(100)
        );
        pd->setWindowTitle(cmd.value("title").toString("Progress"));
        if (cmd.contains("auto_close")) pd->setAutoClose(cmd["auto_close"].toBool(true));
        if (cmd.contains("auto_reset")) pd->setAutoReset(cmd["auto_reset"].toBool(true));
        g_widgets[pid] = pd;
        QObject::connect(pd, &QProgressDialog::canceled, [pid]() {
            QJsonObject r; r["event"] = "progress_canceled"; r["id"] = pid; send_json(r);
        });
        QJsonObject r; r["event"] = "widget_created"; r["id"] = pid; send_json(r);
    }
    else if (name == "set_progress_value") {
        int pid = cmd["id"].toInt();
        if (g_widgets.count(pid)) {
            if (auto* pd = qobject_cast<QProgressDialog*>(g_widgets[pid])) {
                pd->setValue(cmd["value"].toInt(0));
            }
        }
    }
    else if (name == "set_progress_label") {
        int pid = cmd["id"].toInt();
        if (g_widgets.count(pid)) {
            if (auto* pd = qobject_cast<QProgressDialog*>(g_widgets[pid])) {
                pd->setLabelText(cmd["label"].toString(""));
            }
        }
    }
    else if (name == "set_progress_range") {
        int pid = cmd["id"].toInt();
        if (g_widgets.count(pid)) {
            if (auto* pd = qobject_cast<QProgressDialog*>(g_widgets[pid])) {
                pd->setRange(cmd["min"].toInt(0), cmd["max"].toInt(100));
            }
        }
    }
    else if (name == "set_progress_cancel_text") {
        int pid = cmd["id"].toInt();
        if (g_widgets.count(pid)) {
            if (auto* pd = qobject_cast<QProgressDialog*>(g_widgets[pid])) {
                pd->setCancelButtonText(cmd["text"].toString("Cancel"));
            }
        }
    }
    else if (name == "is_progress_canceled") {
        int pid = cmd["id"].toInt();
        QJsonObject r; r["event"] = "progress_canceled_result"; r["id"] = pid;
        if (g_widgets.count(pid)) {
            if (auto* pd = qobject_cast<QProgressDialog*>(g_widgets[pid])) {
                r["canceled"] = pd->wasCanceled();
            }
        }
        send_json(r);
    }
    else if (name == "create_mainwindow") {
        int id = g_next_id++;
        QMainWindow* mw = new QMainWindow();
        g_widgets[id] = mw;
        send_event("widget_created", id);
    }
    else if (name == "set_central_widget") {
        int mw_id = cmd["id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_widgets.count(mw_id) && g_widgets.count(widget_id)) {
            if (auto* mw = qobject_cast<QMainWindow*>(g_widgets[mw_id])) {
                mw->setCentralWidget(g_widgets[widget_id]);
            }
        }
    }
    else if (name == "create_menu_bar") {
        int id = g_next_id++;
        int widget_id = cmd["widget_id"].toInt();
        if (g_widgets.count(widget_id)) {
            if (auto* mw = qobject_cast<QMainWindow*>(g_widgets[widget_id])) {
                QMenuBar* mb = mw->menuBar();
                g_widgets[id] = mb;
                send_event("widget_created", id);
            }
        }
    }
    else if (name == "menu_bar_add_menu") {
        int menubar_id = cmd["menubar_id"].toInt();
        QString title = cmd["title"].toString();
        if (g_widgets.count(menubar_id)) {
            if (auto* mb = qobject_cast<QMenuBar*>(g_widgets[menubar_id])) {
                int id = g_next_id++;
                QMenu* menu = mb->addMenu(title);
                g_menus[id] = menu;
                send_event("menu_created", id);
            }
        }
    }
    else if (name == "menu_add_action") {
        int menu_id = cmd["menu_id"].toInt();
        QString text = cmd["text"].toString();
        if (g_menus.count(menu_id)) {
            int id = g_next_id++;
            QAction* action = g_menus[menu_id]->addAction(text);
            g_actions[id] = action;
            QObject::connect(action, &QAction::triggered, [id]() {
                QJsonObject obj;
                obj["event"] = "action_triggered";
                obj["id"] = id;
                send_json(obj);
            });
            send_event("action_created", id);
        }
    }
    else if (name == "menu_add_separator") {
        int menu_id = cmd["menu_id"].toInt();
        if (g_menus.count(menu_id)) {
            g_menus[menu_id]->addSeparator();
        }
    }
    else if (name == "menu_add_submenu") {
        int menu_id = cmd["menu_id"].toInt();
        QString title = cmd["title"].toString();
        if (g_menus.count(menu_id)) {
            int id = g_next_id++;
            QMenu* submenu = g_menus[menu_id]->addMenu(title);
            g_menus[id] = submenu;
            send_event("menu_created", id);
        }
    }
    else if (name == "create_toolbar") {
        int id = g_next_id++;
        int widget_id = cmd["widget_id"].toInt();
        QString title = cmd["title"].toString("Toolbar");
        if (g_widgets.count(widget_id)) {
            if (auto* mw = qobject_cast<QMainWindow*>(g_widgets[widget_id])) {
                QToolBar* tb = mw->addToolBar(title);
                g_widgets[id] = tb;
                send_event("widget_created", id);
            }
        }
    }
    else if (name == "toolbar_add_button") {
        int toolbar_id = cmd["toolbar_id"].toInt();
        QString text = cmd["text"].toString();
        if (g_widgets.count(toolbar_id)) {
            if (auto* tb = qobject_cast<QToolBar*>(g_widgets[toolbar_id])) {
                int id = g_next_id++;
                QAction* action = tb->addAction(text);
                g_actions[id] = action;
                QObject::connect(action, &QAction::triggered, [id]() {
                    QJsonObject obj;
                    obj["event"] = "action_triggered";
                    obj["id"] = id;
                    send_json(obj);
                });
                send_event("action_created", id);
            }
        }
    }
    else if (name == "toolbar_add_widget") {
        int toolbar_id = cmd["toolbar_id"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_widgets.count(toolbar_id) && g_widgets.count(widget_id)) {
            if (auto* tb = qobject_cast<QToolBar*>(g_widgets[toolbar_id])) {
                tb->addWidget(g_widgets[widget_id]);
            }
        }
    }
    else if (name == "toolbar_add_separator") {
        int toolbar_id = cmd["toolbar_id"].toInt();
        if (g_widgets.count(toolbar_id)) {
            if (auto* tb = qobject_cast<QToolBar*>(g_widgets[toolbar_id])) {
                tb->addSeparator();
            }
        }
    }
    else if (name == "create_statusbar") {
        int id = g_next_id++;
        int widget_id = cmd["widget_id"].toInt();
        if (g_widgets.count(widget_id)) {
            if (auto* mw = qobject_cast<QMainWindow*>(g_widgets[widget_id])) {
                QStatusBar* sb = mw->statusBar();
                g_widgets[id] = sb;
                send_event("widget_created", id);
            }
        }
    }
    else if (name == "statusbar_set_text") {
        int id = cmd["id"].toInt();
        QString text = cmd["text"].toString();
        if (g_widgets.count(id)) {
            if (auto* sb = qobject_cast<QStatusBar*>(g_widgets[id])) {
                sb->showMessage(text);
            }
        }
    }
    else if (name == "create_table") {
        int id = g_next_id++;
        int rows = cmd["rows"].toInt(0);
        int cols = cmd["columns"].toInt(0);
        QTableWidget* table = new QTableWidget(rows, cols);
        g_widgets[id] = table;
        QObject::connect(table, &QTableWidget::cellClicked, [id, table](int row, int col) {
            QJsonObject obj;
            obj["event"] = "cell_clicked";
            obj["id"] = id;
            obj["row"] = row;
            obj["column"] = col;
            send_json(obj);
        });
        QObject::connect(table, &QTableWidget::cellDoubleClicked, [id, table](int row, int col) {
            QJsonObject obj;
            obj["event"] = "cell_double_clicked";
            obj["id"] = id;
            obj["row"] = row;
            obj["column"] = col;
            send_json(obj);
        });
        QObject::connect(table, &QTableWidget::cellChanged, [id, table](int row, int col) {
            QJsonObject obj;
            obj["event"] = "cell_changed";
            obj["id"] = id;
            obj["row"] = row;
            obj["column"] = col;
            QTableWidgetItem* item = table->item(row, col);
            if (item) obj["text"] = item->text();
            send_json(obj);
        });
        send_event("widget_created", id);
    }
    else if (name == "table_set_headers") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                QStringList headers;
                QJsonArray arr = cmd["headers"].toArray();
                for (const auto& h : arr) headers << h.toString();
                table->setHorizontalHeaderLabels(headers);
            }
        }
    }
    else if (name == "table_set_item") {
        int id = cmd["id"].toInt();
        int row = cmd["row"].toInt();
        int col = cmd["column"].toInt();
        QString text = cmd["text"].toString();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->blockSignals(true);
                QTableWidgetItem* item = table->item(row, col);
                if (!item) {
                    item = new QTableWidgetItem(text);
                    table->setItem(row, col, item);
                } else {
                    item->setText(text);
                }
                table->blockSignals(false);
            }
        }
    }
    else if (name == "table_get_item") {
        int id = cmd["id"].toInt();
        int row = cmd["row"].toInt();
        int col = cmd["column"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                QTableWidgetItem* item = table->item(row, col);
                QJsonObject obj;
                obj["event"] = "item_result";
                obj["id"] = id;
                obj["row"] = row;
                obj["column"] = col;
                obj["text"] = item ? item->text() : QString("");
                send_json(obj);
            }
        }
    }
    else if (name == "table_set_row_count") {
        int id = cmd["id"].toInt();
        int count = cmd["count"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->setRowCount(count);
            }
        }
    }
    else if (name == "table_set_column_count") {
        int id = cmd["id"].toInt();
        int count = cmd["count"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->setColumnCount(count);
            }
        }
    }
    else if (name == "table_insert_row") {
        int id = cmd["id"].toInt();
        int pos = cmd["position"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->insertRow(pos);
            }
        }
    }
    else if (name == "table_remove_row") {
        int id = cmd["id"].toInt();
        int pos = cmd["position"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->removeRow(pos);
            }
        }
    }
    else if (name == "table_set_cell_widget") {
        int id = cmd["id"].toInt();
        int row = cmd["row"].toInt();
        int col = cmd["column"].toInt();
        int widget_id = cmd["widget_id"].toInt();
        if (g_widgets.count(id) && g_widgets.count(widget_id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->setCellWidget(row, col, g_widgets[widget_id]);
            }
        }
    }
    else if (name == "table_set_selection_mode") {
        int id = cmd["id"].toInt();
        QString mode = cmd["mode"].toString("single");
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                if (mode == "multi" || mode == "extended")
                    table->setSelectionMode(QAbstractItemView::ExtendedSelection);
                else if (mode == "contiguous")
                    table->setSelectionMode(QAbstractItemView::ContiguousSelection);
                else if (mode == "none")
                    table->setSelectionMode(QAbstractItemView::NoSelection);
                else
                    table->setSelectionMode(QAbstractItemView::SingleSelection);
            }
        }
    }
    else if (name == "table_set_edit_triggers") {
        int id = cmd["id"].toInt();
        QString mode = cmd["mode"].toString("double_clicked");
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                if (mode == "all")
                    table->setEditTriggers(QAbstractItemView::AllEditTriggers);
                else if (mode == "none")
                    table->setEditTriggers(QAbstractItemView::NoEditTriggers);
                else if (mode == "selected")
                    table->setEditTriggers(QAbstractItemView::SelectedClicked);
                else
                    table->setEditTriggers(QAbstractItemView::DoubleClicked);
            }
        }
    }
    else if (name == "table_resize_columns") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
            }
        }
    }
    else if (name == "table_set_column_width") {
        int id = cmd["id"].toInt();
        int col = cmd["column"].toInt();
        int width = cmd["width"].toInt(100);
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->setColumnWidth(col, width);
            }
        }
    }
    else if (name == "table_set_row_height") {
        int id = cmd["id"].toInt();
        int row = cmd["row"].toInt();
        int height = cmd["height"].toInt(30);
        if (g_widgets.count(id)) {
            if (auto* table = qobject_cast<QTableWidget*>(g_widgets[id])) {
                table->setRowHeight(row, height);
            }
        }
    }
    else if (name == "set_plaintext") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) {
                te->setPlainText(cmd["text"].toString());
            }
        }
    }
    else if (name == "get_plaintext") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) {
                send_json({{"event", "text_result"}, {"id", id}, {"text", te->toPlainText()}});
            }
        }
    }
    else if (name == "plaintext_undo") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->undo();
        }
    }
    else if (name == "plaintext_redo") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->redo();
        }
    }
    else if (name == "plaintext_cut") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->cut();
        }
    }
    else if (name == "plaintext_copy") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->copy();
        }
    }
    else if (name == "plaintext_paste") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->paste();
        }
    }
    else if (name == "plaintext_selectall") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* te = qobject_cast<QPlainTextEdit*>(g_widgets[id])) te->selectAll();
        }
    }
    else if (name == "set_font") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            QFont font = g_widgets[id]->font();
            if (cmd.contains("family")) font.setFamily(cmd["family"].toString());
            if (cmd.contains("size")) font.setPointSize(cmd["size"].toInt());
            if (cmd.contains("bold")) font.setBold(cmd["bold"].toBool());
            if (cmd.contains("italic")) font.setItalic(cmd["italic"].toBool());
            if (cmd.contains("underline")) font.setUnderline(cmd["underline"].toBool());
            g_widgets[id]->setFont(font);
        }
    }
    else if (name == "enable_mouse_events") {
        int id = cmd["id"].toInt();
        bool enable = cmd.value("enable").toBool(true);
        if (enable) g_mouse_events_enabled.insert(id);
        else g_mouse_events_enabled.erase(id);
    }
    else if (name == "enable_key_events") {
        int id = cmd["id"].toInt();
        bool enable = cmd.value("enable").toBool(true);
        if (enable) {
            g_key_events_enabled.insert(id);
            if (g_widgets.count(id)) g_widgets[id]->setFocusPolicy(Qt::StrongFocus);
        } else {
            g_key_events_enabled.erase(id);
        }
    }
    else if (name == "enable_close_event") {
        int id = cmd["id"].toInt();
        bool enable = cmd.value("enable").toBool(true);
        if (enable) g_close_events_enabled.insert(id);
        else g_close_events_enabled.erase(id);
    }
    else if (name == "set_frameless") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            g_widgets[id]->setWindowFlags(g_widgets[id]->windowFlags() | Qt::FramelessWindowHint);
            g_widgets[id]->show();
        }
    }
    else if (name == "set_always_on_top") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            g_widgets[id]->setWindowFlags(g_widgets[id]->windowFlags() | Qt::WindowStaysOnTopHint);
            g_widgets[id]->show();
        }
    }
    else if (name == "set_modal") {
        int id = cmd["id"].toInt();
        bool modal = cmd.value("modal").toBool(true);
        if (g_widgets.count(id)) {
            g_widgets[id]->setWindowModality(modal ? Qt::ApplicationModal : Qt::NonModal);
        }
    }
    else if (name == "set_opacity") {
        int id = cmd["id"].toInt();
        double opacity = cmd["opacity"].toDouble(1.0);
        if (g_widgets.count(id)) {
            g_widgets[id]->setWindowOpacity(opacity);
        }
    }
    else if (name == "set_cursor") {
        int id = cmd["id"].toInt();
        QString shape = cmd["shape"].toString("arrow");
        if (g_widgets.count(id)) {
            Qt::CursorShape cs;
            if (shape == "hand") cs = Qt::PointingHandCursor;
            else if (shape == "wait") cs = Qt::WaitCursor;
            else if (shape == "text") cs = Qt::IBeamCursor;
            else if (shape == "cross") cs = Qt::CrossCursor;
            else if (shape == "forbidden") cs = Qt::ForbiddenCursor;
            else if (shape == "busy") cs = Qt::BusyCursor;
            else if (shape == "size_ver") cs = Qt::SizeVerCursor;
            else if (shape == "size_hor") cs = Qt::SizeHorCursor;
            else if (shape == "size_all") cs = Qt::SizeAllCursor;
            else if (shape == "blank") cs = Qt::BlankCursor;
            else cs = Qt::ArrowCursor;
            g_widgets[id]->setCursor(QCursor(cs));
        }
    }
    else if (name == "stackedwidget_add_page") {
        int id = cmd["id"].toInt();
        int child_id = cmd["child_id"].toInt();
        if (g_widgets.count(id) && g_widgets.count(child_id)) {
            if (auto* sw = qobject_cast<QStackedWidget*>(g_widgets[id])) {
                sw->addWidget(g_widgets[child_id]);
            }
        }
    }
    else if (name == "stackedwidget_set_current") {
        int id = cmd["id"].toInt();
        int index = cmd["index"].toInt();
        if (g_widgets.count(id)) {
            if (auto* sw = qobject_cast<QStackedWidget*>(g_widgets[id])) {
                sw->setCurrentIndex(index);
            }
        }
    }
    else if (name == "dockwidget_set_widget") {
        int id = cmd["id"].toInt();
        int child_id = cmd["child_id"].toInt();
        if (g_widgets.count(id) && g_widgets.count(child_id)) {
            if (auto* dw = qobject_cast<QDockWidget*>(g_widgets[id])) {
                dw->setWidget(g_widgets[child_id]);
            }
        }
    }
    else if (name == "textbrowser_set_html") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* tb = qobject_cast<QTextBrowser*>(g_widgets[id])) {
                tb->setHtml(cmd["html"].toString());
            }
        }
    }
    else if (name == "textbrowser_set_text") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* tb = qobject_cast<QTextBrowser*>(g_widgets[id])) {
                tb->setText(cmd["text"].toString());
            }
        }
    }
    else if (name == "lcd_display") {
        int id = cmd["id"].toInt();
        if (g_widgets.count(id)) {
            if (auto* lcd = qobject_cast<QLCDNumber*>(g_widgets[id])) {
                lcd->display(cmd["value"].toDouble(0.0));
            }
        }
    }
    else if (name == "quit") {
        if (g_app) g_app->quit();
        g_running = false;
    }
}

class StdinReader : public QThread {
protected:
    void run() override {
        std::string line;
        while (g_running && std::getline(std::cin, line)) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(line), &err);
            if (err.error != QJsonParseError::NoError) continue;
            if (doc.isArray()) {
                QJsonArray arr = doc.array();
                for (const auto& item : arr) {
                    if (item.isObject()) {
                        QJsonObject cmd = item.toObject();
                        QMetaObject::invokeMethod(qApp, [cmd]() {
                            process_command(cmd);
                        }, Qt::QueuedConnection);
                    }
                }
            } else if (doc.isObject()) {
                QJsonObject cmd = doc.object();
                QMetaObject::invokeMethod(qApp, [cmd]() {
                    process_command(cmd);
                }, Qt::QueuedConnection);
            }
        }
    }
};

int main() {
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);

    std::string line;
    while (std::getline(std::cin, line)) {
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(line), &err);
        if (err.error != QJsonParseError::NoError) continue;
        QJsonObject cmd = doc.object();
        process_command(cmd);
        if (cmd["name"].toString() == "exec") break;
    }

    g_event_filter = new EventFilter();
    qApp->installEventFilter(g_event_filter);

    StdinReader reader;
    reader.start();

    if (g_app) g_app->exec();

    reader.wait(2000);
    return 0;
}

#include "main.moc"
