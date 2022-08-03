defmodule UberphoenixWeb.PageController do
  use UberphoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
