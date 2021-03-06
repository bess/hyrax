RSpec.describe 'hyrax/base/_form_relationships.html.erb', type: :view do
  let(:ability) { double }
  let(:work) { GenericWork.new }
  let(:form) do
    Hyrax::GenericWorkForm.new(work, ability, controller)
  end
  let(:service) { instance_double Hyrax::AdminSetService }
  let(:presenter) { instance_double Hyrax::AdminSetOptionsPresenter, select_options: [] }

  before do
    allow(form).to receive(:collections_for_select).and_return([])
    allow(view).to receive(:action_name).and_return('new')
    allow(Hyrax::AdminSetService).to receive(:new).with(controller).and_return(service)
    allow(Hyrax::AdminSetOptionsPresenter).to receive(:new).with(service).and_return(presenter)
  end

  let(:form_template) do
    %(
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render "hyrax/base/form_relationships", f: f %>
      <% end %>
    )
  end

  let(:page) do
    assign(:form, form)
    render inline: form_template
    Capybara::Node::Simple.new(rendered)
  end

  context 'with assign_admin_set turned on' do
    before do
      allow(Flipflop).to receive(:assign_admin_set?).and_return(true)
    end

    it "draws the page" do
      expect(page).to have_content('Add as member of administrative set')
      expect(page).to have_selector('select#generic_work_admin_set_id')
    end
  end

  context 'with assign_admin_set disabled' do
    before do
      allow(Flipflop).to receive(:assign_admin_set?).and_return(false)
    end
    it 'draws the page, but not the admin set widget' do
      expect(page).not_to have_content('administrative set')
    end
  end
end
