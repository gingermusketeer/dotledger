class Account < ActiveRecord::Base
  self.inheritance_column = nil

  has_many :transactions

  has_many :statements

  has_many :sorted_transactions

  ACCOUNT_TYPES = ['Cheque', 'Savings', 'Credit Card', 'Other']

  validates :name, :presence => true

  validates :number, :presence => true, :uniqueness => true

  validates :type, :presence => true, :inclusion => {:in => ACCOUNT_TYPES}
end
