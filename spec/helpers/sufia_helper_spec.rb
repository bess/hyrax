require 'spec_helper'

describe SufiaHelper do

  describe "#link_to_facet_list" do
    before do
      allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    end

    context "with values" do
      subject { helper.link_to_facet_list(['car', 'truck'], 'vehicle_type') }

      it "should join the values" do
        car_link = catalog_index_path(f: {'vehicle_type_sim' => ['car']})
        truck_link = catalog_index_path(f: {'vehicle_type_sim' => ['truck']})
        expect(subject).to eq "<a href=\"#{car_link}\">car</a>, <a href=\"#{truck_link}\">truck</a>"
        expect(subject).to be_html_safe
      end
    end

    context "without values" do
      subject { helper.link_to_facet_list([], 'vehicle_type') }

      it "should show the default text" do
        expect(subject).to eq "No value entered"
      end
    end
  end

  describe "has_collection_search_parameters?" do
    subject { helper }
    context "when cq is set" do
      before { allow(helper).to receive(:params).and_return({ cq: 'foo'}) }
      it { should have_collection_search_parameters }
    end

    context "when cq is not set" do
      before { allow(helper).to receive(:params).and_return({ cq: ''}) }
      it { should_not have_collection_search_parameters }
    end
  end

  describe "sufia_thumbnail_tag" do
    context "for an image object" do
      let(:document) { SolrDocument.new( mime_type_tesim: 'image/jpeg', noid_tsi: '1234') }
      it "should show the audio thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, { width: 90 })
        rendered.should match /src="\/downloads\/1234\?datastream_id=thumbnail"/
        rendered.should match /width="90"/
      end
    end
    context "for an audio object" do
      let(:document) { SolrDocument.new( mime_type_tesim: 'audio/x-wave') }
      it "should show the audio thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, {})
        rendered.should match /src="\/assets\/audio.png"/
      end
    end
    context "for an document object" do
      let(:document) { SolrDocument.new( mime_type_tesim: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
      it "should show the default thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, {})
        rendered.should match /src="\/assets\/default.png"/
      end
    end
  end

  describe "#link_to_telephone" do

    before do
      @user = mock_model(User)
      allow(@user).to receive(:telephone).and_return('867-5309')
    end
    
    context "when @user is set" do
      it "should return a link to the user's telephone" do
        expect(helper.link_to_telephone).to eq("<a href=\"wtai://wp/mc;867-5309\">867-5309</a>")
      end
    end

    context "when @user is not set" do
      it "should return a link to the user's telephone" do
        expect(helper.link_to_telephone(@user)).to eq("<a href=\"wtai://wp/mc;867-5309\">867-5309</a>")
      end
    end
  
  end

  describe "#current_search_parameters" do

    context "when the user is not in the dashboard" do
      it "should be whatever q is" do
        allow(helper).to receive(:params).and_return({ controller: "catalog", q: "foo" })
        expect(helper.current_search_parameters).to eq("foo")
      end
    end

    context "when the user is on any dashboard page" do

      it "should be ignored on dashboard" do
        allow(helper).to receive(:params).and_return({ controller: "dashboard", q: "foo" })
        expect(helper.current_search_parameters).to be_nil
      end

      it "should be ignored on dashboard files, collections, highlights and shares" do
        allow(helper).to receive(:params).and_return({ controller: "my/files", q: "foo" })
        expect(helper.current_search_parameters).to be_nil
        allow(helper).to receive(:params).and_return({ controller: "my/collections", q: "foo" })
        expect(helper.current_search_parameters).to be_nil
        allow(helper).to receive(:params).and_return({ controller: "my/highlights", q: "foo" })
        expect(helper.current_search_parameters).to be_nil
        allow(helper).to receive(:params).and_return({ controller: "my/shares", q: "foo" })
        expect(helper.current_search_parameters).to be_nil
      end

    end

  end

  describe "#search_form_action" do

    context "when the user is not in the dashboard" do
      it "should return the catalog index path" do
        allow(helper).to receive(:params).and_return({ controller: "foo" })
        expect(helper.search_form_action).to eq(catalog_index_path)
      end
    end

    context "when the user is on the dashboard page" do
      it "should default to My Files" do
        allow(helper).to receive(:params).and_return({ controller: "dashboard" })
        expect(helper.search_form_action).to eq(sufia.dashboard_files_path)
      end
    end

    context "when the user is on the my files page" do
      it "should return the my dashboard files path" do
        allow(helper).to receive(:params).and_return({ controller: "my/files" })
        expect(helper.search_form_action).to eq(sufia.dashboard_files_path)
      end
    end

    context "when the user is on the my collections page" do
      it "should return the my dashboard collections path" do
        allow(helper).to receive(:params).and_return({ controller: "my/collections" })
        expect(helper.search_form_action).to eq(sufia.dashboard_collections_path)
      end
    end

    context "when the user is on the my highlights page" do
      it "should return the my dashboard highlights path" do
        allow(helper).to receive(:params).and_return({ controller: "my/highlights" })
        expect(helper.search_form_action).to eq(sufia.dashboard_highlights_path)
      end
    end

    context "when the user is on the my shares page" do
      it "should return the my dashboard shares path" do
        allow(helper).to receive(:params).and_return({ controller: "my/shares" })
        expect(helper.search_form_action).to eq(sufia.dashboard_shares_path)
      end
    end

  end

end
