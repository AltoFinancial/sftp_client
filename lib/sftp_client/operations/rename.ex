defmodule SFTPClient.Operations.Rename do
  @moduledoc """
  A module that provides functions to rename files and directories on an SFTP
  server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn

  @doc """
  Renames a file named `old_path` and gives it the name specified by `new_path`.
  """
  @spec rename(Conn.t() | SFTPClient.conn_args(), Path.t(), Path.t()) ::
          :ok | {:error, SFTPClient.error()}
  def rename(config_or_conn_or_opts, old_path, new_path) do
    with_connection(config_or_conn_or_opts, &do_rename(&1, old_path, new_path))
  end

  defp do_rename(conn, old_path, new_path) do
    conn.channel_pid
    |> sftp_adapter().rename(
      to_charlist(old_path),
      to_charlist(new_path),
      conn.config.operation_timeout
    )
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Renames a file named `old_name` and gives it the name specified by `new_name`.
  Raises when the operation fails.
  """
  @spec rename!(Conn.t() | SFTPClient.conn_args(), Path.t(), Path.t()) ::
          :ok | no_return
  def rename!(config_or_conn_or_opts, old_path, new_path) do
    config_or_conn_or_opts
    |> rename(old_path, new_path)
    |> may_bang!()
  end
end
