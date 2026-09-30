# ExQt6 — TODO

## Status Atual

| Metric | Count |
|--------|-------|
| Comandos no daemon C++ | 146 |
| Eventos suportados | 24 (click, value_changed, text_changed, close, mouse_*, key_*, timer, layout_created, table_*, color_result, font_result, input_result, progress_canceled, item_clicked, item_double_clicked, current_row_changed) |
| Widgets | 28 (window, button, label, lineedit, combobox, checkbox, radiobutton, slider, spinbox, progressbar, tabwidget, groupbox, textedit, tree, buttongroup, splitter, dockwidget, textbrowser, doublespinbox, datetimeedit, lcdnumber, calendarwidget, dial, stackedwidget, listwidget, scrollarea, scrollbar, toolbutton) |
| Layouts | 4 (vbox, hbox, grid, form) + splitter |
| Dialogs | 4 (msgbox, file_dialog, color_dialog, font_dialog, input_dialog, progress_dialog) |
| Funções Elixir (Widget) | 127 |
| Funções Elixir (Layout) | 12 |
| Funções Elixir (Timer) | 4 |
| Total de funções públicas | 143 |
| Exemplos | 7 (widget_showcase, task_manager, auto_counter, click_counter, click_counter_sup, calculator, notepad) |
| Testes | 30 (unit) + 66 (comprehensive) = 96 total |

---

## Itens Completos

- [x] Testes — 30 unit + 62 comprehensive = 92 testes passando
- [x] README.md com descrição, quickstart, architecture, API overview
- [x] Limpeza — NIF removido, testes antigos removidos, crash dump removido
- [x] QMenuBar + QMenu (File > Open, Save, etc.)
- [x] QToolBar (barra de ferramentas com botões)
- [x] QStatusBar (barra de status inferior)
- [x] QTableWidget (tabelas com rows/cols/cells, editable, cell widget, selection mode)
- [x] Font properties (set_font com family, size, bold, italic, underline)
- [x] Mouse events (click, double_click, enter, leave via event filter)
- [x] Keyboard events (press, release via event filter)
- [x] close_event (intercepta fechamento, pode cancelar)
- [x] Calculadora (grid layout, botões 0-9, operações, display)
- [x] Notepad (text editor com menus, toolbar, statusbar, file dialogs)
- [x] Window properties (set_frameless, set_always_on_top, set_modal, set_opacity, set_cursor)
- [x] Batch commands (JSON array support no daemon + batch/2 no Elixir)
- [x] Pipeline-friendly setters (retornam struct para chaining)
- [x] use ExQt6.Widget.DSL macro (init/0, register/2, find/1 com ETS)
- [x] Named widgets registry (ETS-based lookup por nome)
- [x] set_current_index suporta QTabWidget e QComboBox

---

## A. Documentação

- [x] @doc + @specs em todas as funções públicas (115 Widget + 12 Layout + 4 Timer = 131)
- [ ] ex_doc config no mix.exs
- [ ] Moduledocs completos com exemplos de uso
- [ ] Protocolo JSON documentado
- [ ] Guide: "Como adicionar um widget novo no daemon"
- [ ] Guide: "Como adicionar um evento novo"
- [ ] Guide: "Arquitetura do projeto"
- [ ] Examples documentados com @doc

## B. Dialogs Faltantes

- [x] QColorDialog (seletor de cor)
- [x] QFontDialog (seletor de fonte)
- [x] QInputDialog (input simples: text, int, double, combo)
- [x] QProgressDialog (barra de progresso pra operações longas)
- [ ] QMessageBox customizado (ícone custom, botões custom)

## C. Widgets Novos

- [x] QDockWidget (painéis docking)
- [x] QTextBrowser (renderização de HTML)
- [x] QDoubleSpinBox (valores decimais)
- [x] QDateTimeEdit (date/time picker)
- [x] QToolButton (botão compacto pra toolbars)
- [x] QLCDNumber (display numérico estilo LCD)
- [x] QCalendarWidget (seletor de calendário)
- [x] QDial (botão circular tipo volume)
- [ ] QWizard / QWizardPage (assistente multi-step)
- [x] QStackedWidget (múltiplas páginas, só uma visível)
- [x] QListWidget (lista item-based)
- [x] QScrollArea (área de rolagem)
- [x] QScrollBar (scroll manual)

### Layouts Novos
- [ ] QStackedLayout (empilhar layouts, mostrar só um)
- [ ] Layout margins por widget (set_contents_margins)

## E. Exemplos Novos

- [ ] File Browser (tree + file dialog + preview pane)
- [ ] Chat UI simulado (input + send + message list com scroll)
- [ ] Settings Dialog (form layout com多种 tipos de input, Apply/Cancel)
- [ ] Login Form (user/pass + remember me + validation)
- [ ] Dashboard (grid de cards, charts placeholder, real-time data com timer)
- [ ] Drawing App (custom widget com paint, color picker)
- [ ] Sudoku (grid 9x9, input validation, timer)
- [ ] Markdown Editor (splitter: editor + preview HTML)

## F. Packaging e Distribuição

### hex.pm
- [ ] Configurar mix.exs pra hex (description, licenses, links, files)
- [ ] Daemon binário pré-compilado (Linux x86_64, macOS arm64, macOS x86_64)
- [ ] Script de cross-compilation ou CI pra gerar binários
- [ ] Incluir binário no pacote hex ou baixar no post-install
- [ ] Versionamento semântico (0.1.0 -> 1.0.0 quando estável)

### Nix
- [ ] Criar flake.nix (replaces shell.nix)
- [ ] Nix package pra ExQt6 (incluindo daemon como derivation)
- [ ] Flake pra desenvolvimento (devShell)
- [ ] NixOS module opcional (pra rodar daemon como serviço)

### CI/CD
- [ ] GitHub Actions: compile + test em Linux/macOS
- [ ] GitHub Actions: build daemon binário pra cada plataforma
- [ ] GitHub Actions: auto-publish hex.pm em tag
- [ ] Dialyzer no CI

## Extras

### Eventos Novos
- [ ] resize_event (new_w, new_h)
- [ ] move_event (new_x, new_y)
- [ ] focus_in / focus_out
- [ ] paint_event (custom painting)
- [ ] drag_enter / drag_move / drop (drag & drop)
- [ ] context_menu_request (botão direito)

### Window Flags Extras
- [ ] set_minimize_button / set_maximize_button / set_close_button
- [ ] center_on_screen
- [ ] set_window_icon (de arquivo ou themed icon)
- [ ] set_background (cor ou imagem)
- [ ] set_tab_order (ordem de Tab entre widgets)
- [ ] set_focus_policy (tab/click/strong/no focus)
- [ ] set_object_name (CSS targeting: `#myButton`)

### Outros
- [ ] set_cursor (shape: arrow, hand, wait, text, etc.) — DONE: set_cursor/2 com 10 shapes
- [ ] set_scrollbar (horizontal/vertical, range, value)
- [ ] scroll_to (widget/position)

### Performance
- [ ] Async events (não bloquear GenServer.call pra eventos frequentes)
- [ ] Connection pooling (múltiplos daemons pra múltiplas janelas)
- [ ] Watch mode (hot-reload de widgets sem reiniciar daemon)

### Robustez
- [ ] Daemon health check (ping/pong periódico)
- [ ] Auto-reconnect se daemon morrer
- [ ] Widget lifecycle tracking (auto-cleanup ao fazer GC)
- [ ] Rate limiting (evitar flood de comandos)
- [ ] Graceful shutdown (matar daemon ao fazer System.stop)
- [ ] Timeouts configuráveis globalmente

### Casos de Uso Específicos
- [ ] System tray icon (QSystemTrayIcon)
- [ ] Multimedia (QMediaPlayer, QVideoWidget)
- [ ] Networking (QtNetwork pra HTTP clients)
- [ ] Printing (QPrinter, QPrintDialog)
- [ ] OpenGL embedding (QOpenGLWidget)
- [ ] Web view (QWebEngineView — pesado)
- [ ] Charts (QChartView — gráficos de barra, linha, pie)
- [ ] Model/View (QListView, QTableView com QAbstractItemModel)
- [ ] State machine (QStateMachine pra UX complexa)
- [ ] Animation (QPropertyAnimation pra transições)
