defmodule Rhai.ASTTest do
  use ExUnit.Case

  alias Rhai.AST

  describe "empty/0" do
    test "should create an empty AST" do
      assert %AST{} = ast = AST.empty()
      assert nil == AST.source(ast)
    end
  end

  describe "set_source/2" do
    test "should set the source" do
      assert "x + 1;" ==
               AST.empty()
               |> AST.set_source("x + 1;")
               |> AST.source()
    end
  end

  describe "clear_source/1" do
    test "should clear the source" do
      assert nil ==
               AST.empty()
               |> AST.set_source("x + 1;")
               |> AST.clear_source()
               |> AST.source()
    end
  end
end
