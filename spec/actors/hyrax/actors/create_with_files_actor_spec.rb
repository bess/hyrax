describe Hyrax::Actors::CreateWithFilesActor do
  let(:create_actor) do
    double('create actor', create: true,
                           curation_concern: work,
                           update: true,
                           user: user)
  end
  let(:actor) do
    Hyrax::Actors::ActorStack.new(work, ::Ability.new(user), [described_class])
  end
  let(:user) { create(:user) }
  let(:uploaded_file1) { Hyrax::UploadedFile.create(user: user) }
  let(:uploaded_file2) { Hyrax::UploadedFile.create(user: user) }
  let(:work) { create(:generic_work, user: user) }
  let(:uploaded_file_ids) { [uploaded_file1.id, uploaded_file2.id] }
  let(:attributes) { { uploaded_files: uploaded_file_ids } }

  [:create, :update].each do |mode|
    context "on #{mode}" do
      before do
        allow(Hyrax::Actors::RootActor).to receive(:new).and_return(create_actor)
        allow(create_actor).to receive(mode).and_return(true)
      end
      context "when uploaded_file_ids include nil" do
        let(:uploaded_file_ids) { [nil, uploaded_file1.id, nil] }
        it "will discard those nil values when attempting to find the associated UploadedFile" do
          expect(AttachFilesToWorkJob).to receive(:perform_later)
          expect(Hyrax::UploadedFile).to receive(:find).with([uploaded_file1.id]).and_return([uploaded_file1])
          actor.public_send(mode, attributes)
        end
      end

      context "when uploaded_file_ids belong to me" do
        it "attaches files" do
          expect(AttachFilesToWorkJob).to receive(:perform_later).with(GenericWork, [uploaded_file1, uploaded_file2])
          expect(actor.public_send(mode, attributes)).to be true
        end
      end

      context "when uploaded_file_ids don't belong to me" do
        let(:uploaded_file2) { Hyrax::UploadedFile.create }
        it "doesn't attach files" do
          expect(AttachFilesToWorkJob).not_to receive(:perform_later)
          expect(actor.public_send(mode, attributes)).to be false
        end
      end
    end
  end
end
