defmodule Rhai.PropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Rhai.Engine

  describe "type conversion" do
    property "should convert integer() to rhai integer type and vice-versa" do
      engine = Engine.new()

      check all int <- integer() do
        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => int})
        assert int == result
        assert is_integer(result)
      end
    end

    property "should convert float() to rhai float type and vice-versa" do
      engine = Engine.new()

      check all float <- float() do
        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => float})
        assert float == result
        assert is_float(result)
      end
    end

    property "should convert boolean() to rhai bool type and vice-versa" do
      engine = Engine.new()

      check all bool <- boolean() do
        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => bool})
        assert bool == result
        assert is_boolean(result)
      end
    end

    property "should convert tuple() to rhai array type and vice-versa" do
      engine = Engine.new()

      check all tuple <- tuple({integer(), string(:ascii)}) do
        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => tuple})
        assert Tuple.to_list(tuple) == result
        assert is_list(result)
      end
    end

    property "should convert list() to rhai array type and vice-versa" do
      engine = Engine.new()

      check all list <- list_of(string(:ascii)) do
        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => list})
        assert list == result
        assert is_list(list)
      end
    end

    property "should convert String.t() to rhai string type and vice-versa" do
      engine = Engine.new()

      check all str1 <- string(:ascii),
                str2 <- string(:printable) do
        assert {:ok, result} = Engine.eval(engine, "a + b", %{"a" => str1, "b" => str2})
        assert str1 <> str2 == result
        assert is_binary(result)
      end
    end

    property "should convert Map.t() with String.t() keys to rhai object map type and vice-versa" do
      engine = Engine.new()

      check all map1 <- map_of(string(:ascii), string(:ascii)),
                map2 <- map_of(string(:ascii), integer()),
                map3 <- map_of(string(:ascii), map_of(string(:ascii), integer())) do
        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => map1})
        assert map1 == result

        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => map2})
        assert map2 == result

        assert {:ok, result} = Engine.eval(engine, "a", %{"a" => map3})
        assert map3 == result
      end
    end
  end
end
