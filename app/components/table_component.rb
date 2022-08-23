# frozen_string_literal: true

class TableComponent < ViewComponent::Base
  renders_many :columns, TableColumnComponent
  renders_many :table_rows, TableRowComponent
end
