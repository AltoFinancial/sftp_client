defmodule SFTPClient.Operations.MakeLink do
  @moduledoc """
  A module that provides functions to create symlinks on an SFTP server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn

  @doc """
  Creates a symbolic link pointing to `target_path` with the name
  `symlink_path`.
  """
  @spec make_link(Conn.t() | SFTPClient.conn_args(), Path.t(), Path.t()) ::
          :ok | {:error, SFTPClient.error()}
  def make_link(config_or_conn_or_opts, symlink_path, target_path) do
    with_connection(
      config_or_conn_or_opts,
      &do_make_link(&1, symlink_path, target_path)
    )
  end

  defp do_make_link(conn, symlink_path, target_path) do
    conn.channel_pid
    |> sftp_adapter().make_link(
      to_charlist(symlink_path),
      to_charlist(target_path),
      conn.config.operation_timeout
    )
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Creates a symbolic link pointing to `target_path` with the name
  `symlink_path`. Raises when the operation fails.
  """
  @spec make_link!(Conn.t() | SFTPClient.conn_args(), Path.t(), Path.t()) ::
          :ok | no_return
  def make_link!(config_or_conn_or_opts, symlink_path, target_path) do
    config_or_conn_or_opts
    |> make_link(symlink_path, target_path)
    |> may_bang!()
  end
end
