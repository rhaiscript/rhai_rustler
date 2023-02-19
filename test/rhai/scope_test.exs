defmodule ScopeTest do
  use ExUnit.Case

  alias Rhai.Scope

  describe "push_dynamic/3" do
    test "should push a dynamic variable" do
      scope = Scope.new() |> Scope.push_dynamic("a", 1)

      assert 1 = Scope.get_value(scope, "a")
      assert Scope.contains?(scope, "a")
      refute Scope.is_constant(scope, "a")
    end
  end

  describe "push_constant_dynamic/3" do
    test "should push a dynamic variable" do
      scope = Scope.new() |> Scope.push_constant_dynamic("a", 1)

      assert 1 = Scope.get_value(scope, "a")
      assert Scope.contains?(scope, "a")
      assert Scope.is_constant(scope, "a")
    end
  end

  describe "get_value/2" do
    test "should return the value of the variable" do
      scope = Scope.new() |> Scope.push_dynamic("a", 1)

      assert 1 == Scope.get_value(scope, "a")
    end

    test "should return nil if the variable is not found" do
      scope = Scope.new()

      assert nil == Scope.get_value(scope, "a")
    end
  end

  describe "contains?/2" do
    test "should return true if the variable is found" do
      scope = Scope.new() |> Scope.push_dynamic("a", 1)

      assert Scope.contains?(scope, "a")
    end

    test "should return false if the variable is not found" do
      scope = Scope.new()

      refute Scope.contains?(scope, "a")
    end
  end

  describe "is_constant/2" do
    test "should return true if the variable is a constant" do
      scope = Scope.new() |> Scope.push_constant_dynamic("a", 1)

      assert Scope.is_constant(scope, "a")
    end

    test "should return nil if the variable is not found" do
      scope = Scope.new()

      assert nil == Scope.is_constant(scope, "a")
    end
  end

  describe "clear/1" do
    test "should clear the scope" do
      scope = Scope.new() |> Scope.push_dynamic("a", 1) |> Scope.clear()

      refute Scope.contains?(scope, "a")
    end
  end

  describe "clone_visible/1" do
    test "should clone the scope" do
      scope =
        Scope.new()
        |> Scope.push_dynamic("a", 1)
        |> Scope.push_dynamic("a", 2)
        |> Scope.clone_visible()

      assert 2 == Scope.get_value(scope, "a")
    end
  end

  describe "is_empty/1" do
    test "should return true if the scope is empty" do
      scope = Scope.new()

      assert Scope.is_empty(scope)
    end

    test "should return false if the scope is not empty" do
      scope = Scope.new() |> Scope.push_dynamic("a", 1)

      refute Scope.is_empty(scope)
    end
  end

  describe "len/1" do
    test "should return the number of entries inside the scope" do
      scope = Scope.new()

      assert 0 == Scope.len(scope)

      scope =
        scope
        |> Scope.push_dynamic("a", 1)
        |> Scope.push_dynamic("b", 2)

      assert 2 == Scope.len(scope)
    end
  end
end
