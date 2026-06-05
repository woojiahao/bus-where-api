defmodule BusWhereApiWeb.Controllers.FallbackController do
  use BusWhereApiWeb, :controller

  def call(conn, {:error, %BusWhereApi.Error{} = err}) do
    status = to_http_status(err.code)

    conn
    |> put_status(status)
    |> json(%{
      error: %{
        code: err.code,
        message: err.message,
        details: err.details
      }
    })
  end

  def call(conn, {:error, :bad_request}) do
    # TODO: This should not happen so we should safely log error

    status = to_http_status(:bad_request)

    conn
    |> put_status(status)
    |> json(%{
      error: %{
        code: :bad_request,
        message: "Bad request. Contact the adminstrator"
      }
    })
  end

  defp to_http_status(:bad_request), do: 400
  defp to_http_status(:not_found), do: 404
  defp to_http_status(:external_failure), do: 502
  defp to_http_status(_), do: 500
end
