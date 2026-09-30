{
  "commands": [
    {"name": "create_app"},
    {"name": "create_button", "args": {"id": 1, "text": "Hello"}},
    {"name": "create_listwidget", "args": {"id": 1}},
    {"name": "add_list_item", "args": {"id": 1, "text": "Item A"}},
    {"name": "add_list_items", "args": {"id": 1, "items": ["A", "B", "C"]}},
    {"name": "set_list_current_row", "args": {"id": 1, "row": 2}},
    {"name": "get_list_current_row", "args": {"id": 1}},
    {"name": "create_scrollarea", "args": {"id": 2}},
    {"name": "scrollarea_set_widget", "args": {"id": 2, "child_id": 1}},
    {"name": "create_scrollbar", "args": {"id": 3, "orientation": "vertical", "min": 0, "max": 100}},
    {"name": "create_toolbutton", "args": {"id": 4, "text": "Tools"}},
    {"name": "set_toolbutton_menu", "args": {"id": 4, "items": ["Opt 1", "Opt 2"]}},
    {"name": "show",          "args": {"id": 1}},
    {"name": "set_title",     "args": {"id": 1, "title": "Window"}},
    {"name": "on_click",      "args": {"id": 1}},
    {"name": "resize",        "args": {"id": 1, "w": 300, "h": 200}},
    {"name": "exec"},
    {"name": "quit"}
  ],
  "events": [
    {"event": "clicked", "id": 1, "text": "Hello"},
    {"event": "item_clicked", "id": 1, "row": 0, "text": "Item A"},
    {"event": "current_row_changed", "id": 1, "value": 2},
    {"event": "value_changed", "id": 3, "value": 50}
  ]
}
