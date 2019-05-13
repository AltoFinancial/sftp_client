defmodule SFTPClient.Operations.DownloadFile do
  @moduledoc """
  A module that provides functions to download files from an SFTP server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn
  alias SFTPClient.ConnError
  alias SFTPClient.InvalidOptionError
  alias SFTPClient.OperationError

  @doc """
  Downloads a file from the remote path and stores it in the given local path.
  When the local path is a directory, the file name of the local file is
  inferred from the remote path.
  """
  @spec download_file(
          Conn.t() | SFTPClient.conn_args(),
          Path.t(),
          Path.t()
        ) :: {:ok, Path.t()} | {:error, SFTPClient.error()}
  def download_file(config_or_conn_or_opts, remote_path, local_path) do
    {:ok, download_file!(config_or_conn_or_opts, remote_path, local_path)}
  rescue
    error in [ConnError, InvalidOptionError, OperationError] ->
      {:error, error}
  end

  @doc """
  Downloads a file from the remote path and stores it in the given local path.
  When the local path is a directory, the file name of the local file is
  inferred from the remote path. Raises when the operation fails.
  """
  @spec download_file!(
          Conn.t() | SFTPClient.conn_args(),
          Path.t(),
          Path.t()
        ) :: Path.t() | no_return
  def download_file!(config_or_conn_or_opts, remote_path, local_path) do
    with_connection!(
      config_or_conn_or_opts,
      &do_download_file(&1, remote_path, local_path)
    )
  end

  defp do_download_file(conn, remote_path, local_path) do
    local_path = get_local_path(local_path, remote_path)
    source_stream = SFTPClient.stream_file!(conn, remote_path)
    target_stream = File.stream!(local_path)

    source_stream
    |> Stream.into(target_stream)
    |> Stream.run()

    local_path
  end

  defp get_local_path(local_path, remote_path) do
    if File.dir?(local_path) do
      Path.join(local_path, Path.basename(remote_path))
    else
      ensure_store_path_exists!(local_path)
      local_path
    end
  end

  defp ensure_store_path_exists!(local_path) do
    local_path
    |> Path.dirname()
    |> File.mkdir_p!()
  end
end
