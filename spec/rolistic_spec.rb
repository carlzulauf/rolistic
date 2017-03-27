class TestRole
  include Rolistic

  add_trait :basic_user, %i(manage_account have_fun)

  add_role :n00b, %i(register), default: true
  add_role :admin, Rolistic::Everything
  add_role :member, :basic_user
  add_role :premium_member, :basic_user, %i(access_premium_services)
  add_role :api_client, %i(access_api)
  add_role :banned, []
end

class TestRoleWithoutDefault
  include Rolistic

  add_role :customer, %i(eat)
  add_role :cook,     %i(cook)
end

describe Rolistic do
  context "TestRole implementation" do
    let(:n00b) { TestRole.new }
    %i(admin member premium_member api_client banned).each do |name|
      let(name) { TestRole.new(name) }
    end

    it "acts like a n00b role" do
      expect(n00b).to be_default
      expect(n00b.can?(:register)).to be(true)
    end

    it "acts like a admin role" do
      expect(admin).not_to be_default
      expect(admin.can?(:access_api))
      expect(admin.can?(:do_anything)).to be(true)
    end

    it "acts like a member role" do
      expect(member.can?(:manage_account)).to be(true)
      expect(member.can?(:anything_else)).to be(false)
    end

    it "acts like a premium member role" do
      expect(premium_member.can?(:have_fun)).to be(true)
      expect(premium_member.can?(:access_premium_services)).to be(true)
      expect(premium_member.can?(:other_stuff)).to be(false)
    end

    it "acts like a api_client role" do
      expect(api_client.can?(:access_api)).to be(true)
      expect(api_client.can?(:manage_account)).to be(false)
    end

    it "acts like a banned role" do
      expect(banned.can?(:access_api)).to be(false)
      expect(banned.can?(:manage_account)).to be(false)
      expect(banned.can?(:reticulate_splines)).to be(false)
    end
  end

  context "TestRoleWithoutDefault implementation" do
    describe "new" do
      it "does not error when given nil" do
        TestRoleWithoutDefault.new
        TestRoleWithoutDefault.new(nil)
      end

      it "treats nil role as default" do
        role = TestRoleWithoutDefault.new
        expect(role).to be_default
      end

      it "works with non-default roles still" do
        role = TestRoleWithoutDefault.new(:customer)
        expect(role).not_to be_default
        expect(role.can?(:eat)).to be(true)
        expect(role.can?(:cook)).to be(false)
        expect(role.can?(:random_thing)).to be(false)
      end
    end
  end
end
