defmodule SFTPClient.Operations.MakeDir do
  @moduledoc """
  A module that provides functions to create directories on an SFTP server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn

  @doc """
  Creates a directory specified by path. The path must be a full path to a new
  directory. The directory can only be created in an existing directory.
  """
  @spec make_dir(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          :ok | {:error, SFTPClient.error()}
  def make_dir(config_or_conn_or_opts, path) do
    with_connection(config_or_conn_or_opts, &do_make_dir(&1, path))
  end

  defp do_make_dir(conn, path) do
    conn.channel_pid
    |> sftp_adapter().make_dir(to_charlist(path), conn.config.operation_timeout)
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Creates a directory specified by path. The path must be a full path to a new
  directory. The directory can only be created in an existing directory. Raises
  when the operation fails.
  """
  @spec make_dir!(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          :ok | no_return
  def make_dir!(config_or_conn_or_opts, path) do
    config_or_conn_or_opts
    |> make_dir(path)
    |> may_bang!()
  end
end
