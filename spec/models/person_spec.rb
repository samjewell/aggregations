require "spec_helper"
require "byebug"

describe Person do
  describe ".maximum_salary_by_location" do
    it "finds the highest salary at each location" do
      [50_000, 60_000].each do |highest_salary|
        location = create(:location, name: "highest-#{highest_salary}")
        create(:person, location: location, salary: highest_salary - 1)
        create(:person, location: location, salary: highest_salary)
      end

      result = Person.maximum_salary_by_location

      expect(find_names(result)).to eq(
        "highest-50000" => 50_000,
        "highest-60000" => 60_000
      )
    end
  end

  def find_names(hash_by_id)
    hash_by_id.inject({}) do |hash_by_name, (id, value)|
      name = Location.find(id).name
      hash_by_name.merge(name => value)
    end
  end

  describe ".maximum_salary_by_location_name" do
    it "finds the highest salary at each location, returning a hash with location.name keys" do
      [50_000, 60_000].each do |highest_salary|
        location = create(:location, name: "highest-#{highest_salary}")
        create(:person, location: location, salary: highest_salary - 1)
        create(:person, location: location, salary: highest_salary)
      end

      result = Person.maximum_salary_by_location_name

      expect(result).to eq(
        "highest-50000" => 50_000,
        "highest-60000" => 60_000
      )
    end
  end

  describe ".average_salary_by_manager_name" do
    it "finds the average salary for each manager, returning a hash with manager.name keys" do
      [50_000, 60_000].each do |mean_salary|
        manager = create(:person, name: "mean-approx-#{mean_salary}")
        create(:person, manager: manager, salary: mean_salary - 5)
        create(:person, manager: manager, salary: mean_salary - 1)
        create(:person, manager: manager, salary: mean_salary)
      end

      result = Person.average_salary_by_manager_name

      expect(result).to eq(
        "mean-approx-50000" => 49_998,
        "mean-approx-60000" => 59_998
      )
    end
  end

  describe ".with_lower_than_average_salary_for_their_manager" do
    it "finds employees who have a salary lower than the average for their manager's direct reports" do
      [50_000, 60_000].each do |mean_salary|
        manager = create(:person, name: "mean-approx-#{mean_salary}")
        create(:person, manager: manager, salary: mean_salary - 5, name: "below-average-for-manager-with-mean-salary-#{mean_salary}")
        create(:person, manager: manager, salary: mean_salary - 1)
        create(:person, manager: manager, salary: mean_salary)
      end

      result = Person.with_lower_than_average_salary_for_their_manager

      expect(result.map(&:name)).to eq(%w(
        below-average-for-manager-with-mean-salary-50000
        below-average-for-manager-with-mean-salary-60000
      ))
    end
  end

  describe ".average_salary_of_managers_direct_reports" do
    it "finds the average salary for each manager, returning a hash with manager.name keys" do
      [50_000, 60_000].each do |mean_salary|
        manager = create(:person, name: "mean-approx-#{mean_salary}")
        create(:person, manager: manager, salary: mean_salary - 2)
        create(:person, manager: manager, salary: mean_salary)
      end

      result = Person.average_salary_of_managers_direct_reports

      expect(result).to eq(
        "mean-approx-50000" => 49_999,
        "mean-approx-60000" => 59_999
      )
    end
  end

  describe ".managers_by_average_salary_difference" do
    it "orders managers by the difference between their salary and the average salary of their employees" do
      highest_difference = [45_000, 20_000]
      medium_difference = [50_000, 10_000]
      lowest_difference = [50_000, -5_000]
      ordered_differences = [highest_difference, medium_difference, lowest_difference]

      ordered_differences.each do |(salary, difference)|
        manager = create(:person, salary: salary, name: "difference-#{difference}")
        create(:person, manager: manager, salary: salary - difference * 1)
        create(:person, manager: manager, salary: salary - difference * 2)
        create(:person, manager: manager, salary: salary - difference * 3)
      end

      result = Person.managers_by_average_salary_difference

      expect(result.map(&:name)).to eq(%w(
        difference-20000
        difference-10000
        difference--5000
      ))
    end
  end
end
