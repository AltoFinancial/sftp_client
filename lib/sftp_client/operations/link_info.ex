defmodule SFTPClient.Operations.LinkInfo do
  @moduledoc """
  A module that provides functions to retrieve information on symbolic links
  from an SFTP server.
  """

  import SFTPClient.OperationUtil

  alias File.Stat, as: FileStat
  alias SFTPClient.Conn

  @doc """
  Returns a `File.Stat` struct from the remote symbolic link object specified by
  path.
  """
  @spec link_info(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          {:ok, FileStat.t()} | {:error, SFTPClient.error()}
  def link_info(config_or_conn_or_opts, path) do
    with_connection(config_or_conn_or_opts, &get_link_info(&1, path))
  end

  defp get_link_info(conn, path) do
    conn.channel_pid
    |> sftp_adapter().read_link_info(
      to_charlist(path),
      conn.config.operation_timeout
    )
    |> case do
      {:ok, link_info} -> {:ok, FileStat.from_record(link_info)}
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Returns a `File.Stat` struct from the remote symbolic link object specified by
  path. Raises when the operation fails.
  """
  @spec link_info!(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          FileStat.t() | no_return
  def link_info!(config_or_conn_or_opts, path) do
    config_or_conn_or_opts |> link_info(path) |> may_bang!()
  end
end
