require "rails_helper"

RSpec.describe CommentPolicy do
  subject { described_class.new(user, comment) }

  let(:comment) { build(:comment) }

  let(:valid_attributes_for_create) do
    %i[body_markdown commentable_id commentable_type parent_id]
  end

  let(:valid_attributes_for_update) do
    %i[body_markdown]
  end

  context "when user is not signed-in" do
    let(:user) { nil }

    it { within_block_is_expected.to raise_error(Pundit::NotAuthorizedError) }
  end

  context "when user is not the author" do
    let(:user) { build(:user) }

    it { is_expected.to permit_actions(%i[create]) }
    it { is_expected.to forbid_actions(%i[edit update destroy delete_confirm]) }

    it do
      is_expected.to permit_mass_assignment_of(valid_attributes_for_create).for_action(:create)
    end

    context "with banned status" do
      before { user.add_role :banned }

      it { is_expected.to forbid_actions(%i[create edit update destroy delete_confirm]) }
    end
  end

  context "when user is the author" do
    let(:user) { comment.user }

    it { is_expected.to permit_actions(%i[edit update new create delete_confirm destroy]) }

    it { is_expected.to permit_mass_assignment_of(valid_attributes_for_create).for_action(:create) }
    it { is_expected.to permit_mass_assignment_of(valid_attributes_for_update).for_action(:update) }

    context "with banned status" do
      before { user.add_role :banned }

      it { is_expected.to permit_actions(%i[edit update destroy delete_confirm]) }
      it { is_expected.to forbid_actions(%i[create]) }

      it do
        is_expected.to permit_mass_assignment_of(valid_attributes_for_update).for_action(:update)
      end
    end
  end
end
