defmodule EvalExTest do
  use ExUnit.Case

  test "should evaluate a simple expression" do
    assert {:ok, 3} == EvalEx.eval("1 + 2", %{})
  end
end
