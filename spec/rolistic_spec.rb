class TestRole
  include Rolistic

  trait :basic_user, %i(manage_account have_fun)

  role :n00b, %i(register), default: true
  role :admin, :everything
  role :member, :basic_user
  role :premium_member, :member, %i(access_premium_services)
  role :api_client, %i(access_api)
  role :banned, []
end

class TestRoleWithoutDefault
  include Rolistic

  role :customer, %i(eat)
  role :cook,     %i(cook)
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
      expect(admin.can?(:access_api)).to be(true)
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

    describe "load" do
      it "loads a role from a string" do
        role = TestRole.load("member")
        expect(role).to be_a(TestRole)
        expect(role.name).to eq(:member)
        expect(role.can?(:manage_account)).to be(true)
      end

      it "loads a role from a symbol" do
        expect(TestRole.load(:admin).name).to eq(:admin)
      end

      it "returns an existing role unchanged" do
        role = TestRole.new(:member)
        expect(TestRole.load(role)).to be(role)
      end

      it "loads the default role from nil" do
        expect(TestRole.load(nil)).to be_default
      end

      it "loads the default role from blank strings" do
        expect(TestRole.load("")).to be_default
        expect(TestRole.load("  \t\n")).to be_default
        expect(TestRole.load(:"")).to be_default
      end
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

    describe "load" do
      it "loads a nil role from nil or blank strings" do
        [nil, "", " "].each do |raw|
          role = TestRoleWithoutDefault.load(raw)
          expect(role).to be_default
          expect(role.name).to be_nil
          expect(role.can?(:eat)).to be(false)
        end
      end
    end
  end
end
