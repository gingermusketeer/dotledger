class SortedTransaction < ActiveRecord::Base
  belongs_to :transaction

  belongs_to :category

  belongs_to :account

  validates :name, :presence => true

  validates :account, :presence => true

  validates :transaction, :presence => true

  validates :category, :presence => true

  delegate :name, :to => :category, :prefix => true
end
