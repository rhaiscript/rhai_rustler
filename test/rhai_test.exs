defmodule RhaiTest do
  use ExUnit.Case
  use ExUnitProperties

  describe "eval/2" do
    test "should evaluate an expression without a context" do
      assert {:ok, 3} == Rhai.eval("1 + 2")
    end

    test "should evaluate an expression with a context" do
      assert {:ok, 3} == Rhai.eval("a + b", %{"a" => 1, "b" => 2})
    end

    test "should assing a variable" do
      assert {:ok, 7} == Rhai.eval("let c = 4; a + b + c;", %{"a" => 1, "b" => 2})
    end

    test "should return an error if a variable does not exist" do
      assert {:error, {:variable_not_found, "Variable not found: b (line 1, position 5)"}} ==
               Rhai.eval("a + b", %{"a" => 1})
    end
  end

  describe "precompiled expressions" do
    test "should evaluate a precompiled expression" do
      assert {:ok, %Rhai.PrecompiledExpression{} = precompiled_expression} =
               Rhai.precompile_expression("a + b")

      assert {:ok, 3} == Rhai.eval(precompiled_expression, %{"a" => 1, "b" => 2})
    end
  end

  describe "type conversion" do
    property "should convert integer() to Integer and Integer to integer()" do
      check all int <- integer() do
        assert {:ok, result} = Rhai.eval("a", %{"a" => int})
        assert int == result
        assert is_integer(result)
      end
    end

    property "should convert float() to Float and Float to float()" do
      check all float <- float() do
        assert {:ok, result} = Rhai.eval("a", %{"a" => float})
        assert float == result
        assert is_float(result)
      end
    end

    property "should convert boolean() to Bool and Bool to boolean()" do
      check all bool <- boolean() do
        assert {:ok, result} = Rhai.eval("a", %{"a" => bool})
        assert bool == result
        assert is_boolean(result)
      end
    end

    property "should convert tuple() to Tuple and Tuple to list()" do
      check all tuple <- tuple({integer(), string(:ascii)}) do
        assert {:ok, result} = Rhai.eval("a", %{"a" => tuple})
        assert Tuple.to_list(tuple) == result
        assert is_list(result)
      end
    end

    property "should convert list() to Tuple and Tuple to list()" do
      check all list <- list_of(string(:ascii)) do
        assert {:ok, result} = Rhai.eval("a", %{"a" => list})
        assert list == result
        assert is_list(list)
      end
    end

    property "should convert String.t() to String and String to String.t()" do
      check all str1 <- string(:ascii),
                str2 <- string(:printable) do
        assert {:ok, result} = Rhai.eval("a + b", %{"a" => str1, "b" => str2})
        assert str1 <> str2 == result
        assert is_binary(result)
      end
    end
  end
end
