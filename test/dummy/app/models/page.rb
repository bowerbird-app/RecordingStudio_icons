class Page < ApplicationRecord
  belongs_to :workspace
  belongs_to :folder, optional: true
end