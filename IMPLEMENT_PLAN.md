# ExQt6 — Plano de Implementação de Widgets

Este documento detalha como trazer todos os widgets Qt **práticos** para o ExQt6. O escopo cobre classes usáveis de forma direta/comum, deixando Graphics View e o Model/View abstrato (QAbstractItemModel etc.) para uma fase futura.

> **Padrão de implementação (3 camadas)** — para cada widget novo tanto no daemon quanto no Elixir:
>
> 1. **`native/qt_daemon/main.cpp`**: criar o handler `else if (name == "create_xxx")` que instancia a classe, guarda em `g_widgets[id]`, conecta signals e emite `send_event("widget_created", id)`. Adicionar `#include`.
> 2. **`native/qt_daemon/main.cpp`**: adicionar comandos de configuração/eventos específicos (`set_xxx`, `add_xxx`, `on_xxx`).
> 3. **`lib/ex_qt6/widget.ex`**: função `new_xxx/2` + helpers, seguindo o padrão `await_widget_created/1` e o struct `%__MODULE__{id, type}`.
> 4. **`lib/ex_qt6/widget_dsl.ex`**: importar novas funções se necessário.
> 5. **Testes**: adicionar aos 62 testes comprehensive em `test/comprehensive_test.exs`.
> 6. **Recompilar** o daemon: `cd native/qt_daemon && bash build.sh` (ou via `nix-shell`).
> 7. **`priv/qt_daemon`**: copiar o binário novo (o compilador `:qt_daemon` do `mix.exs` faz isso no build).
> 8. Atualizar `README.md`, `TODO.md` e `native/qt_daemon/protocol.md`.

---

## Prioridade

| Prioridade | Widgets | Justificativa |
|-----------|---------|---------------|
| **P0** | QListWidget, QScrollArea, QScrollBar, QToolButton | Os mais usados; QScrollArea/QScrollBar habilitam UIs maiores |
| **P1** | QListView, QTableView (com modelo), QToolBox, QTimeEdit, QDateEdit, QFontComboBox, QCommandLinkButton | Preenchem lacunas comuns em apps reais |
| **P2** | QMainWindow completo, QMdiArea/QMdiSubWindow, QColumnView, QTextBrowser avançado, QUndoStack/QUndoView, QTabBar | Features de organização/avançadas |
| **P3** | QSizeGrip, QFocusFrame, QTabBar low-level | Baixo ROI isolado; dependem de outros |

---

## Fase P0 — Widgets de alta demanda

### 1. QListWidget
Lista simples orientada a itens (item-based).
- **Daemon**: `#include <QListWidget>`
  - `create_listwidget` → `new QListWidget()`
  - `add_list_item {id, text}` → `addItem(text)`
  - `add_list_items {id, items[]}` → múltiplos
  - `list_remove_item {id, row}`
  - `set_list_current_row {id, row}`
  - `get_list_current_row {id}` → evento `get_result`
  - `set_list_item_text {id, row, text}`
- **Events**: `item_clicked {id,row,text}`, `current_row_changed {id,row}`, `item_double_clicked {id,row,text}`
- **Elixir**: `new_listwidget/2`, `add_list_item/3`, `add_list_items/3`, `list_remove_item/3`, `set_list_current_row/3`, `get_list_current_row/2`.

### 2. QScrollArea
Área de rolagem que contém outro widget.
- **Daemon**: `#include <QScrollArea>`
  - `create_scrollarea {id}` → `new QScrollArea()`
  - `scrollarea_set_widget {id, child_id}` → `setWidget(...)` (ou `setWidgetResizable`)
- **Elixir**: `new_scrollarea/2`, `scrollarea_set_widget/3`.

### 3. QScrollBar
Barra de rolagem manual (horizontal/vertical).
- **Daemon**: `#include <QScrollBar>`
  - `create_scrollbar {id, orientation, min, max, value}` → `new QScrollBar(orient)`
  - `set_scrollbar_range {id,min,max}`, `set_value` (já existe), `get_value` (já existe)
- **Events**: `value_changed {id, value}` (reusar handler existente ou novo).
- **Elixir**: `new_scrollbar/2`.

### 4. QToolButton
Botão compacto para toolbars, com menu popup opcional.
- **Daemon**: `#include <QToolButton>`
  - `create_toolbutton {id, text, icon?, toolbutton_style?}` → `new QToolButton()`
  - `set_toolbutton_menu {id, items[]}` → `setMenu(...)`
  - `set_toolbutton_arrow {id, direction}` → `setArrowType(...)`
- **Events**: `clicked {id}` (reusar handler).
- **Elixir**: `new_toolbutton/2`, `toolbutton_set_menu/3`.

---

## Fase P1 — Lacunas comuns

### 5. QListView
View model-based de lista (exige um modelo). Como o ExQt6 é item-based no estilo conveniente, implementar como `QListView` ligado a um `QStringListModel` interno no daemon.
- **Daemon**: `#include <QListView>`, `#include <QStringListModel>`
  - `create_listview {id}` → `new QListView()` + `setModel(new QStringListModel())`
  - `listview_set_strings {id, items[]}`
  - `listview_current_row/get`
- **Events**: `current_row_changed {id,row}`, `double_clicked`.
- **Elixir**: `new_listview/2`, `listview_set_strings/3`.

### 6. QTableView
Tabela model-based. Alternativa ao `QTableWidget` (já presente), mas a base de um modelo.
- **Daemon**: `#include <QTableView>`, `#include <QStandardItemModel>`
  - `create_tableview {id, rows, cols}`
  - `tableview_set_item {id,row,col,text}`
  - herdou lógica de `QStandardItemModel`.
- **Events**: `cell_clicked {id,row,col}`, `cell_double_clicked`.
- **Elixir**: `new_tableview/2`, `tableview_set_item/4`
- **Nota**: QTableWidget já cobre o caso comum; QTableView é padrão recomendado mas tem maior esforço. Fica em P1 (não P0).

### 7. QToolBox
Coluna de abas empilhadas onde só um item é visível.
- **Daemon**: `#include <QToolBox>`
  - `create_toolbox {id}` → `new QToolBox()`
  - `toolbox_add_item {id, widget_id, label}`
  - `set_current_index` (já suporta, adicionar QToolBox).
- **Events**: `current_changed {id,index}`.
- **Elixir**: `new_toolbox/2`, `toolbox_add_item/4`.

### 8. QTimeEdit / QDateEdit / QDateTimeEdit
Subclasses de `QDateTimeEdit` (já implementado) para restringir a time ou date.
- **Daemon**: `#include <QTimeEdit>`, `#include <QDateEdit>`
  - `create_timeedit {id}`, `create_dateedit {id}`
  - Reutilizar comandos `set_value`/`set_format`/`get_value` do datetimeedit.
- **Elixir**: `new_timeedit/2`, `new_dateedit/2`.

### 9. QFontComboBox
Combobox que lista fontes do sistema.
- **Daemon**: `#include <QFontComboBox>`
  - `create_fontcombobox {id}` → `new QFontComboBox()`
  - `get_fontcombobox_current {id}` (family) → `get_result`
- **Events**: `currentFontChanged {id,family}`.
- **Elixir**: `new_fontcombobox/2`.

### 10. QCommandLinkButton
Botão de comando estilo Vista com texto descritivo.
- **Daemon**: `#include <QCommandLinkButton>`
  - `create_commandlinkbutton {id, text, description?}`
  - `set_commandlink_description {id, text}`
- **Events**: `clicked {id}`.
- **Elixir**: `new_commandlinkbutton/2`.

---

## Fase P2 — Organização / avançados

### 11. QMainWindow (expor recursos faltantes)
`new_mainwindow` já existe; completar com `set_central_widget` (existe), `addToolBar`, `addDockWidget` (parcial), `menuBar`, `statusBar`.
- Integrar host de menus/toolbars/statusbar existentes.
- **Elixir**: `mainwindow_add_toolbar/3`, `mainwindow_add_dock/4`.

### 12. QMdiArea / QMdiSubWindow
Área de múltiplas janelas internas (documentos).
- **Daemon**: `#include <QMdiArea>`, `#include <QMdiSubWindow>`
  - `create_mdiarea {id}` → `new QMdiArea()`
  - `mdi_add_subwindow {id, child_id}` → `addSubWindow(...)`
  - `set_active_subwindow {id, sub_id}`, `cascade/tile`.
- **Elixir**: `new_mdiarea/2`, `mdi_add_subwindow/3`.

### 13. QColumnView
View de colunas encadeadas (estilo navegador de diretórios).
- **Daemon**: `#include <QColumnView>`
  - `create_columnview {id}` (model-based).
- **Elixir**: `new_columnview/2`. Baixa prioridade de uso.

### 14. QTextBrowser (avançado)
Já existe; estender com navegação (`backward/forward`, âncoras, `setOpenExternalLinks`).

### 15. QUndoStack / QUndoView
- **Daemon**: `#include <QUndoStack>`, `#include <QUndoView>`
  - `create_undostack {id}`, `undo {id}`, `redo {id}`, `create_undoview {id, stack_id}`.
- **Elixir**: `new_undostack/2`, `undo/2`, `redo/2`.

### 16. QTabBar
Barra de abas standalone (sem páginas).
- **Daemon**: `#include <QTabBar>`
  - `create_tabbar {id}`, `tabbar_add_tab {id, text}`, `tabbar_set_current {id,index}`.
- **Events**: `currentChanged {id,index}`.

---

## Fase P3 — Baixo ROI (opcional)

- **QSizeGrip** — suporte trivial via flag de janela; geralmente automático em QMainWindow.
- **QFocusFrame** — raramente necessário; normalmente gerenciado pelo style.
- **QTabBar low-level** — coberto pelo QTabWidget/P2.

---

## Widgets fora de escopo (Model/View abstrato + Graphics View)

Estas exigem modelagem de modelos (`QAbstractItemModel`, delegação) ou o framework Graphics View (cena/items). Não são "widgets diretos" e ficam para uma fase futura dedicada:

- **Model/View**: QAbstractItemModel, QAbstractItemView, QAbstractListModel, QAbstractTableModel, QAbstractProxyModel, QSortFilterProxyModel, QItemDelegate, QStyledItemDelegate, QItemSelectionModel, QDataWidgetMapper, QListWidgetItem/Interno, etc.
- **Graphics View**: QGraphicsScene, QGraphicsView, QGraphicsItem e todas as subclasses de items (QGraphicsRectItem, QGraphicsTextItem, ...), QGraphicsProxyWidget, layouts de Graphics View.
- **Estilo/paleta**: QStyle, QPalette, QStyleFactory (parcialmente fora; `set_style` CSS já cobre o caso comum).

---

## Busca de eventos (eventos transversais úteis)

Além dos eventos por-widget acima, priorizar estes eventos transversais (do TODO.md) que beneficiam todos os widgets:

- **resize_event** `{id, new_w, new_h}` — via overload de `resizeEvent`.
- **move_event** `{id, new_x, new_y}` — via `moveEvent`.
- **focus_in / focus_out** — via `focusInEvent`/`focusOutEvent` (ou `installEventFilter`).
- **context_menu_request** `{id, x, y}` — via `contextMenuEvent`.
- **drag & drop** — `drag_enter`, `drag_move`, `drop` (via setAcceptDrops + event filter).

## Extras de infraestrutura (recomendados em paralelo)

Para suportar melhor os widgets novos e a saúde geral:

1. **Eventos de `get_result` genérico** — já existe `get_result`; padronizar para `get_list_current_row`, `get_view_current`, etc. responderem pelo mesmo canal.
2. **Command helpers no daemon** — criar funções auxiliares `send_event(std::string, int id)` e `send_event_json(JsonObject)` para reduzir repetição e erros.
3. **Reutilizar handlers existentes** (`set_value`, `get_value`, `set_current_index`, `set_enabled`, `set_style`, `set_font`) — garantir que as novas classes sejam cobertas pelos `qobject_cast` já presentes.
4. **Teste de "todos os widgets criam"** — um teste comprehensive iterando por todos os `create_*` para garantir que nenhum widget novo quebra o parse JSON.

---

## Ordem sugerida de execução

1. **P0 (1-4)**: implementar os 4 widgets de alta demanda, com testes + exemplos atualizados.
2. **Infraestrutura**: refatorar `send_event` e adicionar teste de criação universal.
3. **P1 (5-10)**: seis widgets de lacunas comuns.
4. **P2 (11-16)**: organização e avançados.
5. **Documentação e packaging**: atualizar README/TODO/protocol.md, configurar ex_doc (pendente no TODO.md).

> Cada fase deve terminar com: daemon recompilado, `priv/qt_daemon` atualizado, testes passando (`mix test`), e `mix format` aplicado.
