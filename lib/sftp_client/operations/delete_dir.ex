defmodule SFTPClient.Operations.DeleteDir do
  @moduledoc """
  A module containing operations to delete a directory from the remote server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Config
  alias SFTPClient.Conn

  @doc """
  Deletes the directory specified by path.
  """
  @spec delete_dir(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          :ok | {:error, SFTPClient.error()}
  def delete_dir(config_or_conn_or_opts, path) do
    with_connection(config_or_conn, &do_delete_dir(&1, path))
  end

  defp do_delete_dir(conn, path) do
    conn.channel_pid
    |> sftp_adapter().del_dir(to_charlist(path), conn.config.operation_timeout)
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Deletes the directory specified by path. Raises when the operation fails.
  """
  @spec delete_dir!(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          :ok | no_return
  def delete_dir!(config_or_conn_or_opts, path) do
    config_or_conn_or_opts
    |> delete_dir(path)
    |> may_bang!()
  end
end
