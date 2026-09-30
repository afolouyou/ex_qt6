defmodule ExQt6.Widget do
  @moduledoc """
  High-level Elixir API for Qt widgets.
  """

  defstruct [:id, :type]

  @type t :: %__MODULE__{id: integer, type: atom}

  defp await_widget_created(timeout \\ 2000) do
    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} -> {:ok, id}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria uma nova janela (QWidget) no aplicativo Qt.
  """
  @spec new_window(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_window(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_window"})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :window}}
      error -> error
    end
  end

  @doc """
  Cria um novo botão com o texto especificado.
  """
  @spec new_button(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_button(app, text, timeout \\ 2000) when is_binary(text) do
    ExQt6.App.cmd(app, %{name: "create_button", text: text})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :button}}
      error -> error
    end
  end

  @doc """
  Cria um novo label (QLabel) com o texto especificado.
  """
  @spec new_label(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_label(app, text \\ "", timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_label", text: text})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :label}}
      error -> error
    end
  end

  @doc """
  Cria um novo campo de entrada de texto (QLineEdit) com placeholder opcional.
  """
  @spec new_lineedit(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_lineedit(app, placeholder \\ "", timeout \\ 2000) do
    cmd = %{name: "create_lineedit"}
    cmd = if placeholder != "", do: Map.put(cmd, :placeholder, placeholder), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :lineedit}}
      error -> error
    end
  end

  @doc """
  Cria um novo combo box (QComboBox) com a lista de itens.
  """
  @spec new_combobox(ExQt6.App.t(), list(String.t()), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_combobox(app, items \\ [], timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_combobox", items: items})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :combobox}}
      error -> error
    end
  end

  @doc """
  Cria um novo checkbox (QCheckBox) com o texto especificado.
  """
  @spec new_checkbox(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_checkbox(app, text \\ "", timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_checkbox", text: text})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :checkbox}}
      error -> error
    end
  end

  @doc """
  Cria um novo slider (QSlider) com as opções de intervalo e orientação.
  """
  @spec new_slider(ExQt6.App.t(), keyword(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_slider(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_slider"}
    cmd = if opts[:min], do: Map.put(cmd, :min, opts[:min]), else: cmd
    cmd = if opts[:max], do: Map.put(cmd, :max, opts[:max]), else: cmd
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    cmd = if opts[:orientation], do: Map.put(cmd, :orientation, opts[:orientation]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :slider}}
      error -> error
    end
  end

  @doc """
  Cria um novo editor de texto multifonte (QTextEdit).
  """
  @spec new_textedit(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_textedit(app, text \\ "", timeout \\ 2000) do
    cmd = %{name: "create_textedit"}
    cmd = if text != "", do: Map.put(cmd, :text, text), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :textedit}}
      error -> error
    end
  end

  @doc """
  Define o texto plano de um widget de texto.
  """
  @spec set_plaintext(t(), ExQt6.App.t(), String.t()) :: :ok
  def set_plaintext(%__MODULE__{id: id}, app, text) do
    ExQt6.App.cmd(app, %{name: "set_plaintext", id: id, text: text})
  end

  @doc """
  Obtém o texto plano de um widget de texto.
  """
  @spec get_plaintext(t(), ExQt6.App.t(), keyword()) :: {:ok, String.t()} | {:error, :timeout}
  def get_plaintext(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_plaintext", id: id})

    receive do
      {:qt_event, %{"event" => "text_result", "id" => ^id, "text" => text}} -> {:ok, text}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Desfaz a última operação de texto em um widget de texto plano.
  """
  @spec plaintext_undo(t(), ExQt6.App.t()) :: :ok
  def plaintext_undo(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "plaintext_undo", id: id})
  end

  @doc """
  Refaz a última operação de texto em um widget de texto plano.
  """
  @spec plaintext_redo(t(), ExQt6.App.t()) :: :ok
  def plaintext_redo(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "plaintext_redo", id: id})
  end

  @doc """
  Recorta o texto selecionado de um widget de texto plano.
  """
  @spec plaintext_cut(t(), ExQt6.App.t()) :: :ok
  def plaintext_cut(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "plaintext_cut", id: id})
  end

  @doc """
  Copia o texto selecionado de um widget de texto plano.
  """
  @spec plaintext_copy(t(), ExQt6.App.t()) :: :ok
  def plaintext_copy(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "plaintext_copy", id: id})
  end

  @doc """
  Cola o texto da área de transferência em um widget de texto plano.
  """
  @spec plaintext_paste(t(), ExQt6.App.t()) :: :ok
  def plaintext_paste(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "plaintext_paste", id: id})
  end

  @doc """
  Seleciona todo o texto de um widget de texto plano.
  """
  @spec plaintext_selectall(t(), ExQt6.App.t()) :: :ok
  def plaintext_selectall(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "plaintext_selectall", id: id})
  end

  @doc """
  Cria um novo spin box (QSpinBox) com os valores mínimo e máximo.
  """
  @spec new_spinbox(ExQt6.App.t(), integer(), integer(), keyword(), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_spinbox(app, min_val, max_val, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_spinbox", min: min_val, max: max_val}
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    cmd = if opts[:suffix], do: Map.put(cmd, :suffix, opts[:suffix]), else: cmd
    cmd = if opts[:prefix], do: Map.put(cmd, :prefix, opts[:prefix]), else: cmd
    cmd = if opts[:single_step], do: Map.put(cmd, :single_step, opts[:single_step]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :spinbox}}
      error -> error
    end
  end

  @doc """
  Cria uma nova barra de progresso (QProgressBar).
  """
  @spec new_progressbar(ExQt6.App.t(), integer(), integer(), keyword(), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_progressbar(app, min_val \\ 0, max_val \\ 100, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_progressbar", min: min_val, max: max_val}
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    cmd = if opts[:format], do: Map.put(cmd, :format, opts[:format]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :progressbar}}
      error -> error
    end
  end

  @doc """
  Cria um novo widget de abas (QTabWidget).
  """
  @spec new_tabwidget(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_tabwidget(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_tabwidget"})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :tabwidget}}
      error -> error
    end
  end

  @doc """
  Adiciona uma aba a um widget de abas com o título especificado.
  """
  @spec add_tab(t(), ExQt6.App.t(), t(), String.t()) :: :ok
  def add_tab(%__MODULE__{id: tabwidget_id}, app, %__MODULE__{id: widget_id}, title \\ "") do
    ExQt6.App.cmd(app, %{
      name: "add_tab",
      tabwidget_id: tabwidget_id,
      widget_id: widget_id,
      title: title
    })
  end

  @doc """
  Define o índice da aba ativa em um widget de abas.
  """
  @spec set_current_index(t(), ExQt6.App.t(), integer()) :: :ok
  def set_current_index(%__MODULE__{id: id}, app, index) do
    ExQt6.App.cmd(app, %{name: "set_current_index", id: id, index: index})
  end

  @doc """
  Cria um novo group box (QGroupBox) com o título especificado.
  """
  @spec new_groupbox(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_groupbox(app, title, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_groupbox", title: title})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :groupbox}}
      error -> error
    end
  end

  @doc """
  Cria um novo botão de rádio (QRadioButton) com o texto especificado.
  """
  @spec new_radiobutton(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_radiobutton(app, text \\ "", timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_radiobutton", text: text})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :radiobutton}}
      error -> error
    end
  end

  @doc """
  Cria um novo widget de árvore (QTreeWidget) com cabeçalhos opcionais.
  """
  @spec new_tree(ExQt6.App.t(), keyword(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_tree(app, opts \\ [], timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_tree"})

    case await_widget_created(timeout) do
      {:ok, id} ->
        tree = %__MODULE__{id: id, type: :tree}
        if opts[:headers], do: add_tree_header(tree, app, opts[:headers])
        {:ok, tree}

      error ->
        error
    end
  end

  @doc """
  Adiciona cabeçalhos a um widget de árvore.
  """
  @spec add_tree_header(t(), ExQt6.App.t(), [String.t()]) :: :ok
  def add_tree_header(%__MODULE__{id: id}, app, headers) when is_list(headers) do
    ExQt6.App.cmd(app, %{name: "add_tree_header", id: id, headers: headers})
  end

  @doc """
  Adiciona um item a um widget de árvore com opções de texto e filhos.
  """
  @spec add_tree_item(t(), ExQt6.App.t(), keyword()) :: :ok
  def add_tree_item(%__MODULE__{id: id}, app, opts \\ []) do
    cmd = %{name: "add_tree_item", id: id}
    cmd = if opts[:text], do: Map.put(cmd, :text, opts[:text]), else: cmd
    cmd = if opts[:children], do: Map.put(cmd, :children, opts[:children]), else: cmd
    ExQt6.App.cmd(app, cmd)
  end

  @doc """
  Define o texto de um item específico em um widget de árvore.
  """
  @spec set_tree_item_text(t(), ExQt6.App.t(), integer(), integer(), String.t()) :: :ok
  def set_tree_item_text(%__MODULE__{id: id}, app, row, column, text) do
    ExQt6.App.cmd(app, %{name: "set_tree_item_text", id: id, row: row, column: column, text: text})
  end

  @doc """
  Cria um novo grupo de botões (QButtonGroup).
  """
  @spec new_buttongroup(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_buttongroup(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_buttongroup"})

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :buttongroup}}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Adiciona um widget a um grupo de botões.
  """
  @spec add_to_buttongroup(t(), ExQt6.App.t(), t()) :: :ok
  def add_to_buttongroup(%__MODULE__{id: group_id}, app, %__MODULE__{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "add_to_buttongroup", group_id: group_id, widget_id: widget_id})
  end

  @doc """
  Cria um novo splitter (QSplitter) com a orientação especificada.
  """
  @spec new_splitter(ExQt6.App.t(), String.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_splitter(app, orientation \\ "horizontal", timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_splitter", orientation: orientation})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :splitter}}
      error -> error
    end
  end

  @doc """
  Cria um painel docking (QDockWidget).
  """
  @spec new_dockwidget(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_dockwidget(app, opts \\ []) do
    title = opts[:title] || "Dock"
    ExQt6.App.cmd(app, %{name: "create_dockwidget", title: title})

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :dockwidget}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um navegador de texto (QTextBrowser), suporta HTML.
  """
  @spec new_textbrowser(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_textbrowser(app, opts \\ []) do
    cmd = %{name: "create_textbrowser"}
    cmd = if opts[:text], do: Map.put(cmd, :text, opts[:text]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :textbrowser}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um spinbox de ponto flutuante (QDoubleSpinBox).
  """
  @spec new_doublespinbox(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_doublespinbox(app, opts \\ []) do
    cmd = %{name: "create_doublespinbox"}
    cmd = if opts[:min], do: Map.put(cmd, :min, opts[:min]), else: cmd
    cmd = if opts[:max], do: Map.put(cmd, :max, opts[:max]), else: cmd
    cmd = if opts[:step], do: Map.put(cmd, :step, opts[:step]), else: cmd
    cmd = if opts[:decimals], do: Map.put(cmd, :decimals, opts[:decimals]), else: cmd
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    cmd = if opts[:prefix], do: Map.put(cmd, :prefix, opts[:prefix]), else: cmd
    cmd = if opts[:suffix], do: Map.put(cmd, :suffix, opts[:suffix]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :doublespinbox}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um editor de data/hora (QDateTimeEdit).
  """
  @spec new_datetimeedit(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_datetimeedit(app, opts \\ []) do
    cmd = %{name: "create_datetimeedit"}
    cmd = if opts[:format], do: Map.put(cmd, :format, opts[:format]), else: cmd
    cmd = if opts[:datetime], do: Map.put(cmd, :datetime, opts[:datetime]), else: cmd

    cmd =
      if opts[:calendar_popup] != nil,
        do: Map.put(cmd, :calendar_popup, opts[:calendar_popup]),
        else: cmd

    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :datetimeedit}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um display numérico estilo LCD (QLCDNumber).
  """
  @spec new_qlcdnumber(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_qlcdnumber(app, opts \\ []) do
    cmd = %{name: "create_qlcdnumber"}
    cmd = if opts[:mode], do: Map.put(cmd, :mode, opts[:mode]), else: cmd
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :lcdnumber}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um seletor de calendário (QCalendarWidget).
  """
  @spec new_calendarwidget(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_calendarwidget(app, opts \\ []) do
    cmd = %{name: "create_calendarwidget"}
    cmd = if opts[:date], do: Map.put(cmd, :date, opts[:date]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :calendarwidget}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um botão circular tipo volume (QDial).
  """
  @spec new_dial(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_dial(app, opts \\ []) do
    cmd = %{name: "create_dial"}
    cmd = if opts[:min], do: Map.put(cmd, :min, opts[:min]), else: cmd
    cmd = if opts[:max], do: Map.put(cmd, :max, opts[:max]), else: cmd
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    cmd = if opts[:notches] != nil, do: Map.put(cmd, :notches, opts[:notches]), else: cmd
    cmd = if opts[:wrapping] != nil, do: Map.put(cmd, :wrapping, opts[:wrapping]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :dial}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um widget empilhado (QStackedWidget), mostra apenas uma página por vez.
  """
  @spec new_stackedwidget(ExQt6.App.t()) :: {:ok, t()} | {:error, :timeout}
  def new_stackedwidget(app) do
    ExQt6.App.cmd(app, %{name: "create_stackedwidget"})

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :stackedwidget}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Adiciona uma página ao QStackedWidget.
  """
  @spec stackedwidget_add_page(t(), ExQt6.App.t(), t()) :: :ok
  def stackedwidget_add_page(%__MODULE__{id: id}, app, %__MODULE__{id: child_id}) do
    ExQt6.App.cmd(app, %{name: "stackedwidget_add_page", id: id, child_id: child_id})
  end

  @doc """
  Define a página visível no QStackedWidget.
  """
  @spec stackedwidget_set_current(t(), ExQt6.App.t(), integer()) :: :ok
  def stackedwidget_set_current(%__MODULE__{id: id}, app, index) do
    ExQt6.App.cmd(app, %{name: "stackedwidget_set_current", id: id, index: index})
  end

  @doc """
  Define o widget filho de um QDockWidget.
  """
  @spec dockwidget_set_widget(t(), ExQt6.App.t(), t()) :: :ok
  def dockwidget_set_widget(%__MODULE__{id: id}, app, %__MODULE__{id: child_id}) do
    ExQt6.App.cmd(app, %{name: "dockwidget_set_widget", id: id, child_id: child_id})
  end

  @doc """
  Define o conteúdo HTML de um QTextBrowser.
  """
  @spec textbrowser_set_html(t(), ExQt6.App.t(), String.t()) :: :ok
  def textbrowser_set_html(%__MODULE__{id: id}, app, html) do
    ExQt6.App.cmd(app, %{name: "textbrowser_set_html", id: id, html: html})
  end

  @doc """
  Define o texto puro de um QTextBrowser.
  """
  @spec textbrowser_set_text(t(), ExQt6.App.t(), String.t()) :: :ok
  def textbrowser_set_text(%__MODULE__{id: id}, app, text) do
    ExQt6.App.cmd(app, %{name: "textbrowser_set_text", id: id, text: text})
  end

  @doc """
  Define o valor exibido em um QLCDNumber.
  """
  @spec lcd_display(t(), ExQt6.App.t(), number()) :: :ok
  def lcd_display(%__MODULE__{id: id}, app, value) do
    ExQt6.App.cmd(app, %{name: "lcd_display", id: id, value: value})
  end

  @doc """
  Adiciona um widget a um splitter.
  """
  @spec splitter_add(t(), ExQt6.App.t(), t()) :: :ok
  def splitter_add(%__MODULE__{id: splitter_id}, app, %__MODULE__{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "splitter_add", splitter_id: splitter_id, widget_id: widget_id})
  end

  @doc """
  Define os tamanhos relativos dos painéis de um splitter.
  """
  @spec splitter_set_sizes(t(), ExQt6.App.t(), [integer()]) :: :ok
  def splitter_set_sizes(%__MODULE__{id: id}, app, sizes) when is_list(sizes) do
    ExQt6.App.cmd(app, %{name: "splitter_set_sizes", id: id, sizes: sizes})
  end

  @doc """
  Cria uma nova janela principal (QMainWindow).
  """
  @spec new_mainwindow(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_mainwindow(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_mainwindow"})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :mainwindow}}
      error -> error
    end
  end

  @doc """
  Define o widget central de uma janela principal.
  """
  @spec set_main_widget(t(), ExQt6.App.t(), t()) :: :ok
  def set_main_widget(%__MODULE__{id: mw_id}, app, %__MODULE__{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "set_central_widget", id: mw_id, widget_id: widget_id})
  end

  @doc """
  Cria uma nova barra de menus em um widget.
  """
  @spec new_menu_bar(t(), ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_menu_bar(%__MODULE__{id: widget_id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_menu_bar", widget_id: widget_id})

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} ->
        {:ok, %__MODULE__{id: id, type: :menubar}}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Adiciona um menu à barra de menus com o título especificado.
  """
  @spec menu_bar_add_menu(t(), ExQt6.App.t(), String.t(), keyword()) ::
          {:ok, integer()} | {:error, :timeout}
  def menu_bar_add_menu(%__MODULE__{id: menubar_id}, app, title, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "menu_bar_add_menu", menubar_id: menubar_id, title: title})

    receive do
      {:qt_event, %{"event" => "menu_created", "id" => id}} -> {:ok, id}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Adiciona uma ação de texto a um menu.
  """
  @spec menu_add_action(integer(), ExQt6.App.t(), String.t(), keyword()) ::
          {:ok, integer()} | {:error, :timeout}
  def menu_add_action(menu_id, app, text, timeout \\ 2000) when is_integer(menu_id) do
    ExQt6.App.cmd(app, %{name: "menu_add_action", menu_id: menu_id, text: text})

    receive do
      {:qt_event, %{"event" => "action_created", "id" => id}} -> {:ok, id}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Adiciona um separador a um menu.
  """
  @spec menu_add_separator(integer(), ExQt6.App.t()) :: :ok
  def menu_add_separator(menu_id, app) when is_integer(menu_id) do
    ExQt6.App.cmd(app, %{name: "menu_add_separator", menu_id: menu_id})
  end

  @doc """
  Adiciona um submenu a um menu com o título especificado.
  """
  @spec menu_add_submenu(integer(), ExQt6.App.t(), String.t(), keyword()) ::
          {:ok, integer()} | {:error, :timeout}
  def menu_add_submenu(menu_id, app, title, timeout \\ 2000) when is_integer(menu_id) do
    ExQt6.App.cmd(app, %{name: "menu_add_submenu", menu_id: menu_id, title: title})

    receive do
      {:qt_event, %{"event" => "menu_created", "id" => id}} -> {:ok, id}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Cria uma nova barra de ferramentas (QToolBar) em um widget.
  """
  @spec new_toolbar(t(), ExQt6.App.t(), String.t(), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_toolbar(%__MODULE__{id: widget_id}, app, title \\ "Toolbar", timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_toolbar", widget_id: widget_id, title: title})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :toolbar}}
      error -> error
    end
  end

  @doc """
  Adiciona um botão à barra de ferramentas com o texto especificado.
  """
  @spec toolbar_add_button(t(), ExQt6.App.t(), String.t(), keyword()) ::
          {:ok, integer()} | {:error, :timeout}
  def toolbar_add_button(%__MODULE__{id: toolbar_id}, app, text, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "toolbar_add_button", toolbar_id: toolbar_id, text: text})

    receive do
      {:qt_event, %{"event" => "action_created", "id" => id}} -> {:ok, id}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Adiciona um widget à barra de ferramentas.
  """
  @spec toolbar_add_widget(t(), ExQt6.App.t(), t()) :: :ok
  def toolbar_add_widget(%__MODULE__{id: toolbar_id}, app, %__MODULE__{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "toolbar_add_widget", toolbar_id: toolbar_id, widget_id: widget_id})
  end

  @doc """
  Adiciona um separador à barra de ferramentas.
  """
  @spec toolbar_add_separator(t(), ExQt6.App.t()) :: :ok
  def toolbar_add_separator(%__MODULE__{id: toolbar_id}, app) do
    ExQt6.App.cmd(app, %{name: "toolbar_add_separator", toolbar_id: toolbar_id})
  end

  @doc """
  Cria uma nova barra de status (QStatusBar) em um widget.
  """
  @spec new_statusbar(t(), ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_statusbar(%__MODULE__{id: widget_id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_statusbar", widget_id: widget_id})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :statusbar}}
      error -> error
    end
  end

  @doc """
  Define o texto exibido na barra de status.
  """
  @spec statusbar_set_text(t(), ExQt6.App.t(), String.t()) :: :ok
  def statusbar_set_text(%__MODULE__{id: id}, app, text) do
    ExQt6.App.cmd(app, %{name: "statusbar_set_text", id: id, text: text})
  end

  @doc """
  Cria uma nova tabela (QTableWidget) com o número de linhas e colunas.
  """
  @spec new_table(ExQt6.App.t(), integer(), integer(), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_table(app, rows \\ 0, columns \\ 0, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_table", rows: rows, columns: columns})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :table}}
      error -> error
    end
  end

  @doc """
  Define os cabeçalhos de uma tabela.
  """
  @spec table_set_headers(t(), ExQt6.App.t(), [String.t()]) :: :ok
  def table_set_headers(%__MODULE__{id: id}, app, headers) when is_list(headers) do
    ExQt6.App.cmd(app, %{name: "table_set_headers", id: id, headers: headers})
  end

  @doc """
  Define o texto de uma célula específica da tabela.
  """
  @spec table_set_item(t(), ExQt6.App.t(), integer(), integer(), String.t()) :: :ok
  def table_set_item(%__MODULE__{id: id}, app, row, col, text) do
    ExQt6.App.cmd(app, %{name: "table_set_item", id: id, row: row, column: col, text: text})
  end

  @doc """
  Obtém o texto de uma célula específica da tabela.
  """
  @spec table_get_item(t(), ExQt6.App.t(), integer(), integer(), keyword()) ::
          {:ok, String.t()} | {:error, :timeout}
  def table_get_item(%__MODULE__{id: id}, app, row, col, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "table_get_item", id: id, row: row, column: col})

    receive do
      {:qt_event,
       %{"event" => "item_result", "id" => ^id, "row" => ^row, "column" => ^col, "text" => text}} ->
        {:ok, text}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Define o número de linhas de uma tabela.
  """
  @spec table_set_row_count(t(), ExQt6.App.t(), integer()) :: :ok
  def table_set_row_count(%__MODULE__{id: id}, app, count) do
    ExQt6.App.cmd(app, %{name: "table_set_row_count", id: id, count: count})
  end

  @doc """
  Define o número de colunas de uma tabela.
  """
  @spec table_set_column_count(t(), ExQt6.App.t(), integer()) :: :ok
  def table_set_column_count(%__MODULE__{id: id}, app, count) do
    ExQt6.App.cmd(app, %{name: "table_set_column_count", id: id, count: count})
  end

  @doc """
  Insere uma nova linha em uma tabela na posição especificada.
  """
  @spec table_insert_row(t(), ExQt6.App.t(), integer()) :: :ok
  def table_insert_row(%__MODULE__{id: id}, app, position) do
    ExQt6.App.cmd(app, %{name: "table_insert_row", id: id, position: position})
  end

  @doc """
  Remove uma linha de uma tabela na posição especificada.
  """
  @spec table_remove_row(t(), ExQt6.App.t(), integer()) :: :ok
  def table_remove_row(%__MODULE__{id: id}, app, position) do
    ExQt6.App.cmd(app, %{name: "table_remove_row", id: id, position: position})
  end

  @doc """
  Define um widget em uma célula específica da tabela.
  """
  @spec table_set_cell_widget(t(), ExQt6.App.t(), integer(), integer(), t()) :: :ok
  def table_set_cell_widget(%__MODULE__{id: table_id}, app, row, col, %__MODULE__{id: widget_id}) do
    ExQt6.App.cmd(app, %{
      name: "table_set_cell_widget",
      id: table_id,
      row: row,
      column: col,
      widget_id: widget_id
    })
  end

  @doc """
  Define o modo de seleção de uma tabela.
  """
  @spec table_set_selection_mode(t(), ExQt6.App.t(), String.t()) :: :ok
  def table_set_selection_mode(%__MODULE__{id: id}, app, mode \\ "single") do
    ExQt6.App.cmd(app, %{name: "table_set_selection_mode", id: id, mode: mode})
  end

  @doc """
  Define os gatilhos de edição de uma tabela.
  """
  @spec table_set_edit_triggers(t(), ExQt6.App.t(), String.t()) :: :ok
  def table_set_edit_triggers(%__MODULE__{id: id}, app, mode \\ "double_clicked") do
    ExQt6.App.cmd(app, %{name: "table_set_edit_triggers", id: id, mode: mode})
  end

  @doc """
  Redimensiona automaticamente as colunas da tabela para se ajustarem ao conteúdo.
  """
  @spec table_resize_columns(t(), ExQt6.App.t()) :: :ok
  def table_resize_columns(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "table_resize_columns", id: id})
  end

  @doc """
  Define a largura de uma coluna específica da tabela.
  """
  @spec table_set_column_width(t(), ExQt6.App.t(), integer(), integer()) :: :ok
  def table_set_column_width(%__MODULE__{id: id}, app, col, width) do
    ExQt6.App.cmd(app, %{name: "table_set_column_width", id: id, column: col, width: width})
  end

  @doc """
  Define a altura de uma linha específica da tabela.
  """
  @spec table_set_row_height(t(), ExQt6.App.t(), integer(), integer()) :: :ok
  def table_set_row_height(%__MODULE__{id: id}, app, row, height) do
    ExQt6.App.cmd(app, %{name: "table_set_row_height", id: id, row: row, height: height})
  end

  @doc """
  Define a fonte de um widget com as opções especificadas.
  """
  @spec set_font(t(), ExQt6.App.t(), keyword()) :: t()
  def set_font(%__MODULE__{} = w, app, opts \\ []) do
    cmd = Map.new(opts) |> Map.put(:name, "set_font") |> Map.put(:id, w.id)
    ExQt6.App.cmd(app, cmd)
    w
  end

  @doc """
  Habilita ou desabilita o recebimento de eventos de mouse em um widget.
  """
  @spec enable_mouse_events(t(), ExQt6.App.t(), boolean()) :: t()
  def enable_mouse_events(%__MODULE__{} = w, app, enable \\ true) do
    ExQt6.App.cmd(app, %{name: "enable_mouse_events", id: w.id, enable: enable})
    w
  end

  @doc """
  Habilita ou desabilita o recebimento de eventos de teclado em um widget.
  """
  @spec enable_key_events(t(), ExQt6.App.t(), boolean()) :: t()
  def enable_key_events(%__MODULE__{} = w, app, enable \\ true) do
    ExQt6.App.cmd(app, %{name: "enable_key_events", id: w.id, enable: enable})
    w
  end

  @doc """
  Habilita ou desabilita o recebimento do evento de fechar em um widget.
  """
  @spec enable_close_event(t(), ExQt6.App.t(), boolean()) :: t()
  def enable_close_event(%__MODULE__{} = w, app, enable \\ true) do
    ExQt6.App.cmd(app, %{name: "enable_close_event", id: w.id, enable: enable})
    w
  end

  @doc """
  Torna um widget sem moldura (frameless).
  """
  @spec set_frameless(t(), ExQt6.App.t()) :: t()
  def set_frameless(%__MODULE__{} = w, app) do
    ExQt6.App.cmd(app, %{name: "set_frameless", id: w.id})
    w
  end

  @doc """
  Define se um widget deve ficar sempre acima das outras janelas.
  """
  @spec set_always_on_top(t(), ExQt6.App.t(), boolean()) :: t()
  def set_always_on_top(%__MODULE__{} = w, app, on_top \\ true) do
    ExQt6.App.cmd(app, %{name: "set_always_on_top", id: w.id, on_top: on_top})
    w
  end

  @doc """
  Define se um widget é modal ou não.
  """
  @spec set_modal(t(), ExQt6.App.t(), boolean()) :: t()
  def set_modal(%__MODULE__{} = w, app, modal \\ true) do
    ExQt6.App.cmd(app, %{name: "set_modal", id: w.id, modal: modal})
    w
  end

  @doc """
  Define a opacidade de um widget (0.0 a 1.0).
  """
  @spec set_opacity(t(), ExQt6.App.t(), float()) :: t()
  def set_opacity(%__MODULE__{} = w, app, opacity)
      when is_float(opacity) and opacity >= 0.0 and opacity <= 1.0 do
    ExQt6.App.cmd(app, %{name: "set_opacity", id: w.id, opacity: opacity})
    w
  end

  @doc """
  Define o formato do cursor quando sobre um widget.
  """
  @spec set_cursor(t(), ExQt6.App.t(), String.t()) :: t()
  def set_cursor(%__MODULE__{} = w, app, shape \\ "arrow") do
    ExQt6.App.cmd(app, %{name: "set_cursor", id: w.id, shape: shape})
    w
  end

  @doc """
  Habilita ou desabilita um widget.
  """
  @spec set_enabled(t(), ExQt6.App.t(), boolean()) :: t()
  def set_enabled(%__MODULE__{} = w, app, enabled \\ true) do
    ExQt6.App.cmd(app, %{name: "set_enabled", id: w.id, enabled: enabled})
    w
  end

  @doc """
  Define a visibilidade de um widget.
  """
  @spec set_visible(t(), ExQt6.App.t(), boolean()) :: t()
  def set_visible(%__MODULE__{} = w, app, visible \\ true) do
    ExQt6.App.cmd(app, %{name: "set_visible", id: w.id, visible: visible})
    w
  end

  @doc """
  Esconde um widget.
  """
  @spec hide(t(), ExQt6.App.t()) :: t()
  def hide(%__MODULE__{} = w, app) do
    ExQt6.App.cmd(app, %{name: "hide", id: w.id})
    w
  end

  @doc """
  Define o texto de dica (tooltip) exibido ao passar o mouse sobre um widget.
  """
  @spec set_tooltip(t(), ExQt6.App.t(), String.t()) :: t()
  def set_tooltip(%__MODULE__{} = w, app, tooltip) do
    ExQt6.App.cmd(app, %{name: "set_tooltip", id: w.id, tooltip: tooltip})
    w
  end

  @doc """
  Aplica um estilo CSS a um widget.
  """
  @spec set_style(t(), ExQt6.App.t(), String.t()) :: t()
  def set_style(%__MODULE__{} = w, app, css) do
    ExQt6.App.cmd(app, %{name: "set_style", id: w.id, style: css})
    w
  end

  @doc """
  Define a geometria (posição e tamanho) de um widget.
  """
  @spec set_geometry(t(), ExQt6.App.t(), integer(), integer(), integer(), integer()) :: t()
  def set_geometry(%__MODULE__{} = widget, app, x, y, w, h) do
    ExQt6.App.cmd(app, %{name: "set_geometry", id: widget.id, x: x, y: y, w: w, h: h})
    widget
  end

  @doc """
  Define o tamanho fixo de um widget.
  """
  @spec set_fixed_size(t(), ExQt6.App.t(), integer(), integer()) :: t()
  def set_fixed_size(%__MODULE__{} = widget, app, w, h) do
    ExQt6.App.cmd(app, %{name: "set_fixed_size", id: widget.id, w: w, h: h})
    widget
  end

  @doc """
  Define o tamanho mínimo de um widget.
  """
  @spec set_minimum_size(t(), ExQt6.App.t(), integer(), integer()) :: t()
  def set_minimum_size(%__MODULE__{} = widget, app, w, h) do
    ExQt6.App.cmd(app, %{name: "set_minimum_size", id: widget.id, w: w, h: h})
    widget
  end

  @doc """
  Define o tamanho máximo de um widget.
  """
  @spec set_maximum_size(t(), ExQt6.App.t(), integer(), integer()) :: t()
  def set_maximum_size(%__MODULE__{} = widget, app, w, h) do
    ExQt6.App.cmd(app, %{name: "set_maximum_size", id: widget.id, w: w, h: h})
    widget
  end

  @doc """
  Define o alinhamento e quebra de texto de um label.
  """
  @spec set_label_align(t(), ExQt6.App.t(), String.t(), boolean()) :: t()
  def set_label_align(%__MODULE__{} = widget, app, alignment \\ "left", word_wrap \\ false) do
    ExQt6.App.cmd(app, %{
      name: "set_label_align",
      id: widget.id,
      alignment: alignment,
      word_wrap: word_wrap
    })

    widget
  end

  @doc """
  Define se um campo de entrada de texto é somente leitura.
  """
  @spec set_lineedit_readonly(t(), ExQt6.App.t(), boolean()) :: t()
  def set_lineedit_readonly(%__MODULE__{} = widget, app, readonly \\ true) do
    ExQt6.App.cmd(app, %{name: "set_lineedit_readonly", id: widget.id, readonly: readonly})
    widget
  end

  @doc """
  Define o modo de exibição de um campo de entrada de texto (normal, senha, etc).
  """
  @spec set_lineedit_echo(t(), ExQt6.App.t(), String.t()) :: t()
  def set_lineedit_echo(%__MODULE__{} = widget, app, mode \\ "normal") do
    ExQt6.App.cmd(app, %{name: "set_lineedit_echo", id: widget.id, mode: mode})
    widget
  end

  @doc """
  Exibe uma caixa de mensagem nativa com as opções especificadas.
  """
  @spec msgbox(ExQt6.App.t(), keyword()) :: {:ok, String.t()} | {:error, :timeout}
  def msgbox(app, opts \\ []) do
    type = opts[:type] || "info"
    title = opts[:title] || ""
    text = opts[:text] || ""
    buttons = opts[:buttons] || ["ok"]
    ExQt6.App.cmd(app, %{name: "msgbox", type: type, title: title, text: text, buttons: buttons})

    receive do
      {:qt_event, %{"event" => "msgbox_result", "result" => result}} -> {:ok, result}
    after
      30_000 -> {:error, :timeout}
    end
  end

  @doc """
  Exibe um diálogo de arquivo nativo para abrir ou salvar arquivos.
  """
  @spec file_dialog(ExQt6.App.t(), keyword()) :: {:ok, String.t()} | {:error, :timeout}
  def file_dialog(app, opts \\ []) do
    mode = opts[:mode] || "open"
    title = opts[:title] || ""
    dir = opts[:dir] || ""
    filter = opts[:filter] || ""
    ExQt6.App.cmd(app, %{name: "file_dialog", mode: mode, title: title, dir: dir, filter: filter})

    receive do
      {:qt_event, %{"event" => "file_dialog_result", "path" => path}} -> {:ok, path}
    after
      60_000 -> {:error, :timeout}
    end
  end

  @doc """
  Exibe um diálogo de seleção de cor. Retorna {:ok, "#rrggbb"} ou {:ok, ""} se cancelado.
  """
  @spec color_dialog(ExQt6.App.t(), keyword()) :: {:ok, String.t()} | {:error, :timeout}
  def color_dialog(app, opts \\ []) do
    id = opts[:id] || 0
    title = opts[:title] || "Pick a Color"
    color = opts[:color] || "#ffffff"
    ExQt6.App.cmd(app, %{name: "color_dialog", id: id, title: title, color: color})

    receive do
      {:qt_event, %{"event" => "color_result", "color" => color}} -> {:ok, color}
    after
      60_000 -> {:error, :timeout}
    end
  end

  @doc """
  Exibe um diálogo de seleção de fonte. Retorna {:ok, %{family, size, bold, italic, underline}} ou {:ok, :cancelled}.
  """
  @spec font_dialog(ExQt6.App.t(), keyword()) :: {:ok, map() | :cancelled} | {:error, :timeout}
  def font_dialog(app, opts \\ []) do
    id = opts[:id] || 0
    ExQt6.App.cmd(app, %{name: "font_dialog", id: id})

    receive do
      {:qt_event, %{"event" => "font_result", "ok" => true} = r} ->
        {:ok,
         %{
           family: r["family"],
           size: r["size"],
           bold: r["bold"],
           italic: r["italic"],
           underline: r["underline"]
         }}

      {:qt_event, %{"event" => "font_result", "ok" => false}} ->
        {:ok, :cancelled}
    after
      60_000 -> {:error, :timeout}
    end
  end

  @doc """
  Exibe um diálogo de input (texto, inteiro, double ou opção). Retorna {:ok, valor} ou {:ok, :cancelled}.
  """
  @spec input_dialog(ExQt6.App.t(), keyword()) :: {:ok, term() | :cancelled} | {:error, :timeout}
  def input_dialog(app, opts \\ []) do
    id = opts[:id] || 0
    type = opts[:type] || "text"
    cmd = %{name: "input_dialog", id: id, type: type}
    cmd = if opts[:title], do: Map.put(cmd, :title, opts[:title]), else: cmd
    cmd = if opts[:label], do: Map.put(cmd, :label, opts[:label]), else: cmd
    cmd = if opts[:default], do: Map.put(cmd, :default, opts[:default]), else: cmd
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    cmd = if opts[:min], do: Map.put(cmd, :min, opts[:min]), else: cmd
    cmd = if opts[:max], do: Map.put(cmd, :max, opts[:max]), else: cmd
    cmd = if opts[:step], do: Map.put(cmd, :step, opts[:step]), else: cmd
    cmd = if opts[:decimals], do: Map.put(cmd, :decimals, opts[:decimals]), else: cmd
    cmd = if opts[:options], do: Map.put(cmd, :options, opts[:options]), else: cmd
    cmd = if opts[:current], do: Map.put(cmd, :current, opts[:current]), else: cmd
    cmd = if opts[:echo], do: Map.put(cmd, :echo, opts[:echo]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "input_result", "ok" => true, "value" => value}} -> {:ok, value}
      {:qt_event, %{"event" => "input_result", "ok" => false}} -> {:ok, :cancelled}
    after
      60_000 -> {:error, :timeout}
    end
  end

  @doc """
  Cria um diálogo de progresso. Retorna a struct do widget.
  """
  @spec new_progress_dialog(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_progress_dialog(app, opts \\ []) do
    label = opts[:label] || "Working..."
    cancel = opts[:cancel] || "Cancel"
    min = opts[:min] || 0
    max = opts[:max] || 100
    cmd = %{name: "progress_dialog", label: label, cancel: cancel, min: min, max: max}
    cmd = if opts[:title], do: Map.put(cmd, :title, opts[:title]), else: cmd
    cmd = if opts[:auto_close] != nil, do: Map.put(cmd, :auto_close, opts[:auto_close]), else: cmd
    cmd = if opts[:auto_reset] != nil, do: Map.put(cmd, :auto_reset, opts[:auto_reset]), else: cmd
    ExQt6.App.cmd(app, cmd)

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} -> {:ok, %__MODULE__{id: id}}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Define o valor atual de um diálogo de progresso.
  """
  @spec set_progress_value(t(), ExQt6.App.t(), integer()) :: :ok
  def set_progress_value(%__MODULE__{id: id}, app, value) do
    ExQt6.App.cmd(app, %{name: "set_progress_value", id: id, value: value})
  end

  @doc """
  Define o texto de label de um diálogo de progresso.
  """
  @spec set_progress_label(t(), ExQt6.App.t(), String.t()) :: :ok
  def set_progress_label(%__MODULE__{id: id}, app, label) do
    ExQt6.App.cmd(app, %{name: "set_progress_label", id: id, label: label})
  end

  @doc """
  Define o range (min/max) de um diálogo de progresso.
  """
  @spec set_progress_range(t(), ExQt6.App.t(), integer(), integer()) :: :ok
  def set_progress_range(%__MODULE__{id: id}, app, min, max) do
    ExQt6.App.cmd(app, %{name: "set_progress_range", id: id, min: min, max: max})
  end

  @doc """
  Define o texto do botão de cancelamento de um diálogo de progresso.
  """
  @spec set_progress_cancel_text(t(), ExQt6.App.t(), String.t()) :: :ok
  def set_progress_cancel_text(%__MODULE__{id: id}, app, text) do
    ExQt6.App.cmd(app, %{name: "set_progress_cancel_text", id: id, text: text})
  end

  @doc """
  Verifica se o diálogo de progresso foi cancelado. Retorna {:ok, boolean}.
  """
  @spec is_progress_canceled(t(), ExQt6.App.t()) :: {:ok, boolean()} | {:error, :timeout}
  def is_progress_canceled(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "is_progress_canceled", id: id})

    receive do
      {:qt_event, %{"event" => "progress_canceled_result", "canceled" => canceled}} ->
        {:ok, canceled}
    after
      2000 -> {:error, :timeout}
    end
  end

  @doc """
  Exibe um widget na tela.
  """
  @spec show(t(), ExQt6.App.t()) :: :ok
  def show(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "show", id: id})
  end

  @doc """
  Define o título de uma janela.
  """
  @spec set_title(t(), ExQt6.App.t(), String.t()) :: :ok
  def set_title(%__MODULE__{id: id}, app, title) do
    ExQt6.App.cmd(app, %{name: "set_title", id: id, title: title})
  end

  @doc """
  Redimensiona uma janela para a largura e altura especificadas.
  """
  @spec resize(t(), ExQt6.App.t(), integer(), integer()) :: :ok
  def resize(%__MODULE__{id: id}, app, w, h) do
    ExQt6.App.cmd(app, %{name: "resize", id: id, w: w, h: h})
  end

  @doc """
  Define o texto de um widget.
  """
  @spec set_text(t(), ExQt6.App.t(), String.t()) :: :ok
  def set_text(%__MODULE__{id: id}, app, text) do
    ExQt6.App.cmd(app, %{name: "set_text", id: id, text: text})
  end

  @doc """
  Define o valor numérico de um widget.
  """
  @spec set_value(t(), ExQt6.App.t(), number()) :: :ok
  def set_value(%__MODULE__{id: id}, app, value) do
    ExQt6.App.cmd(app, %{name: "set_value", id: id, value: value})
  end

  @doc """
  Define o estado marcado/desmarcado de um widget.
  """
  @spec set_checked(t(), ExQt6.App.t(), boolean()) :: :ok
  def set_checked(%__MODULE__{id: id}, app, checked) do
    ExQt6.App.cmd(app, %{name: "set_checked", id: id, checked: checked})
  end

  @doc """
  Adiciona uma lista de itens a um widget (combo box, etc).
  """
  @spec add_items(t(), ExQt6.App.t(), [String.t()]) :: :ok
  def add_items(%__MODULE__{id: id}, app, items) do
    ExQt6.App.cmd(app, %{name: "add_items", id: id, items: items})
  end

  @doc """
  Obtém o texto de um widget.
  """
  @spec get_text(t(), ExQt6.App.t(), keyword()) :: {:ok, String.t()} | {:error, :timeout}
  def get_text(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_text", id: id})

    receive do
      {:qt_event, %{"event" => "text_result", "id" => ^id, "text" => text}} -> {:ok, text}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Obtém o valor numérico de um widget.
  """
  @spec get_value(t(), ExQt6.App.t(), keyword()) :: {:ok, number()} | {:error, :timeout}
  def get_value(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_value", id: id})

    receive do
      {:qt_event, %{"event" => "value_result", "id" => ^id, "value" => value}} -> {:ok, value}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Obtém o estado marcado/desmarcado de um widget.
  """
  @spec get_checked(t(), ExQt6.App.t(), keyword()) :: {:ok, boolean()} | {:error, :timeout}
  def get_checked(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_checked", id: id})

    receive do
      {:qt_event, %{"event" => "checked_result", "id" => ^id, "checked" => checked}} ->
        {:ok, checked}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Cria uma lista de itens (QListWidget).
  """
  @spec new_listwidget(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_listwidget(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_listwidget"})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :listwidget}}
      error -> error
    end
  end

  @doc """
  Adiciona um único item a um QListWidget.
  """
  @spec add_list_item(t(), ExQt6.App.t(), String.t()) :: :ok
  def add_list_item(%__MODULE__{id: id}, app, text) when is_binary(text) do
    ExQt6.App.cmd(app, %{name: "add_list_item", id: id, text: text})
  end

  @doc """
  Adiciona vários itens a um QListWidget.
  """
  @spec add_list_items(t(), ExQt6.App.t(), [String.t()]) :: :ok
  def add_list_items(%__MODULE__{id: id}, app, items) when is_list(items) do
    ExQt6.App.cmd(app, %{name: "add_list_items", id: id, items: items})
  end

  @doc """
  Remove o item na linha especificada de um QListWidget.
  """
  @spec list_remove_item(t(), ExQt6.App.t(), integer()) :: :ok
  def list_remove_item(%__MODULE__{id: id}, app, row) do
    ExQt6.App.cmd(app, %{name: "list_remove_item", id: id, row: row})
  end

  @doc """
  Define a linha atual (selecionada) de um QListWidget.
  """
  @spec set_list_current_row(t(), ExQt6.App.t(), integer()) :: :ok
  def set_list_current_row(%__MODULE__{id: id}, app, row) do
    ExQt6.App.cmd(app, %{name: "set_list_current_row", id: id, row: row})
  end

  @doc """
  Obtém a linha atual (selecionada) de um QListWidget.
  """
  @spec get_list_current_row(t(), ExQt6.App.t(), keyword()) ::
          {:ok, integer()} | {:error, :timeout}
  def get_list_current_row(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_list_current_row", id: id})

    receive do
      {:qt_event, %{"event" => "row_result", "id" => ^id, "value" => row}} -> {:ok, row}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Define o texto do item na linha especificada de um QListWidget.
  """
  @spec set_list_item_text(t(), ExQt6.App.t(), integer(), String.t()) :: :ok
  def set_list_item_text(%__MODULE__{id: id}, app, row, text) do
    ExQt6.App.cmd(app, %{name: "set_list_item_text", id: id, row: row, text: text})
  end

  @doc """
  Cria uma área de rolagem (QScrollArea) que pode conter outro widget.
  """
  @spec new_scrollarea(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_scrollarea(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_scrollarea"}
    cmd = if opts[:resizable] != nil, do: Map.put(cmd, :resizable, opts[:resizable]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :scrollarea}}
      error -> error
    end
  end

  @doc """
  Define o widget exibido dentro de um QScrollArea.
  """
  @spec scrollarea_set_widget(t(), ExQt6.App.t(), t()) :: :ok
  def scrollarea_set_widget(%__MODULE__{id: id}, app, %__MODULE__{id: child_id}) do
    ExQt6.App.cmd(app, %{name: "scrollarea_set_widget", id: id, child_id: child_id})
  end

  @doc """
  Cria uma barra de rolagem (QScrollBar) horizontal ou vertical.
  """
  @spec new_scrollbar(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_scrollbar(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_scrollbar"}
    cmd = if opts[:orientation], do: Map.put(cmd, :orientation, opts[:orientation]), else: cmd
    cmd = if opts[:min], do: Map.put(cmd, :min, opts[:min]), else: cmd
    cmd = if opts[:max], do: Map.put(cmd, :max, opts[:max]), else: cmd
    cmd = if opts[:value], do: Map.put(cmd, :value, opts[:value]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :scrollbar}}
      error -> error
    end
  end

  @doc """
  Cria um botão de ferramenta compacto (QToolButton), usualmente em toolbars.
  """
  @spec new_toolbutton(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_toolbutton(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_toolbutton"}
    cmd = if opts[:text], do: Map.put(cmd, :text, opts[:text]), else: cmd
    cmd = if opts[:style], do: Map.put(cmd, :style, opts[:style]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :toolbutton}}
      error -> error
    end
  end

  @doc """
  Define um menu com os itens fornecidos em um QToolButton.
  """
  @spec set_toolbutton_menu(t(), ExQt6.App.t(), [String.t()]) :: :ok
  def set_toolbutton_menu(%__MODULE__{id: id}, app, items) when is_list(items) do
    ExQt6.App.cmd(app, %{name: "set_toolbutton_menu", id: id, items: items})
  end

  @doc """
  Cria uma lista baseada em modelo (QListView). Os itens são definidos com `listview_set_strings/3`.
  """
  @spec new_listview(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_listview(app, _opts \\ [], timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_listview"})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :listview}}
      error -> error
    end
  end

  @doc """
  Define a lista de strings exibida em um QListView.
  """
  @spec listview_set_strings(t(), ExQt6.App.t(), list(String.t())) :: :ok
  def listview_set_strings(%__MODULE__{id: id}, app, items) do
    ExQt6.App.cmd(app, %{name: "listview_set_strings", id: id, items: items})
  end

  @doc """
  Obtém a linha atual (selecionada) de um QListView.
  """
  @spec get_listview_current(t(), ExQt6.App.t(), keyword()) ::
          {:ok, integer()} | {:error, :timeout}
  def get_listview_current(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_listview_current", id: id})

    receive do
      {:qt_event, %{"event" => "row_result", "id" => ^id, "value" => row}} -> {:ok, row}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Define a linha atual (selecionada) de um QListView.
  """
  @spec set_listview_current(t(), ExQt6.App.t(), integer()) :: :ok
  def set_listview_current(%__MODULE__{id: id}, app, row) do
    ExQt6.App.cmd(app, %{name: "set_listview_current", id: id, row: row})
  end

  @doc """
  Cria uma tabela baseada em modelo (QTableView). Células são definidas com `tableview_set_item/4`.
  """
  @spec new_tableview(ExQt6.App.t(), non_neg_integer(), non_neg_integer(), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_tableview(app, rows \\ 0, cols \\ 0, _opts \\ [], timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_tableview", rows: rows, columns: cols})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :tableview}}
      error -> error
    end
  end

  @doc """
  Define o texto de uma célula em um QTableView.
  """
  @spec tableview_set_item(t(), ExQt6.App.t(), non_neg_integer(), non_neg_integer(), String.t()) ::
          :ok
  def tableview_set_item(%__MODULE__{id: id}, app, row, col, text) do
    ExQt6.App.cmd(app, %{name: "tableview_set_item", id: id, row: row, column: col, text: text})
  end

  @doc """
  Define os cabeçalhos das colunas de um QTableView.
  """
  @spec tableview_set_headers(t(), ExQt6.App.t(), list(String.t())) :: :ok
  def tableview_set_headers(%__MODULE__{id: id}, app, headers) do
    ExQt6.App.cmd(app, %{name: "tableview_set_headers", id: id, headers: headers})
  end

  @doc """
  Cria uma caixa de ferramentas (QToolBox) com itens empilhados.
  """
  @spec new_toolbox(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_toolbox(app, _opts \\ [], timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_toolbox"})

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :toolbox}}
      error -> error
    end
  end

  @doc """
  Adiciona um item (widget) a um QToolBox com o rótulo especificado.
  """
  @spec toolbox_add_item(t(), ExQt6.App.t(), ExQt6.Widget.t(), String.t()) :: :ok
  def toolbox_add_item(%__MODULE__{id: id}, app, %ExQt6.Widget{id: widget_id}, label) do
    ExQt6.App.cmd(app, %{
      name: "toolbox_add_item",
      id: id,
      widget_id: widget_id,
      label: label
    })
  end

  @doc """
  Cria um editor de tempo (QTimeEdit), restrito a hora/minuto/segundo.
  """
  @spec new_timeedit(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_timeedit(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_timeedit"}
    cmd = if opts[:format], do: Map.put(cmd, :format, opts[:format]), else: cmd
    cmd = if opts[:time], do: Map.put(cmd, :time, opts[:time]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :timeedit}}
      error -> error
    end
  end

  @doc """
  Cria um editor de data (QDateEdit), restrito a ano/mês/dia.
  """
  @spec new_dateedit(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_dateedit(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_dateedit"}
    cmd = if opts[:format], do: Map.put(cmd, :format, opts[:format]), else: cmd
    cmd = if opts[:date], do: Map.put(cmd, :date, opts[:date]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :dateedit}}
      error -> error
    end
  end

  @doc """
  Cria um combo box de fontes (QFontComboBox) listando as fontes do sistema.
  """
  @spec new_fontcombobox(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def new_fontcombobox(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_fontcombobox"}
    cmd = if opts[:font], do: Map.put(cmd, :font, opts[:font]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :fontcombobox}}
      error -> error
    end
  end

  @doc """
  Obtém a fonte (family) atual selecionada em um QFontComboBox.
  """
  @spec get_fontcombobox_current(t(), ExQt6.App.t(), keyword()) ::
          {:ok, String.t()} | {:error, :timeout}
  def get_fontcombobox_current(%__MODULE__{id: id}, app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "get_fontcombobox_current", id: id})

    receive do
      {:qt_event, %{"event" => "font_result", "id" => ^id, "value" => family}} ->
        {:ok, family}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Cria um botão de comando (QCommandLinkButton) com texto e descrição opcional.
  """
  @spec new_commandlinkbutton(ExQt6.App.t(), String.t(), keyword()) ::
          {:ok, t()} | {:error, :timeout}
  def new_commandlinkbutton(app, text, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_commandlinkbutton", text: text}
    cmd = if opts[:description], do: Map.put(cmd, :description, opts[:description]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_widget_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id, type: :commandlinkbutton}}
      error -> error
    end
  end

  @doc """
  Define a descrição de um QCommandLinkButton.
  """
  @spec set_commandlink_description(t(), ExQt6.App.t(), String.t()) :: :ok
  def set_commandlink_description(%__MODULE__{id: id}, app, text) do
    ExQt6.App.cmd(app, %{name: "set_commandlink_description", id: id, text: text})
  end
end

defmodule ExQt6.Timer do
  @moduledoc """
  Qt timer for periodic events.
  """

  defstruct [:id]

  @type t :: %__MODULE__{id: integer()}

  @doc """
  Cria um novo timer Qt com o intervalo em milissegundos.
  """
  @spec new(ExQt6.App.t(), integer(), integer()) :: {:ok, t()} | {:error, :timeout}
  def new(app, interval_ms \\ 1000, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_timer", interval: interval_ms})

    receive do
      {:qt_event, %{"event" => "widget_created", "id" => id}} -> {:ok, %__MODULE__{id: id}}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Inicia a contagem do timer.
  """
  @spec start(t(), ExQt6.App.t()) :: :ok
  def start(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "start_timer", id: id})
  end

  @doc """
  Para a contagem do timer.
  """
  @spec stop(t(), ExQt6.App.t()) :: :ok
  def stop(%__MODULE__{id: id}, app) do
    ExQt6.App.cmd(app, %{name: "stop_timer", id: id})
  end

  @doc """
  Define o intervalo do timer em milissegundos.
  """
  @spec set_interval(t(), ExQt6.App.t(), integer()) :: :ok
  def set_interval(%__MODULE__{id: id}, app, interval_ms) do
    ExQt6.App.cmd(app, %{name: "set_timer_interval", id: id, interval: interval_ms})
  end
end

defmodule ExQt6.Layout do
  @moduledoc """
  Layout management (VBox, HBox, Grid, Form).
  """

  defstruct [:id]

  @type t :: %__MODULE__{id: integer()}

  defp await_layout_created(timeout \\ 2000) do
    receive do
      {:qt_event, %{"event" => "layout_created", "id" => id}} -> {:ok, id}
    after
      timeout -> {:error, :timeout}
    end
  end

  @doc """
  Cria um novo layout vertical (QVBoxLayout).
  """
  @spec vbox(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def vbox(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_vbox"})

    case await_layout_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id}}
      error -> error
    end
  end

  @doc """
  Cria um novo layout horizontal (QHBoxLayout).
  """
  @spec hbox(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def hbox(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_hbox"})

    case await_layout_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id}}
      error -> error
    end
  end

  @doc """
  Define o layout de um widget.
  """
  @spec set_layout(t(), ExQt6.App.t(), ExQt6.Widget.t()) :: :ok
  def set_layout(%__MODULE__{id: layout_id}, app, %ExQt6.Widget{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "set_layout", widget_id: widget_id, layout_id: layout_id})
  end

  @doc """
  Adiciona um widget a um layout.
  """
  @spec add(t(), ExQt6.App.t(), ExQt6.Widget.t()) :: :ok
  def add(%__MODULE__{id: layout_id}, app, %ExQt6.Widget{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "add_widget", layout_id: layout_id, widget_id: widget_id})
  end

  @doc """
  Adiciona um layout filho a um layout pai.
  """
  @spec add_layout(t(), ExQt6.App.t(), t()) :: :ok
  def add_layout(%__MODULE__{id: layout_id}, app, %__MODULE__{id: child_layout_id}) do
    ExQt6.App.cmd(app, %{
      name: "add_layout",
      layout_id: layout_id,
      child_layout_id: child_layout_id
    })
  end

  @doc """
  Cria um novo layout de grade (QGridLayout) com opções de linhas, colunas e espaçamento.
  """
  @spec grid(ExQt6.App.t(), keyword(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def grid(app, opts \\ [], timeout \\ 2000) do
    cmd = %{name: "create_grid"}
    cmd = if opts[:rows], do: Map.put(cmd, :rows, opts[:rows]), else: cmd
    cmd = if opts[:columns], do: Map.put(cmd, :columns, opts[:columns]), else: cmd
    cmd = if opts[:margin], do: Map.put(cmd, :margin, opts[:margin]), else: cmd
    cmd = if opts[:spacing], do: Map.put(cmd, :spacing, opts[:spacing]), else: cmd
    ExQt6.App.cmd(app, cmd)

    case await_layout_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id}}
      error -> error
    end
  end

  @doc """
  Adiciona um widget a uma grade na posição especificada com span opcional.
  """
  @spec grid_add_widget(t(), ExQt6.App.t(), ExQt6.Widget.t(), integer(), integer(), keyword()) ::
          :ok
  def grid_add_widget(
        %__MODULE__{id: layout_id},
        app,
        %ExQt6.Widget{id: widget_id},
        row,
        col,
        opts \\ []
      ) do
    cmd = %{
      name: "grid_add_widget",
      layout_id: layout_id,
      widget_id: widget_id,
      row: row,
      column: col
    }

    cmd = if opts[:row_span], do: Map.put(cmd, :row_span, opts[:row_span]), else: cmd
    cmd = if opts[:col_span], do: Map.put(cmd, :col_span, opts[:col_span]), else: cmd
    ExQt6.App.cmd(app, cmd)
  end

  @doc """
  Adiciona um layout filho a uma grade na posição especificada.
  """
  @spec grid_add_layout(t(), ExQt6.App.t(), t(), integer(), integer()) :: :ok
  def grid_add_layout(%__MODULE__{id: layout_id}, app, %__MODULE__{id: child_id}, row, col) do
    ExQt6.App.cmd(app, %{
      name: "grid_add_layout",
      layout_id: layout_id,
      child_layout_id: child_id,
      row: row,
      column: col
    })
  end

  @doc """
  Cria um novo layout de formulário (QFormLayout).
  """
  @spec form(ExQt6.App.t(), keyword()) :: {:ok, t()} | {:error, :timeout}
  def form(app, timeout \\ 2000) do
    ExQt6.App.cmd(app, %{name: "create_form"})

    case await_layout_created(timeout) do
      {:ok, id} -> {:ok, %__MODULE__{id: id}}
      error -> error
    end
  end

  @doc """
  Adiciona uma linha ao layout de formulário com um rótulo de texto.
  """
  @spec form_add_row(t(), ExQt6.App.t(), String.t(), ExQt6.Widget.t()) :: :ok
  def form_add_row(%__MODULE__{id: layout_id}, app, label, %ExQt6.Widget{id: widget_id})
      when is_binary(label) do
    ExQt6.App.cmd(app, %{
      name: "form_add_row",
      layout_id: layout_id,
      widget_id: widget_id,
      label: label
    })
  end

  @doc """
  Adiciona uma linha ao layout de formulário sem rótulo.
  """
  @spec form_add_row(t(), ExQt6.App.t(), ExQt6.Widget.t()) :: :ok
  def form_add_row(%__MODULE__{id: layout_id}, app, %ExQt6.Widget{id: widget_id}) do
    ExQt6.App.cmd(app, %{name: "form_add_row", layout_id: layout_id, widget_id: widget_id})
  end

  @doc """
  Adiciona uma linha ao layout de formulário usando um widget como rótulo.
  """
  @spec form_add_row_widget(t(), ExQt6.App.t(), ExQt6.Widget.t(), ExQt6.Widget.t()) :: :ok
  def form_add_row_widget(
        %__MODULE__{id: layout_id},
        app,
        %ExQt6.Widget{id: label_id},
        %ExQt6.Widget{id: widget_id}
      ) do
    ExQt6.App.cmd(app, %{
      name: "form_add_row_widget",
      layout_id: layout_id,
      label_widget_id: label_id,
      widget_id: widget_id
    })
  end
end
