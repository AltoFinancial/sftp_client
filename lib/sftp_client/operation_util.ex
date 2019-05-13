defmodule SFTPClient.OperationUtil do
  @moduledoc """
  A utility module that intends to be imported by operation modules.
  """

  alias SFTPClient.Conn
  alias SFTPClient.ConnError
  alias SFTPClient.InvalidOptionError
  alias SFTPClient.OperationError

  @sftp_adapter Application.get_env(:sftp_client, :sftp_adapter, :ssh_sftp)
  @ssh_adapter Application.get_env(:sftp_client, :ssh_adapter, :ssh)

  @doc """
  Gets the configured SFTP adapter. Defaults to the Erlang `:ssh_sftp` module.
  """
  @spec sftp_adapter() :: module
  def sftp_adapter, do: @sftp_adapter

  @doc """
  Gets the configured SSH adapter. Defaults to the Erlang `:ssh` module.
  """
  @spec ssh_adapter() :: module
  def ssh_adapter, do: @ssh_adapter

  @doc """
  Converts the result of a non-bang function so that the result is returned or
  an exception is raised on error.
  """
  @spec may_bang!(:ok | {:ok | :error, any}) :: any | no_return
  def may_bang!(result)

  def may_bang!(:ok), do: :ok

  def may_bang!({:ok, result}), do: result

  def may_bang!({:error, %{__exception__: _} = error}), do: raise(error)

  def may_bang!({:error, error}) do
    raise("Unexpected error: #{inspect(error)}")
  end

  @doc """
  A function which converts all errors that can occur when an SFTP operation
  fails into a matching exception struct.
  """
  @spec handle_error(any) ::
          ConnError.t() | InvalidOptionError.t() | OperationError.t()
  def handle_error(error)

  def handle_error({:eoptions, {{key, value}, reason}}) do
    %InvalidOptionError{key: key, value: load_opt_value(value), reason: reason}
  end

  def handle_error(reason) when is_atom(reason) do
    %OperationError{reason: reason}
  end

  def handle_error(message) do
    %ConnError{message: to_string(message)}
  end

  defp load_opt_value(value) when is_list(value), do: to_string(value)
  defp load_opt_value(value), do: value

  @doc """
  Uses the given conn or builds up a connection with the given config that is
  closed after the callback has run.
  """
  @spec with_connection(
          Config.t() | Conn.t() | Keyword.t() | %{optional(atom) => any},
          (Conn.t() -> res)
        ) :: res when res: var
  def with_connection(config_or_conn_or_opts)

  def with_connection(%Conn{} = conn, fun), do: fun.(conn)

  def with_connection(config_or_opts, fun) do
    with {:ok, conn} <- SFTPClient.connect(config_or_opts) do
      try do
        fun.(conn)
      after
        SFTPClient.disconnect(conn)
      end
    end
  end

  @doc """
  Uses the given conn or builds up a connection with the given config that is
  closed after the callback has run. Raises on error.
  """
  @spec with_connection!(
          Config.t() | Conn.t() | Keyword.t() | %{optional(atom) => any},
          (Conn.t() -> res)
        ) :: res when res: var
  def with_connection!(config_or_conn_or_opts)

  def with_connection!(%Conn{} = conn, fun), do: fun.(conn)

  def with_connection!(config_or_opts, fun) do
    conn = SFTPClient.connect!(config_or_opts)

    try do
      fun.(conn)
    after
      SFTPClient.disconnect(conn)
    end
  end
end
