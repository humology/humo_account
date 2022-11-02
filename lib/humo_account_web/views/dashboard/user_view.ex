defmodule HumoAccountWeb.Dashboard.UserView do
  use HumoAccountWeb, :view

  def format_datetime(datetime) do
    Calendar.strftime(datetime, "%a %d.%m.%y %H:%S")
  end
end
