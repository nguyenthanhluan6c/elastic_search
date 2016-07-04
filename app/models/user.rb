class User < ApplicationRecord
  include Searchable

  has_many :books
  
  def as_indexed_json(options = {})
    self.as_json({
      only: [:name, :email],
      include: {
        books: { only: :name }
      }
    })
  end
end
