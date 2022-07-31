defmodule EvalexprRustlerTest do
  use ExUnit.Case
  doctest EvalexprRustler

  test "greets the world" do
    assert EvalexprRustler.hello() == :world
  end
end
