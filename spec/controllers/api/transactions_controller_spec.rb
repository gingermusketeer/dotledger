require 'spec_helper'

describe Api::TransactionsController do
  let!(:transaction) { FactoryGirl.create :transaction, :name => 'Transaction Name' }
  let!(:account) { FactoryGirl.create :account }

  describe "GET index" do
    let!(:account_transactions) { FactoryGirl.create_list :transaction, 2, :account => account }
    let!(:other_transactions) { FactoryGirl.create_list :transaction, 2 }
    let!(:sorted_transactions) { FactoryGirl.create_list :transaction, 2 }
    let!(:transactions_for_review) { FactoryGirl.create_list :transaction, 2 }
    let!(:all_transactions) {
      [transaction, account_transactions, other_transactions, sorted_transactions, transactions_for_review].flatten
    }
    let!(:unsorted_transactions) { [transaction, account_transactions, other_transactions].flatten }

    before do
      category = FactoryGirl.create :category

      sorted_transactions.each do |t|
        t.create_sorted_transaction(
          :account => t.account,
          :category => category,
          :name => t.search,
          :review => false
        )
      end

      transactions_for_review.each do |t|
        t.create_sorted_transaction(
          :account => t.account,
          :category => category,
          :name => t.search,
          :review => true
        )
      end
    end

    context "no filters" do
      before { get :index }

      it { should respond_with :success }

      it "should return all transactions" do
        expect(assigns(:transactions)).to match_array all_transactions
      end
    end

    context "filter by account_id" do
      before do
        get :index, :account_id => account.id
      end

      it { should respond_with :success }

      it "should return all transactions for the account" do
        expect(assigns(:transactions)).to match_array account_transactions
      end
    end

    context "filter sorted" do
      before do
        get :index, :sorted => true
      end

      it { should respond_with :success }

      it "should return sorted transactions" do
        expect(assigns(:transactions)).to match_array [sorted_transactions, transactions_for_review].flatten
      end
    end

    context "filter unsorted" do
      before do
        get :index, :unsorted => true
      end

      it { should respond_with :success }

      it "should return unsorted transactions" do
        expect(assigns(:transactions)).to match_array unsorted_transactions
      end
    end

    context "filter flagged for review" do
      before do
        get :index, :review => true
      end

      it { should respond_with :success }

      it "should return transactions flagged for review" do
        expect(assigns(:transactions)).to match_array transactions_for_review
      end
    end

    context "filter not flagged for review" do
      before do
        get :index, :review => false
      end

      it { should respond_with :success }

      it "should return transactions not flagged for review" do
        expect(assigns(:transactions)).to match_array sorted_transactions
      end
    end
  end

  describe "GET show" do
    before { get :show, :id => transaction.id }

    it { should respond_with :success }

    it "should return the transaction" do
      expect(assigns(:transaction)).to eq transaction
    end
  end

  describe "POST create" do
    def valid_request
      attributes = FactoryGirl.attributes_for(:transaction)
      attributes.merge!(:account_id => account.id)
      post :create, attributes
    end

    it "should respond with 200" do
      valid_request
      expect(subject).to respond_with(:success)
    end

    it "should create a transaction" do
      expect {
        valid_request
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "PUT update" do
    def valid_request
      put :update,
        :id => transaction.id,
        :name => 'New Transaction Name'
    end

    it "should respond with 200" do
      valid_request
      expect(subject).to respond_with(:success)
    end

    it "should update the name" do
      expect {
        valid_request
      }.to change {transaction.reload.name}.from('Transaction Name').to('New Transaction Name')
    end
  end

  describe "DELETE destroy" do
    def valid_request
      delete :destroy,
        :id => transaction.id
    end

    it "should respond with 204" do
      valid_request
      expect(subject).to respond_with(:no_content)
    end

    it "should delete the transaction" do
      expect {
        valid_request
      }.to change(Transaction, :count).by(-1)
    end
  end

  describe "POST sort" do
    # FIXME: this needs more tests

    it "should respond with 200" do
      post :sort
      expect(subject).to respond_with(:success)
    end

    context "with account_id" do
      let(:account) { FactoryGirl.create :account }
      it "should respond with 200" do
        post :sort, :account_id => account.id
        expect(subject).to respond_with(:success)
      end
    end
  end
end
