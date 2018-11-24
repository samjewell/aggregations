require "byebug"

class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: "Person", foreign_key: :manager_id
  has_many :employees, class_name: "Person", foreign_key: :manager_id

  def self.maximum_salary_by_location
    group(:location_id).maximum(:salary)
  end

  def self.maximum_salary_by_location_name
    joins(:location).group("locations.name").maximum(:salary)
  end

  def self.average_salary_by_manager_name
    joins(:manager).group("managers_people.name").average(:salary)
  end

  def self.with_lower_than_average_salary_for_their_manager
    joins(
      "INNER JOIN (" +
        Person.
          select("manager_id, AVG(salary) as average").
          group("manager_id").
          to_sql +
      ") salaries " \
      "ON salaries.manager_id = people.manager_id"
    ).
    where("people.salary < salaries.average")
  end

  def self.average_salary_of_managers_direct_reports
    joins(:employees).group(:name).average("employees_people.salary")
  end

  def self.managers_by_average_salary_difference
    #orders managers by the difference between their salary and the average salary of their employees
    # joins(
    #   "INNER JOIN (" +
    #     Person.
    #       select("people.id as manager_id, AVG(employees_people.salary) as average").
    #       joins(:employees).
    #       group(:id).
    #       to_sql +
    #   ") team_average_salaries " \
    #   "ON team_average_salaries.manager_id = people.id"
    # ).
    # order(Arel.sql("salary - team_average_salaries.average DESC"))

    joins(
      "INNER JOIN (" +
        Person.
          select("people.id as manager_id, people.salary - AVG(employees_people.salary) as difference").
          joins(:employees).
          group(:id).
          to_sql +
      ") salaries " \
      "ON salaries.manager_id = people.id"
    ).
    order("salaries.difference DESC")
  end

  def to_s
    "name: #{name}, salary: #{salary}, location_id: #{location_id}"
  end
end
