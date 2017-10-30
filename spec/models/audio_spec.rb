require 'rails_helper'

RSpec.describe Audio, type: :model do

  subject {
    # Mock implementation of GenericResource#with_ds_resource so we don't try to make a call to Fedora for this test
    allow_any_instance_of(GenericResource).to receive(:with_ds_resource).and_return(nil)
    allow_any_instance_of(GenericResource).to receive(:save).and_return(nil)
    allow(File).to receive(:size).and_return(1)

    fedora_audio_generic_resource = GenericResource.new(pid: 'audio:object')
    fedora_audio_generic_resource.add_datastream(fedora_audio_generic_resource.create_datastream(
			ActiveFedora::Datastream,
      'content',
			:controlGroup => 'M',
			:mimeType => 'audio/wav',
			:dsLabel => "audio.wav",
			:versionable => false
		))
    fedora_audio_generic_resource.add_relationship(:is_constituent_of, 'info:fedora/fake:project')
    Audio.new(fedora_audio_generic_resource)
  }

  context "#media_type" do
    it "returns a downcase version of the class name" do
      expect(subject.media_type).to eq('audio')
    end
  end

  context "#create_access_copy_if_not_exist" do
    it "creates derivative for public resource in public directory and sets access datastream RELS-INT :rdf_type equal to ServiceFile" do
      expect(subject.create_access_copy_if_not_exist).to eq("/Users/Shared/derivativo_test_home/public/audio/00/cc/94/00cc94415af4fec64d40b22ef14aef3969b5d658fb2641422bb439d86a153df0/access.mp3")
      expect(
        subject.fedora_object.rels_int.relationships(
          subject.fedora_object.datastreams[MediaResource::ACCESS_DATASTREAM_NAME], :rdf_type
        ).first.object.value
      ).to eq('http://pcdm.org/use#ServiceFile')
    end

    it "creates derivative for restricted resource in restricted directory and sets access datastream RELS-INT :rdf_type equal to ServiceFile" do
      subject.fedora_object.add_relationship(:restriction, MediaResource::ONSITE_RESTRICTION_LITERAL_VALUE)
      expect(subject.create_access_copy_if_not_exist).to eq("/Users/Shared/derivativo_test_home/restricted/audio/00/cc/94/00cc94415af4fec64d40b22ef14aef3969b5d658fb2641422bb439d86a153df0/access.mp3")
      expect(
        subject.fedora_object.rels_int.relationships(
          subject.fedora_object.datastreams[MediaResource::ACCESS_DATASTREAM_NAME], :rdf_type
        ).first.object.value
      ).to eq('http://pcdm.org/use#ServiceFile')
    end
  end

end