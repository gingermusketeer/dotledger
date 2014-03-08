require 'spec_helper'

describe Tag do
  before do
    FactoryGirl.create :tag
  end

  it { should have_db_column(:name).of_type(:string).with_options(:null => false) }

  it { should validate_presence_of :name }

  it { should validate_uniqueness_of :name }

  describe "#tags_from_string" do
    let(:tags_string) { 'First Tag, Second Tag' }

    let(:tags_name_array) { ['First Tag', 'Second Tag'] }

    context "existing tags" do
      let!(:tag1) { FactoryGirl.create :tag, :name => 'First Tag' }

      let!(:tag2) { FactoryGirl.create :tag , :name => 'Second Tag'}

      specify do
        expect(Tag.tags_from_string(tags_string)).to eq [tag1, tag2]
      end
    end

    context "new tags" do
      specify do
        expect(Tag.tags_from_string(tags_string).map(&:name)).to eq tags_name_array
      end
    end
  end
end
