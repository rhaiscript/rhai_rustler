defmodule Rhai.EngineTest do
  use ExUnit.Case

  alias Rhai.{AST, Engine, Scope}

  describe "new/0" do
    test "should create a new engine" do
      assert %Engine{} = Engine.new()
    end
  end

  describe "new_raw/0" do
    test "should create a new raw engine" do
      assert %Engine{} = Engine.new_raw()
    end
  end

  describe "module resolvers" do
    test "should load a rhai module via the import directive" do
      assert {:ok, 42} =
               Engine.new_raw()
               |> Engine.set_module_resolvers([:file])
               |> Engine.eval("""
               import "#{File.cwd!()}/test/fixtures/script" as m;

               m::test(41)
               """)
    end

    test "should load a dylib module via the import directive" do
      assert {:ok, [6, "inner", "value"]} =
               Engine.new_raw()
               |> Engine.set_module_resolvers([:dylib])
               |> Engine.eval("""
               import "#{File.cwd!()}/priv/native/libtest_dylib_module" as plugin;

               let result = [];

               result += plugin::triple_add(1, 2, 3);
               result += plugin::new_plugin_object("inner").get_inner();
               result += plugin::get_property(\#{ property: "value" });

               result
               """)
    end
  end

  describe "register_global_module/2" do
    test "should register a module into the global namespace" do
      engine = Engine.new()

      assert {:ok, engine} =
               Engine.register_global_module(
                 engine,
                 "#{File.cwd!()}/priv/native/libtest_dylib_module"
               )

      assert {:ok, [6, "inner", "value"]} =
               Engine.eval(engine, """
               let result = [];

               result += triple_add(1, 2, 3);
               result += new_plugin_object("inner").get_inner();
               result += get_property(\#{ property: "value" });

               result
               """)
    end

    test "should return error if the module is not found" do
      assert {:error, {:runtime, _}} =
               Engine.new()
               |> Engine.register_global_module("non_existing_module")
    end
  end

  describe "register_global_module!/2" do
    test "should register a module into the global namespace" do
      assert {:ok, 6} =
               Engine.new()
               |> Engine.register_global_module!(
                 File.cwd!() <> "/priv/native/libtest_dylib_module"
               )
               |> Engine.eval("triple_add(1, 2, 3);")
    end

    test "should raise if the module is not found" do
      assert_raise RuntimeError, fn ->
        engine = Engine.new()

        Engine.register_global_module!(engine, "non_existing_module")
      end
    end
  end

  describe "register_static_module/3" do
    test "should register a static moudle namespace" do
      engine = Engine.new()

      assert {:ok, engine} =
               Engine.register_static_module(
                 engine,
                 "plugin",
                 "#{File.cwd!()}/priv/native/libtest_dylib_module"
               )

      assert {:ok, [6, "inner", "value"]} =
               Engine.eval(engine, """
               let result = [];

               result += triple_add(1, 2, 3);
               result += new_plugin_object("inner").get_inner();
               result += plugin::get_property(\#{ property: "value" });

               result
               """)
    end

    test "should return error if the module is not found" do
      engine = Engine.new()

      assert {:error, {:runtime, _}} =
               Engine.register_static_module(engine, "plugin", "non_existing_module")
    end
  end

  describe "register_static_module!/3" do
    test "should register a static moudle namespace" do
      assert {:ok, "value"} =
               Engine.new()
               |> Engine.register_static_module!(
                 "plugin",
                 "#{File.cwd!()}/priv/native/libtest_dylib_module"
               )
               |> Engine.eval("plugin::get_property(\#{ property: \"value\" });")
    end

    test "should raise if the module is not found" do
      assert_raise RuntimeError, fn ->
        engine = Engine.new()

        Engine.register_static_module!(engine, "plugin", "non_existing_module")
      end
    end
  end

  describe "register_custom_operator/3" do
    test "should register a custom operator" do
      assert {:ok, engine} =
               Engine.new()
               |> Engine.register_static_module!(
                 "plugin",
                 "#{File.cwd!()}/priv/native/libtest_dylib_module"
               )
               |> Engine.register_custom_operator("#", 160)

      assert {:ok, 3} = Engine.eval(engine, "1 # 2")
    end

    test "should return error if the operator is reserved" do
      engine = Engine.new()

      assert {:error, {:custom_operator, "'+' is a reserved operator"}} =
               Engine.register_custom_operator(engine, "+", 160)
    end
  end

  describe "register_custom_operator!/3" do
    test "should register a custom operator" do
      assert {:ok, 3} =
               Engine.new()
               |> Engine.register_static_module!(
                 "plugin",
                 "#{File.cwd!()}/priv/native/libtest_dylib_module"
               )
               |> Engine.register_custom_operator!("#", 160)
               |> Engine.eval("1 # 2")
    end

    test "should raise if the operator is reserved" do
      engine = Engine.new()

      assert_raise RuntimeError, fn ->
        Engine.register_custom_operator!(engine, "+", 160)
      end
    end
  end

  describe "register_package/2" do
    test "should register the standard package" do
      engine = Engine.new_raw()

      assert {:error, {:function_not_found, _}} = Engine.eval(engine, "[1, 2, 3].get(1)")

      assert {:ok, 2} =
               engine
               |> Engine.register_package(:standard)
               |> Engine.eval("[1, 2, 3].get(1)")
    end
  end

  describe "compile/2" do
    test "should compile a string into an AST" do
      engine = Engine.new()

      assert {:ok, %AST{}} = Engine.compile(engine, "1+1")
    end

    test "should not compile an invalid expression" do
      engine = Engine.new()

      assert {:error, {:parsing, _}} = Engine.compile(engine, "???")
    end
  end

  describe "compile_with_scope/3" do
    test "should compile a string into an AST with scope" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 2)

      assert {:ok, %AST{} = ast} =
               Engine.compile_with_scope(engine, scope, "fn test (x) { a + b + x}; test(3)")

      assert {:ok, 6} = Engine.eval_ast(engine, ast)
    end
  end

  describe "compile_expression/2" do
    test "should compile an expression into an AST" do
      engine = Engine.new()

      assert {:ok, %AST{} = ast} = Engine.compile_expression(engine, "1 + 1")
      assert {:ok, 2} = Engine.eval_ast(engine, ast)
    end
  end

  describe "compile_expression_with_scope/3" do
    test "should compile an expression into an AST with scope" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 2)

      assert {:ok, %AST{} = ast} = Engine.compile_expression_with_scope(engine, scope, "a + b")

      assert {:ok, 3} = Engine.eval_ast(engine, ast)
    end
  end

  describe "compile_file/2" do
    test "should compile a script file into an AST" do
      engine = Engine.new()

      assert {:ok, %AST{} = ast} =
               Engine.compile_file(engine, File.cwd!() <> "/test/fixtures/script.rhai")

      assert {:ok, 43} = Engine.eval_ast(engine, ast)
    end
  end

  describe "compile_file_with_scope/3" do
    test "should compile an expression into an AST with scope" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 2)

      assert {:ok, %AST{} = ast} =
               Engine.compile_file_with_scope(
                 engine,
                 scope,
                 File.cwd!() <> "/test/fixtures/script_with_scope.rhai"
               )

      assert {:ok, 45} = Engine.eval_ast(engine, ast)
    end
  end

  describe "compile_into_self_contained/3" do
    test "should compile a script into an AST with scope embedding all imported modules" do
      engine = Engine.new_raw()

      scope =
        Scope.new()
        |> Scope.push_constant("a", 1)
        |> Scope.push_constant("b", 2)
        |> Scope.push_constant("c", 3)

      assert {:ok, %AST{} = ast} =
               engine
               |> Engine.set_module_resolvers([:dylib])
               |> Engine.compile_into_self_contained(scope, """
               import "#{File.cwd!()}/priv/native/libtest_dylib_module" as plugin;

               let result = [];

               result += plugin::triple_add(a, b, c);
               result += plugin::new_plugin_object("inner").get_inner();
               result += plugin::get_property(\#{ property: "value" });

               result
               """)

      assert {:ok, [6, "inner", "value"]} = Engine.eval_ast(engine, ast)
    end
  end

  describe "compact_script/2" do
    test "should compact a script" do
      engine = Engine.new()

      assert {:ok, "fn test(){a+b}"} =
               Engine.compact_script(engine, """


               fn test() { a + b }


               """)
    end
  end

  describe "eval/1" do
    test "should eval a script" do
      engine = Engine.new()

      assert {:ok, 2} = Engine.eval(engine, "1 + 1")
    end
  end

  describe "eval_with_scope/3" do
    test "should eval a script with scope" do
      engine = Engine.new()
      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push("b", 1)

      assert {:ok, 2} = Engine.eval_with_scope(engine, scope, "a + b")
    end
  end

  describe "eval_ast/2" do
    test "should eval an AST" do
      engine = Engine.new()
      {:ok, ast} = Engine.compile(engine, "40 + 2")

      assert {:ok, 42} = Engine.eval_ast(engine, ast)
    end
  end

  describe "eval_ast_with_scope/3" do
    test "should eval an AST with scope" do
      engine = Engine.new()
      {:ok, ast} = Engine.compile(engine, "a + b")
      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push("b", 1)

      assert {:ok, 2} = Engine.eval_ast_with_scope(engine, scope, ast)
    end
  end

  describe "eval_expression/2" do
    test "should eval an expression" do
      engine = Engine.new()

      assert {:ok, 2} = Engine.eval_expression(engine, "1 + 1")
    end
  end

  describe "eval_expression_with_scope/3" do
    test "should eval an expression with scope" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 1)

      assert {:ok, 2} = Engine.eval_expression_with_scope(engine, scope, "a + b")
    end
  end

  describe "eval_file/2" do
    test "should eval a script file" do
      engine = Engine.new()

      assert {:ok, 43} = Engine.eval_file(engine, File.cwd!() <> "/test/fixtures/script.rhai")
    end
  end

  describe "eval_file_with_scope/3" do
    test "should eval a script file with scope" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 2)

      assert {:ok, 45} =
               Engine.eval_file_with_scope(
                 engine,
                 scope,
                 File.cwd!() <> "/test/fixtures/script_with_scope.rhai"
               )
    end
  end

  describe "run/2" do
    test "should run a script" do
      engine = Engine.new()

      assert :ok = Engine.run(engine, "40 + 2;")
    end
  end

  describe "run_with_scope/3" do
    test "should run a script with scope" do
      engine = Engine.new()
      scope = Scope.new() |> Scope.push("x", 40)

      assert :ok = Engine.run_with_scope(engine, scope, "x += 2;")
      assert 42 == Scope.get_value(scope, "x")
    end
  end

  describe "run_ast/2" do
    test "should run an AST" do
      engine = Engine.new()
      {:ok, ast} = Engine.compile(engine, "40 + 2;")

      assert :ok = Engine.run_ast(engine, ast)
    end
  end

  describe "run_ast_with_scope/3" do
    test "should run an AST with scope" do
      engine = Engine.new()
      scope = Scope.new() |> Scope.push("x", 40)

      {:ok, ast} = Engine.compile(engine, "x += 2;")

      assert :ok = Engine.run_ast_with_scope(engine, scope, ast)
      assert 42 == Scope.get_value(scope, "x")
    end
  end

  describe "run_file/2" do
    test "should run a script file" do
      engine = Engine.new()

      assert :ok = Engine.run_file(engine, File.cwd!() <> "/test/fixtures/script.rhai")
    end
  end

  describe "run_file_with_scope/3" do
    test "should run a script file with scope" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 2)

      assert :ok =
               Engine.run_file_with_scope(
                 engine,
                 scope,
                 File.cwd!() <> "/test/fixtures/script_with_scope.rhai"
               )

      assert 45 == Scope.get_value(scope, "x")
    end
  end

  describe "call_fn/5" do
    test "should call a script function" do
      engine = Engine.new()
      {:ok, ast} = Engine.compile(engine, "fn test(x, y) { a + b + x + y }")
      scope = Scope.new() |> Scope.push("a", 1) |> Scope.push("b", 2)

      assert {:ok, 10} = Engine.call_fn(engine, scope, ast, "test", [3, 4])
    end
  end

  describe "set_fail_on_invalid_map_property/2, fail_on_invalid_map_property?/1" do
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

  describe "set_max_array_size/2, max_array_size/1" do
    test "should return an unlimited size by default" do
      engine = Engine.new()

      assert 0 == Engine.max_array_size(engine)
    end

    test "should set a max array size" do
      assert 256 = Engine.new() |> Engine.set_max_array_size(256) |> Engine.max_array_size()
    end
  end

  describe "set_allow_anonymous_fn/2, allow_anonymous_fn?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_anonymous_fn?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new() |> Engine.set_allow_anonymous_fn(false) |> Engine.allow_anonymous_fn?()
    end
  end

  describe "set_allow_if_expression/2, allow_if_expression?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_if_expression?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new()
             |> Engine.set_allow_if_expression(false)
             |> Engine.allow_if_expression?()
    end
  end

  describe "set_allow_loop_expressions/2, allow_loop_expressions/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_loop_expressions?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new()
             |> Engine.set_allow_loop_expressions(false)
             |> Engine.allow_loop_expressions?()
    end
  end

  describe "set_allow_looping/2, allow_looping?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_looping?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new() |> Engine.set_allow_looping(false) |> Engine.allow_looping?()
    end
  end

  describe "set_allow_shadowing/2, allow_shadowing?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_shadowing?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new() |> Engine.set_allow_shadowing(false) |> Engine.allow_shadowing?()
    end
  end

  describe "set_allow_statement_expression/2, allow_statement_expression?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_statement_expression?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new()
             |> Engine.set_allow_statement_expression(false)
             |> Engine.allow_statement_expression?()
    end
  end

  describe "set_allow_switch_expression/2, allow_switch_expression?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.allow_switch_expression?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new()
             |> Engine.set_allow_switch_expression(false)
             |> Engine.allow_switch_expression?()
    end
  end

  describe "set_fast_operators/2, fast_operators?/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert Engine.fast_operators?(engine)
    end

    test "should set the flag to false" do
      refute Engine.new()
             |> Engine.set_fast_operators(false)
             |> Engine.fast_operators?()
    end
  end

  describe "set_allow_max_call_levels/2, allow_max_call_levels/1" do
    test "should return true by default" do
      engine = Engine.new()

      assert 64 == Engine.max_call_levels(engine)
    end

    test "should set the flag to false" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_call_levels(256)
               |> Engine.max_call_levels()
    end
  end

  describe "set_max_call_levels/2, max_call_levels/1" do
    test "should return 64 by default" do
      engine = Engine.new()

      assert 64 == Engine.max_call_levels(engine)
    end

    test "should set the size to 256" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_call_levels(256)
               |> Engine.max_call_levels()
    end
  end

  describe "set_max_expr_depths/3, max_expr_depth/1, max_function_expr_depth/1" do
    test "should return 64 by default" do
      engine = Engine.new()

      assert 64 == Engine.max_expr_depth(engine)
    end

    test "should set expr depth" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_expr_depths(256, 512)
               |> Engine.max_expr_depth()
    end

    test "should set max function expr depth" do
      assert 512 ==
               Engine.new()
               |> Engine.set_max_expr_depths(256, 512)
               |> Engine.max_function_expr_depth()
    end
  end

  describe "set_max_map_size/2, max_map_size/1" do
    test "should return 0 by default" do
      engine = Engine.new()

      assert 0 == Engine.max_map_size(engine)
    end

    test "should set the size to 256" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_map_size(256)
               |> Engine.max_map_size()
    end
  end

  describe "set_max_modules/2, max_modules/1" do
    test "should return the default" do
      engine = Engine.new()

      assert 18_446_744_073_709_551_615 == Engine.max_modules(engine)
    end

    test "should set modules number to 256" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_modules(256)
               |> Engine.max_modules()
    end
  end

  describe "set_max_operations/2, max_operations/1" do
    test "should return 0 by default" do
      engine = Engine.new()

      assert 0 == Engine.max_operations(engine)
    end

    test "should set ops limit to 256" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_operations(256)
               |> Engine.max_operations()
    end
  end

  describe "set_max_string_size/2, max_string_size/1" do
    test "should return 0 by default" do
      engine = Engine.new()

      assert 0 == Engine.max_string_size(engine)
    end

    test "should set string size limit to 256" do
      assert 256 ==
               Engine.new()
               |> Engine.set_max_string_size(256)
               |> Engine.max_string_size()
    end
  end

  describe "set_strict_variables/2, strict_variables/1" do
    test "should return false by default" do
      engine = Engine.new()

      refute Engine.strict_variables?(engine)
    end

    test "should set strict variables mode to true" do
      assert Engine.new()
             |> Engine.set_strict_variables(true)
             |> Engine.strict_variables?()
    end
  end

  describe "set_optimization_level/2, optimization_level/1" do
    test "should return :simple by default" do
      engine = Engine.new()

      assert :simple == Engine.optimization_level(engine)
    end

    test "should set the optimization level" do
      optimization_level = Enum.random([:full, :simple, :none])

      assert optimization_level ==
               Engine.new()
               |> Engine.set_optimization_level(optimization_level)
               |> Engine.optimization_level()
    end
  end

  describe "optimize_ast/4" do
    test "should optimize an AST" do
      engine = Engine.new()

      scope = Scope.new() |> Scope.push_constant("a", 1) |> Scope.push_constant("b", 2)

      {:ok, ast} = Engine.compile(engine, "a + b")

      assert %AST{} = optimized_ast = Engine.optimize_ast(engine, scope, ast, :full)
      assert {:ok, 3} = Engine.eval_ast_with_scope(engine, scope, optimized_ast)
    end
  end

  describe "disable_symbol/2" do
    test "should disable a keyword" do
      assert {:error, {:parsing, "'if' is a reserved keyword (line 1, position 9)"}} =
               Engine.new()
               |> Engine.disable_symbol("if")
               |> Engine.compile("let x = if true { 42 } else { 0 };")
    end

    test "should disable an operator" do
      assert {:error, {:parsing, "Unknown operator: '+' (line 1, position 11)"}} =
               Engine.new()
               |> Engine.disable_symbol("+")
               |> Engine.compile("let x = 1 + 2;")
    end
  end

  describe "ensure_data_size_within_limits/2" do
    test "should not return an error if the data size is within limits" do
      assert :ok =
               Engine.new()
               |> Engine.set_max_array_size(2)
               |> Engine.ensure_data_size_within_limits("[1, 2]")
    end

    test "should return error if the data size is too big" do
      assert {:error, {:data_too_large, "Length of string too large"}} =
               Engine.new()
               |> Engine.set_max_string_size(1)
               |> Engine.ensure_data_size_within_limits("[1, 2]")
    end
  end
end
