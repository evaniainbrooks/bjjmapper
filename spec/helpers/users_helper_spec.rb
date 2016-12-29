require 'spec_helper'

describe UsersHelper do
  describe '#all_instructors_select_groups' do
    def withrank(rank)
      build(:user, belt_rank: rank, name: "#{rank} user")
    end
    
    before do
      users = [
        withrank('blue'),
        withrank('blue'),
        withrank('white'),
        withrank('purple'),
        withrank('blue'),
        withrank('brown'),
        withrank('black'),
        withrank('white')
      ]

      User.stub_chain(:where, :limit, :sort_by).and_return(users)
    end

    subject { helper.all_instructors_select_groups }

    it 'returns the users grouped by belt rank' do
      subject[0][0].should eq 'Black'
      subject[0][1][0][0].should match 'black'

      subject[4][0].should eq 'White'
      subject[4][1][0][0].should match 'white'
    end
  end
end
