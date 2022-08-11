defmodule EvalEx do
  use Rustler, otp_app: :evalex, crate: "evalex"

  # When your NIF is loaded, it will override this function.
  def eval(_, _), do: :erlang.nif_error(:nif_not_loaded)
end
