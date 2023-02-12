defmodule Rhai.EngineTest do
  use ExUnit.Case

  alias Rhai.Engine

  describe "new/0" do
    test "should create a new engine" do
      assert %Engine{} = Engine.new()
    end
  end

  describe "eval/1" do
    test "should eval a script" do
      engine = Engine.new()

      assert {:ok, 2} = Engine.eval(engine, "1 + 1")
    end
  end

  describe "set_fail_on_invalid_map_property/2, fail_on_invalid_map_property?/0" do
    test "should return false by default" do
      engine = Engine.new()

      refute Engine.fail_on_invalid_map_property?(engine)
    end

    test "should set fail on invalid map property to enabled" do
      assert Engine.new()
             |> Engine.set_fail_on_invalid_map_property(true)
             |> Engine.fail_on_invalid_map_property?()
    end
  end

  describe "compile/2" do
    test "should compile a valid expression into AST" do
      engine = Engine.new()

      assert {:ok, %Rhai.AST{}} = Engine.compile(engine, "1+1")
    end

    test "should not compile an invalid expression" do
      engine = Engine.new()

      assert {:error, {:parsing, _}} = Engine.compile(engine, "???")
    end
  end
end
