defmodule SFTPClient.Operations.WriteFile do
  @moduledoc """
  A module that provides functions to write file contents to an SFTP server.
  """

  import SFTPClient.OperationUtil

  alias SFTPClient.Conn

  @doc """
  Reads a file from the server, and returns the data as String.
  """
  @spec write_file(
          Conn.t() | SFTPClient.conn_args(),
          Path.t(),
          binary | [binary]
        ) :: :ok | {:error, SFTPClient.error()}
  def write_file(config_or_conn_or_opts, path, data) when is_binary(data) do
    write_file(config_or_conn_or_opts, path, [data])
  end

  def write_file(config_or_conn_or_opts, path, iolist) do
    with_connection(config_or_conn_or_opts, &do_write_file(&1, path, iolist))
  end

  defp do_write_file(conn, path, iolist) do
    conn.channel_pid
    |> sftp_adapter().write_file(
      to_charlist(path),
      Enum.to_list(iolist),
      conn.config.operation_timeout
    )
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, handle_error(error)}
    end
  end

  @doc """
  Reads a file from the server, and returns the data as String. Raises when the
  operation fails.
  """
  @spec write_file!(
          Conn.t() | SFTPClient.conn_args(),
          Path.t(),
          binary | [binary]
        ) :: :ok | no_return
  def write_file!(config_or_conn_or_opts, path, data) do
    config_or_conn_or_opts
    |> write_file(path, data)
    |> may_bang!()
  end
end
