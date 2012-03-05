module VagrantVbguest

  # This implementation is based on Action::Box::Download by vagrant
  # 
  # This adoption does not run as a action/middleware, but is called manually
  #
  # MIT License - Mitchell Hashimoto and John Bender - https://github.com/mitchellh/vagrant
  #
  #
  #
  class Download

    BASENAME = "vbguest"

    include Vagrant::Util

    attr_reader :temp_path

    def initialize(env)
      @env = env
      @env["download.classes"] ||= []
      @env["download.classes"] += [Vagrant::Downloaders::HTTP, Vagrant::Downloaders::File]
      @downloader = nil
    end

    def instantiate_downloader
      # Assign to a temporary variable since this is easier to type out,
      # since it is used so many times.
      classes = @env["download.classes"]

      # Find the class to use.
      classes.each_index do |i|
        klass = classes[i]

        # Use the class if it matches the given URI or if this
        # is the last class...
        if classes.length == (i + 1) || klass.match?(@env[:iso_url])
          @env[:ui].info I18n.t("vagrant.plugins.vbguest.download.with", :class => klass.to_s)
          @downloader = klass.new(@env[:ui])
          break
        end
      end

      # This line should never be reached, but we'll keep this here
      # just in case for now.
      raise Errors::BoxDownloadUnknownType if !@downloader

      @downloader.prepare(@env[:iso_url])
      true
    end

    def download
      if instantiate_downloader
        with_tempfile do |tempfile|
          download_to(tempfile)
          @temp_path = @env["download.temp_path"] = tempfile.path
        end
      end
    end

    def cleanup
      if temp_path && File.exist?(temp_path)
        @env[:ui].info I18n.t("vagrant.plugins.vbguest.download.cleaning")
        File.unlink(temp_path)
      end
    end

    def with_tempfile
      File.open(iso_temp_path, Platform.tar_file_options) do |tempfile|
        yield tempfile
      end
    end

    def iso_temp_path
      @env[:tmp_path].join(BASENAME + Time.now.to_i.to_s)
    end

    def download_to(f)
      @downloader.download!(@env[:iso_url], f)
    end

  end
end