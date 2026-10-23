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

RSpec.describe Rolistic do
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

    it "accepts ability names as strings" do
      expect(member.can?("manage_account")).to be(true)
      expect(member.can?("access_api")).to be(false)
      expect(admin.can?("anything")).to be(true)
    end

    it "compiles abilities to frozen sets" do
      expect(premium_member.abilities).to be_a(Set).and be_frozen
      expect(premium_member.abilities).to eq(Set[:manage_account, :have_fun, :access_premium_services])
      expect(TestRole.new(:unknown).abilities).to be_a(Set).and be_frozen
    end

    it "does not allow abilities to be modified through an instance" do
      expect { member.abilities << :access_api }.to raise_error(FrozenError)
      expect(TestRole.new(:member).can?(:access_api)).to be(false)
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

  context "subclass of TestRole" do
    let(:subclass) do
      Class.new(TestRole) do
        role :moderator, :member, %i(moderate)
        role :api_client, %i(access_api access_admin_api)
      end
    end

    it "inherits roles and the default role" do
      expect(subclass.new(:premium_member).can?(:access_premium_services)).to be(true)
      expect(subclass.new(:admin).can?(:anything)).to be(true)
      expect(subclass.new).to be_default
      expect(subclass.new.can?(:register)).to be(true)
    end

    it "can define roles using inherited traits and roles" do
      moderator = subclass.new(:moderator)
      expect(moderator.can?(:have_fun)).to be(true)
      expect(moderator.can?(:moderate)).to be(true)
    end

    it "can override inherited roles without affecting the parent" do
      expect(subclass.new(:api_client).can?(:access_admin_api)).to be(true)
      expect(TestRole.new(:api_client).can?(:access_admin_api)).to be(false)
    end

    it "can set its own default role without affecting the parent" do
      subclass.role :guest, %i(browse), default: true
      expect(subclass.new.name).to eq(:guest)
      expect(TestRole.new.name).to eq(:n00b)
    end

    it "lists inherited and new roles as available" do
      expect(subclass.available).to eq(TestRole.available + [:moderator])
      expect(TestRole.available).not_to include(:moderator)
    end
  end

  context "role definitions" do
    def define_roles(&block)
      Class.new do
        include Rolistic
        class_exec(&block)
      end
    end

    it "ignores unsupported arguments without discarding earlier abilities" do
      klass = define_roles do
        trait :reader, %i(read)
        role :writer, :reader, %i(write), "unsupported"
      end
      role = klass.new(:writer)
      expect(role.can?(:read)).to be(true)
      expect(role.can?(:write)).to be(true)
    end

    it "is not affected by changes to arrays after they are used to define traits" do
      abilities = %i(read)
      klass = define_roles do
        trait :reader, abilities
        role :writer, :reader, %i(write)
      end
      abilities << :delete
      expect(klass.traits_map[:reader]).to eq(Set[:read])
      expect(klass.new(:writer).can?(:delete)).to be(false)
    end

    it "does not allow referencing unknown traits or roles" do
      expect {
        define_roles do
          trait :reader, %i(read)
          role :writer, :raeder, %i(write)
        end
      }.to raise_error(Rolistic::DefinitionError, /no trait or role named :raeder/)
    end

    it "does not allow referencing roles before they are defined" do
      expect {
        define_roles do
          role :editor, :writer, %i(edit)
          role :writer, %i(write)
        end
      }.to raise_error(Rolistic::DefinitionError, /no trait or role named :writer/)
    end

    it "does not allow inheriting from an everything role" do
      expect {
        define_roles do
          role :admin, :everything
          role :super_admin, :admin
        end
      }.to raise_error(Rolistic::DefinitionError, /cannot inherit from :admin/)
    end

    it "does not allow combining everything with other abilities" do
      [[:everything, %i(read)], [%i(read), :everything]].each do |args|
        expect {
          define_roles { role :admin, *args }
        }.to raise_error(Rolistic::DefinitionError, /cannot be combined/)
      end
    end
  end

  context "TestRoleWithoutDefault implementation" do
    describe "new" do
      it "treats nil role as default" do
        expect(TestRoleWithoutDefault.new).to be_default
        expect(TestRoleWithoutDefault.new(nil)).to be_default
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
