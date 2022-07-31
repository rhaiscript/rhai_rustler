defmodule Evalexpr do
  use Rustler, otp_app: :evalexpr_rustler, crate: "evalexpr_rustler"

  # When your NIF is loaded, it will override this function.
  def eval(_, _), do: :erlang.nif_error(:nif_not_loaded)
end
