defmodule Rhai.PropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Rhai.{Engine, Scope}

  describe "type conversion" do
    property "should convert integer() to rhai integer type and vice-versa" do
      engine = Engine.new()

      check all int <- integer() do
        scope = Scope.new() |> Scope.push("a", int)
        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a")
        assert int == result
        assert is_integer(result)
      end
    end

    property "should convert float() to rhai float type and vice-versa" do
      engine = Engine.new()

      check all float <- float() do
        scope = Scope.new() |> Scope.push("a", float)
        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a")
        assert float == result
        assert is_float(result)
      end
    end

    property "should convert boolean() to rhai bool type and vice-versa" do
      engine = Engine.new()

      check all bool <- boolean() do
        scope = Scope.new() |> Scope.push("a", bool)
        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a")
        assert bool == result
        assert is_boolean(result)
      end
    end

    property "should convert tuple() to rhai array type and vice-versa" do
      engine = Engine.new()

      check all tuple <- tuple({integer(), string(:ascii)}) do
        scope = Scope.new() |> Scope.push("a", tuple)
        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a")
        assert Tuple.to_list(tuple) == result
        assert is_list(result)
      end
    end

    property "should convert list() to rhai array type and vice-versa" do
      engine = Engine.new()

      check all list <- list_of(string(:ascii)) do
        scope = Scope.new() |> Scope.push("a", list)
        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a")
        assert list == result
        assert is_list(list)
      end
    end

    property "should convert String.t() to rhai string type and vice-versa" do
      engine = Engine.new()

      check all str1 <- string(:ascii),
                str2 <- string(:printable) do
        scope = Scope.new() |> Scope.push("a", str1) |> Scope.push("b", str2)
        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a + b")
        assert str1 <> str2 == result
        assert is_binary(result)
      end
    end

    property "should convert Map.t() with String.t() keys to rhai object map type and vice-versa" do
      engine = Engine.new()

      check all map1 <- map_of(string(:ascii), string(:ascii)),
                map2 <- map_of(string(:ascii), integer()),
                map3 <- map_of(string(:ascii), map_of(string(:ascii), integer())) do
        scope =
          Scope.new() |> Scope.push("a", map1) |> Scope.push("b", map2) |> Scope.push("c", map3)

        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "a")
        assert map1 == result

        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "b")
        assert map2 == result

        assert {:ok, result} = Engine.eval_with_scope(engine, scope, "c")
        assert map3 == result
      end
    end
  end
end
