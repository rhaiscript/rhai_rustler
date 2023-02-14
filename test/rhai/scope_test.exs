defmodule Rhai.ScopeTest do
  use ExUnit.Case

  describe "push_dynamic/3" do
    test "should push a dynamic variable" do
      scope = Rhai.Scope.new() |> Rhai.Scope.push_dynamic("a", 1)

      assert 1 = Rhai.Scope.get(scope, "a")
      assert Rhai.Scope.contains?(scope, "a")
      refute Rhai.Scope.is_constant(scope, "a")
    end
  end

  describe "push_constant_dynamic/3" do
    test "should push a dynamic variable" do
      scope = Rhai.Scope.new() |> Rhai.Scope.push_constant_dynamic("a", 1)

      assert 1 = Rhai.Scope.get(scope, "a")
      assert Rhai.Scope.contains?(scope, "a")
      assert Rhai.Scope.is_constant(scope, "a")
    end
  end

  describe "get/2" do
    test "should return the value of the variable" do
      scope = Rhai.Scope.new() |> Rhai.Scope.push_dynamic("a", 1)

      assert 1 == Rhai.Scope.get(scope, "a")
    end

    test "should return nil if the variable is not found" do
      scope = Rhai.Scope.new()

      assert nil == Rhai.Scope.get(scope, "a")
    end
  end

  describe "contains?/2" do
    test "should return true if the variable is found" do
      scope = Rhai.Scope.new() |> Rhai.Scope.push_dynamic("a", 1)

      assert Rhai.Scope.contains?(scope, "a")
    end

    test "should return false if the variable is not found" do
      scope = Rhai.Scope.new()

      refute Rhai.Scope.contains?(scope, "a")
    end
  end

  describe "is_constant/2" do
    test "should return true if the variable is a constant" do
      scope = Rhai.Scope.new() |> Rhai.Scope.push_constant_dynamic("a", 1)

      assert Rhai.Scope.is_constant(scope, "a")
    end

    test "should return nil if the variable is not found" do
      scope = Rhai.Scope.new()

      assert nil == Rhai.Scope.is_constant(scope, "a")
    end
  end
end
