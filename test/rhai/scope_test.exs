defmodule ScopeTest do
  use ExUnit.Case

  alias Rhai.Scope

  describe "new/0" do
    test "should create a new scope" do
      assert %Scope{} = Scope.new()
    end
  end

  describe "with_capacity/1" do
    test "should create a new scope with a particular capacity" do
      assert %Scope{} = Scope.with_capacity(10)
    end
  end

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

  describe "remove/2" do
    test "should remove and return the variable from the scope" do
      scope = Scope.new()

      assert 1 == scope |> Scope.push_dynamic("a", 1) |> Scope.remove("a")
      refute Scope.contains?(scope, "a")
    end

    test "should do nothing and return nil if the variable is not found" do
      scope = Scope.new()

      assert nil == Scope.remove(scope, "a")
      refute Scope.contains?(scope, "a")
    end
  end

  describe "rewind/2" do
    test "should rewind the scope to a previous size" do
      scope =
        Scope.new()
        |> Scope.push_dynamic("a", 1)
        |> Scope.push_dynamic("b", 2)
        |> Scope.push_dynamic("c", 3)
        |> Scope.rewind(2)

      assert 2 == Scope.len(scope)
      assert 1 == Scope.get_value(scope, "a")
      assert 2 == Scope.get_value(scope, "b")
      refute Scope.contains?(scope, "c")

      scope = Scope.rewind(scope, 0)

      assert Scope.is_empty(scope)
    end
  end

  describe "pop/1" do
    test "should pop remove the last entry from the Scope" do
      scope =
        Scope.new()
        |> Scope.push_dynamic("a", 1)
        |> Scope.push_dynamic("b", 2)
        |> Scope.push_dynamic("c", 3)

      assert {:ok, scope} = Scope.pop(scope)
      assert 2 == Scope.len(scope)
      refute Scope.contains?(scope, "c")
    end

    test "should return an error if the scope is empty" do
      assert {:error, {:scope_is_empty, _}} = Scope.new() |> Scope.pop()
    end
  end

  describe "pop!/1" do
    test "should pop remove the last entry from the Scope" do
      scope =
        Scope.new()
        |> Scope.push_dynamic("a", 1)
        |> Scope.push_dynamic("b", 2)
        |> Scope.push_dynamic("c", 3)

      scope = Scope.pop!(scope)

      assert 2 == Scope.len(scope)
      refute Scope.contains?(scope, "c")
    end

    test "should raise if the scope is empty" do
      assert_raise RuntimeError, fn ->
        Scope.new() |> Scope.pop!()
      end
    end
  end

  describe "set_value/1" do
    test "should update the value of the named entry in the Scope" do
      assert {:ok, scope} =
               Scope.new()
               |> Scope.push_dynamic("a", 1)
               |> Scope.set_value("a", 2)

      assert 2 == Scope.get_value(scope, "a")
    end

    test "should add a new entry if no entry matching the specified name is found" do
      assert {:ok, scope} = Scope.new() |> Scope.set_value("a", 1)

      assert 1 == Scope.get_value(scope, "a")
    end

    test "should return an error when trying to update the value of a constant" do
      assert {:error, {:cannot_update_value_of_constant, _}} =
               Scope.new()
               |> Scope.push_constant_dynamic("a", 1)
               |> Scope.set_value("a", 2)
    end
  end

  describe "set_value!/1" do
    test "should update the value of the named entry in the Scope" do
      scope =
        Scope.new()
        |> Scope.push_dynamic("a", 1)
        |> Scope.set_value!("a", 2)

      assert 2 == Scope.get_value(scope, "a")
    end

    test "should add a new entry if no entry matching the specified name is found" do
      scope = Scope.new() |> Scope.set_value!("a", 1)

      assert 1 == Scope.get_value(scope, "a")
    end

    test "should raise when trying to update the value of a constant" do
      assert_raise RuntimeError, fn ->
        Scope.new()
        |> Scope.push_constant_dynamic("a", 1)
        |> Scope.set_value!("a", 2)
      end
    end
  end

  describe "Enumerable" do
    setup do
      scope =
        Scope.new()
        |> Scope.push_dynamic("a", 1)
        |> Scope.push_dynamic("b", 2)
        |> Scope.push_dynamic("c", 3)

      {:ok, %{scope: scope}}
    end

    test "Enum.to_list/1", %{scope: scope} do
      assert [
               {"a", 1},
               {"b", 2},
               {"c", 3}
             ] = Enum.to_list(scope)
    end

    test "Enum.count/1", %{scope: scope} do
      assert 3 = Enum.count(scope)
    end

    test "left in right", %{scope: scope} do
      assert {"a", 1} in scope
    end

    test "Enum.map/2", %{scope: scope} do
      assert [
               {"a", 2},
               {"b", 4},
               {"c", 6}
             ] = Enum.map(scope, fn {k, v} -> {k, v * 2} end)
    end

    test "Enum.slice/2", %{scope: scope} do
      assert [
               {"a", 1},
               {"b", 2}
             ] = Enum.slice(scope, 0..1)
    end
  end
end
