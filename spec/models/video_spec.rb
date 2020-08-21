require 'rails_helper'

RSpec.describe Video, type: :model do

  subject {
    # Mock implementation of GenericResource#with_ds_resource so we don't try to make a call to Fedora for this test
    allow_any_instance_of(GenericResource).to receive(:with_ds_resource).and_return(nil)
    allow_any_instance_of(GenericResource).to receive(:save).and_return(nil)
    allow(File).to receive(:size).and_return(1)

    fedora_video_generic_resource = GenericResource.new(pid: 'video:object')
    fedora_video_generic_resource.add_datastream(fedora_video_generic_resource.create_datastream(
			ActiveFedora::Datastream,
      'content',
			:controlGroup => 'M',
			:mimeType => 'video/mov',
			:dsLabel => "video.mov",
			:versionable => false
		))
    Video.new(fedora_video_generic_resource)
  }

  context "#media_type" do
    it "returns a downcase version of the class name" do
      expect(subject.media_type).to eq('video')
    end
  end

  context "#create_access_copy_if_not_exist" do
    it "creates derivative in expected location and sets access datastream RELS-INT :rdf_type equal to ServiceFile" do
      expect(subject.create_access_copy_if_not_exist).to eq(DERIVATIVO[:cache_path] + "/01/51/32/015132720f46e3160860dd1fcbdb6ad9fb10921b55df686d610c42fee10d9a62/access.mp4")
      expect(
        subject.fedora_object.rels_int.relationships(
          subject.fedora_object.datastreams[MediaResource::ACCESS_DATASTREAM_NAME], :rdf_type
        ).first.object.value
      ).to eq('http://pcdm.org/use#ServiceFile')
    end
  end

end