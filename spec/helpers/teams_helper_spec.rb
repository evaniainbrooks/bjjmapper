require 'spec_helper'

describe TeamsHelper do
  describe '#all_teams_groups' do
    let(:parent_team) { create(:team, parent_team: nil, name: 'Parent Team') }
    let(:child_team) { build(:team, parent_team: parent_team, name: 'Child Team') }
    let(:orphan_team) { build(:team, parent_team: nil, name: 'Orphan Team') }

    before { Team.stub_chain(:all, :limit, :to_a).and_return([parent_team, child_team, orphan_team]) }

    subject { helper.all_teams_groups }
    let(:parent_key) { parent_team.to_param }

    it 'groups decorated teams by the parent_team_id' do
      subject[nil].should include(orphan_team.decorate)
      subject[nil].should_not include(child_team.decorate)
      subject[parent_key].should include(parent_team.decorate)
      subject[parent_key].should include(child_team.decorate)
    end
  end
end
