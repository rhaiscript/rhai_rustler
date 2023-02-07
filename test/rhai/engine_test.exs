defmodule Rhai.EngineTest do
  use ExUnit.Case

  alias Rhai.Engine

  describe "engine_new/0" do
    test "should create a new engine" do
      assert %Engine{} = Rhai.Engine.new()
    end
  end

  describe "engine_eval/1" do
    test "should eval a script" do
      assert {:ok, 2} = Engine.new() |> Engine.eval("1 + 1")
    end
  end

  describe "engine_set_fail_on_invalid_map_property/2" do
    test "should set fail on invalid map property" do
      assert {:error, {:property_not_found, _}} =
               Engine.new()
               |> Engine.set_fail_on_invalid_map_property(true)
               |> Engine.eval("let a = \#{b: 2}; a.c")
    end
  end
end
