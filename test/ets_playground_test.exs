defmodule EtsPlaygroundTest do
  use ExUnit.Case
  @dets_file "cars.dets"

  setup do
    {:ok, cars} = :dets.open_file(:cars, [file: @dets_file, type: :bag])
    :cars |> :dets.insert({"328i", "BMW", "White", 2011})
    :cars |> :dets.insert({"335i", "BMW", "Black", 2013})
    :cars |> :dets.insert({"528i", "BMW", "White", 2012})
    :ok
  end

  teardown do
    :dets.close(:cars)
    File.rm(@dets_file)
    :ok
  end

  test "getting a table's info" do
    info = :dets.info(:cars)
    IO.inspect info
    assert info[:type] == :bag
  end

  test "inserting and retrieving data" do
    [{_model, make, _color, _year}|_tail] = :dets.lookup(:cars, "328i")
    assert make == "BMW"
  end

  test "traversing the table sequentially" do
    first = :dets.first(:cars)
    second = :dets.next(:cars, first)
    third = :dets.next(:cars, second)
    assert third == "528i"
    assert :"$end_of_table" == :dets.next(:cars, third)
  end

  test "querying the table for data that matches a pattern" do
    query = {:_, :_, :_, 2012}
    cars_from_2012 = :dets.match_object(:cars, query)
    [{model, _, _, _}|_tail] = cars_from_2012
    assert model == "528i"
  end

  test "querying using match specs" do
    query = [{
               {:_, :_, :_, :"$1"},
               [{:andalso,
                   {:'>=', :"$1", 2011},
                   {:'=<', :"$1", 2012},
               }],
               [:"$_"]
            }]
    selected_cars = :dets.select(:cars, query)
    IO.inspect selected_cars
    assert Enum.count(selected_cars) == 2
  end
end
