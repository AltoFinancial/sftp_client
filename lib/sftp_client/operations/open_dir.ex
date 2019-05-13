defmodule SFTPClient.Operations.OpenDir do
  @moduledoc """
  A module that provides functions to open a directory on an SFTP server in
  order to list their contents.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn
  alias SFTPClient.Handle

  @doc """
  Opens a handle to a directory on the server. The handle can be used for
  reading directory contents.
  """
  @spec open_dir(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          {:ok, Handle.t()} | {:error, SFTPClient.error()}
  def open_dir(config_or_conn_or_opts, path) do
    with_connection(config_or_conn_or_opts, &do_open_dir(&1, path))
  end

  defp do_open_dir(conn, path) do
    conn.channel_pid
    |> sftp_adapter().opendir(to_charlist(path), conn.config.operation_timeout)
    |> case do
      {:ok, handle} ->
        {:ok, %Handle{id: handle, conn: conn, path: to_string(path)}}

      {:error, error} ->
        {:error, handle_error(error)}
    end
  end

  @doc """
  Opens a handle to a directory on the server. The handle can be used for
  reading directory contents. Then runs the function and closes the handle when
  finished.
  """
  @spec open_dir(Conn.t() | SFTPClient.conn_args(), Path.t(), (Handle.t() -> res)) ::
          {:ok, res} | {:error, SFTPClient.error()}
        when res: var
  def open_dir(config_or_conn_or_opts, path, fun) do
    with_connection(config_or_conn_or_opts, fn conn ->
      with {:ok, handle} <- do_open_dir(conn, path) do
        {:ok, run_callback(handle, fun)}
      end
    end)
  end

  @doc """
  Opens a handle to a directory on the server. The handle can be used for
  reading directory contents. Raises when the operation fails.
  """
  @spec open_dir!(Conn.t() | SFTPClient.conn_args(), Path.t()) ::
          Handle.t() | no_return
  def open_dir!(config_or_conn_or_opts, path) do
    config_or_conn_or_opts
    |> open_dir(path)
    |> may_bang!()
  end

  @doc """
  Opens a handle to a directory on the server. The handle can be used for
  reading directory contents. Then runs the function and closes the handle when
  finished. Raises when the operation fails.
  """
  @spec open_dir!(
          Conn.t() | SFTPClient.conn_args(), Path.t(), (Handle.t() -> res)
        ) :: res | no_return when res: var
  def open_dir!(config_or_conn_or_opts, path, fun) do
    config_or_conn_or_opts
    |> open_dir!(path)
    |> run_callback(fun)
  end

  defp run_callback(handle, fun) do
    fun.(handle)
  after
    SFTPClient.close_handle(handle)
  end
end
