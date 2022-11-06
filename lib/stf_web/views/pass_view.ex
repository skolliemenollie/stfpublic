defmodule StfWeb.SendView do
  use StfWeb, :view
  alias StfWeb.PassView

  def render("result.json", %{result: result}) do
    result
  end
end
