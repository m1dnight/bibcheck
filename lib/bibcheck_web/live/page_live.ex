defmodule BibcheckWeb.PageLive do
  use BibcheckWeb, :live_view
  require Logger

  @testdata """
  @book{DBLP:books/daglib/0035693,
  author    = {Chris MacCord},
  title     = {Metaprogramming Elixir - Write Less Code, Get More Done (and Have
               Fun!)},
  series    = {The pragmatic programmers},
  publisher = {O'Reilly},
  year      = {},
  url       = {http://www.oreilly.de/catalog/9781680500417/index.html},
  isbn      = {978-1-680-50041-7},
  timestamp = {Thu, 11 Jun 2015 16:44:23 +0200},
  biburl    = {https://dblp.org/rec/books/daglib/0035693.bib},
  bibsource = {dblp computer science bibliography, https://dblp.org}
  }
  """
  @impl true
  def mount(_params, _session, socket) do
    bibtex_document = @testdata
    errors = BibtexParser.check_string(bibtex_document)

    document_issues = errors |> Enum.filter(fn {e, _} -> is_atom(e) end)
    socket = assign(socket, :document_issues, document_issues)

    entry_issues = errors |> Enum.filter(fn {e, _} -> is_bitstring(e) end)
    socket = assign(socket, :entry_issues, entry_issues)

    socket = assign(socket, :bibtex_document, bibtex_document)
    Logger.error(inspect(entry_issues))

    entries = BibtexParser.parse_string(bibtex_document)
    entries = entries |> Enum.map(fn e -> {e.label, e} end) |> Enum.into(%{})
    socket = assign(socket, :entries, entries)

    {:ok, socket}
  end

  @impl true
  def handle_event("check", %{"bibtex_text" => %{"bibtex_input" => content}}, socket) do
    socket = assign(socket, :bibtex_document, content)
    errors = BibtexParser.check_string(content)

    document_issues = errors |> Enum.filter(fn {e, _} -> is_atom(e) end)
    socket = assign(socket, :document_issues, document_issues)

    entry_issues = errors |> Enum.filter(fn {e, _} -> is_bitstring(e) end)
    socket = assign(socket, :entry_issues, entry_issues)

    entries = BibtexParser.parse_string(content)
    entries = entries |> Enum.map(fn e -> {e.label, e} end) |> Enum.into(%{})
    socket = assign(socket, :entries, entries)

    {:noreply, socket}
  end

  @impl true
  def handle_event("format", _, socket) do
    content = socket.assigns.bibtex_document
    formatted = content |> BibtexParser.parse_string() |> BibtexParser.Writer.to_string()
    socket = assign(socket, :bibtex_document, formatted)
    {:noreply, socket}
  end

  def title(entries, label) do
    found =
      entries
      |> Map.get(label, nil)

    case found do
      nil ->
        nil

      e ->
        Keyword.get(e.tags, :title, nil)
    end
  end

  def pretty_error_name(error_name) do
    case error_name do
      :duplicate_titles ->
        "Duplicate titles"

      :duplicate_labels ->
        "Duplicate labels"

      :empty_tags ->
        "Empty tags"

      _ ->
        "Unknown error"
    end
  end

  def summarize_entry({entry, issues}) do
    entry = entry

    issues =
      issues
      |> Enum.map(&pretty_print_entry_issue/1)

    {entry, issues}
  end

  def pretty_print_entry_issue(issue) do
    case issue do
      {:empty_tags, tags} ->
        tag_strs = tags |> Enum.map(&Atom.to_string/1) |> Enum.join(", ")
        "Empty tags: #{tag_strs}"

      {:abbreviated_journal_title, title} ->
        "Abbreviated journal title: #{title}"

      {:missing_tags, tags} ->
        tag_strs = tags |> Enum.join(", ")
        "Missing required tags: #{tag_strs}"

      _ ->
        inspect(issue)
    end
  end
end
