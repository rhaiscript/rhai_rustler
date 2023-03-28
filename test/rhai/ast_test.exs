defmodule Rhai.ASTTest do
  use ExUnit.Case

  alias Rhai.{AST, Engine}

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

  describe "merge/2" do
    test "should merge two ASTs" do
      engine = Engine.new()

      {:ok, ast1} =
        Engine.compile(engine, """
        fn foo(x) { 42 + x }
        foo(1)
        """)

      {:ok, ast2} =
        Engine.compile(engine, """
        fn foo(n) { `hello${n}` }
        foo("!")
        """)

      ast3 = AST.merge(ast1, ast2)

      assert {:ok, "hello!"} ==
               Engine.eval_ast(engine, ast3)
    end
  end

  describe "combine/2" do
    test "should combine two ASTs" do
      engine = Engine.new()

      {:ok, ast1} =
        Engine.compile(engine, """
        fn foo(x) { 42 + x }
        foo(1)
        """)

      {:ok, ast2} =
        Engine.compile(engine, """
        fn foo(n) { `hello${n}` }
        foo("!")
        """)

      ast3 = AST.combine(ast1, ast2)

      assert {:ok, "hello!"} ==
               Engine.eval_ast(engine, ast3)
    end
  end

  describe "clear_functions/1" do
    test "should clear all functions" do
      engine = Engine.new()

      {:ok, ast} =
        Engine.compile(engine, """
        fn foo(x) { 42 + x }
        foo(1)
        """)

      assert {:ok, 43} ==
               Engine.eval_ast(engine, ast)

      ast = AST.clear_functions(ast)

      assert {:error, {:function_not_found, _}} = Engine.eval_ast(engine, ast)
    end
  end
end
