require "pharos/addons/ingress_nginx"

describe Pharos::Addons::IngressNginx do

  let(:config) { { foo: 'bar'} }
  let(:cpu_arch) { double(:cpu_arch ) }
  let(:master) { double(:host, address: '1.1.1.1') }

  subject do
    described_class.new(config, enabled: true, master: master, cpu_arch: cpu_arch)
  end

  describe "#validate" do
    it "validates default_backend as optional" do
      result = described_class.validate({enabled: true})
      expect(result.success?).to be_truthy

    end

    it "wants image in default_backend to be a string" do
       result = described_class.validate({enabled: true, default_backend: {image: 12345}})
       expect(result.success?).to be_falsey
       expect(result.errors.dig(:default_backend, :image)).not_to be_nil
    end
  end


  describe "#image_name" do
    context "with a configured image" do
      let(:config) { {default_backend: {image: 'some_image'}} }

      it "returns configured name" do
        expect(cpu_arch).not_to receive(:name)
        expect(subject.image_name).to eq("some_image")
      end
    end

    context "for cpu_arch=arm64" do
      let(:cpu_arch) { double(:cpu_arch, name: 'arm64' ) }

      it "returns default for arm64" do
        expect(subject.image_name).to eq(Pharos::Addons::IngressNginx::DEFAULT_BACKEND_ARM64_IMAGE)
      end
    end

    context "for cpu_arch=amd64" do
      let(:cpu_arch) { double(:cpu_arch, name: 'amd64' ) }

      it "returns default" do
        expect(subject.image_name).to eq(Pharos::Addons::IngressNginx::DEFAULT_BACKEND_IMAGE)
      end
    end
  end
end
