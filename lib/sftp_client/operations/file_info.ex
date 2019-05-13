defmodule SFTPClient.Operations.FileInfo do
  @moduledoc """
  A module that provides functions to retrieve information on files and
  directories from an SFTP server.
  """

  import SFTPClient.OperationUtil

  alias File.Stat, as: FileStat
  alias SFTPClient.Conn

  @doc """
  Returns a `File.Stat` struct from the remote file system object specified by
  path.
  """
  @spec file_info(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          {:ok, FileStat.t()} | {:error, SFTPClient.error()}
  def file_info(config_or_conn_or_opts, path) do
    with_connection(config_or_conn_or_opts, &get_file_info(&1, path))
  end

  defp get_file_info(conn, path) do
    conn.channel_pid
    |> sftp_adapter().read_file_info(
      to_charlist(path),
      conn.config.operation_timeout
    )
    |> case do
      {:ok, file_info} -> {:ok, FileStat.from_record(file_info)}
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Returns a `File.Stat` struct from the remote file system object specified by
  path. Raises when the operation fails.
  """
  @spec file_info!(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          FileStat.t() | no_return
  def file_info!(config_or_conn_or_opts, path) do
    config_or_conn_or_opts
    |> file_info(path)
    |> may_bang!()
  end
end
