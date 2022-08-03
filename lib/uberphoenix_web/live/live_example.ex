defmodule UberphoenixWeb.ExampleLive do
  use UberphoenixWeb, :live_view

  alias Uberphoenix.Examples

  def mount(_params, _session, socket) do
    examples = get_examples() |> create_changeset()

    socket
    |> assign(:sum, get_sum(examples))
    |> assign(:changeset, examples)
    |> (&{:ok, &1}).()
  end

  def render(assigns) do
    UberphoenixWeb.PageView.render("example.html", assigns)
  end

  defp create_changeset(examples) do
    examples
    |> Enum.map(&tuple_to_example_map/1)
    |> (&Examples.changeset(%Examples{}, %{examples: &1})).()
  end

  defp get_sum(list) do
    list
    |> Ecto.Changeset.get_field(:examples)
    |> Enum.reduce(0.0, &sum_active/2)
    |> :erlang.float_to_binary(decimals: 2)
  end

  defp sum_active(%{is_active: false}, acc), do: acc
  defp sum_active(%{amount: amount}, acc), do: acc + amount

  defp tuple_to_example_map({index, name, amount}, is_active \\ true) do
    %{
      example_id: index,
      name: name,
      amount: String.to_float(amount),
      is_active: is_active
    }
  end

  def handle_event("change_active", params, socket) do
    socket
    |> update_examples(params)
    |> (&{:noreply, &1}).()
  end

  def handle_event("sortby", %{"sortby" => field}, socket) do
    socket
    |> sort_by_field(field)
    |> (&{:noreply, &1}).()
  end

  def handle_event(a, b, socket) do
    a |> IO.inspect()
    b |> IO.inspect()
    {:noreply, socket}
  end

  defp update_examples(socket, params) do
    form_examples =
      params
      |> get_in(["examples", "examples"])
      |> Map.values()

    updated_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:examples)
      |> Enum.map(&update_active_state(&1, form_examples))
      |> (&Examples.changeset(socket.assigns.changeset, %{examples: &1})).()

    socket
    |> assign(:changeset, updated_changeset)
    |> assign(:sum, get_sum(updated_changeset))
  end

  defp update_active_state(%{example_id: id} = example, form_examples) do
    form_examples
    |> Enum.find(fn %{"example_id" => eid} -> id === eid end)
    |> (&Map.put(example, :is_active, &1["is_active"] === "true")).()
    |> Map.from_struct()
  end

  defp sort_by_field(socket, "name"), do: sort_by(socket, :name)
  defp sort_by_field(socket, "active"), do: sort_by(socket, :is_active)
  defp sort_by_field(socket, "amount"), do: sort_by(socket, :amount)
  defp sort_by_field(socket, _), do: socket

  defp sort_by(socket, field) do
    socket
    |> assign_order(field)
    |> sort_changeset(field)
  end

  defp assign_order(socket, field) do
    if socket.assigns[:order_by] === field do
      socket |> change_order()
    else
      socket
      |> assign(:order, :desc)
      |> assign(:order_by, field)
    end
  end

  defp change_order(%{assigns: %{order: :asc}} = socket), do: assign(socket, :order, :desc)
  defp change_order(%{assigns: %{order: :desc}} = socket), do: assign(socket, :order, :asc)
  defp change_order(socket), do: assign(socket, :order, :desc)

  defp sort_changeset(socket, field) do
    sorted_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:examples)
      |> Enum.map(&Map.from_struct/1)
      |> Enum.sort_by(fn example -> example[field] end, socket.assigns.order)
      |> (&Examples.changeset(socket.assigns.changeset, %{examples: &1})).()

    assign(socket, :changeset, sorted_changeset)
  end

  defp get_examples() do
    [
      {"1", "example1", "100.00"},
      {"2", "example2", "110.00"},
      {"3", "example3", "111.00"},
      {"4", "example4", "111.10"},
      {"5", "example5", "111.11"}
    ]
  end
end
