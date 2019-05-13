defmodule SFTPClient.Operations.DeleteFile do
  @moduledoc """
  A module containing operations to delete a file from the remote server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn

  @doc """
  Deletes the file specified by path.
  """
  @spec delete_file(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          :ok | {:error, SFTPClient.error()}
  def delete_file(config_or_conn_or_opts, path) do
    with_connection(config_or_conn_or_opts, &do_delete_file(&1, path))
  end

  defp do_delete_file(conn, path) do
    conn.channel_pid
    |> sftp_adapter().delete(to_charlist(path), conn.config.operation_timeout)
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Deletes the file specified by path. Raises when the operation fails.
  """
  @spec delete_file!(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          :ok | no_return
  def delete_file!(config_or_conn_or_opts, path) do
    config_or_conn_or_opts
    |> delete_file(path)
    |> may_bang!()
  end
end
