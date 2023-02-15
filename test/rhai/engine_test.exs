defmodule Rhai.EngineTest do
  use ExUnit.Case

  alias Rhai.{Engine, Scope}

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

  describe "eval_with_scope/3" do
    test "should eval a script with scope" do
      engine = Engine.new()
      scope = Scope.new() |> Scope.push_constant_dynamic("a", 1) |> Scope.push_dynamic("b", 1)

      assert {:ok, 2} = Engine.eval_with_scope(engine, scope, "a + b")
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

  # FIXME: At the moment Rhai has a wrong default for this one, disabling the test until it gets fixed upstream
  # describe "set_allow_loop_expressions/2, allow_loop_expressions/1" do
  # test "should return true by default" do
  #  engine = Engine.new()
  #
  # assert Engine.allow_loop_expressions?(engine)
  # end
  #
  # test "should set the flag to false" do
  #   engine = Engine.new()
  #
  #  refute Engine.new()
  #        |> Engine.set_allow_loop_expressions(false)
  #       |> Engine.allow_loop_expressions?()
  # end
  # end

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
end
