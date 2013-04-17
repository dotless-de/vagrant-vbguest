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
      @env["download.classes"] += default_downloaders
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
        if classes.length == (i + 1) || klass.match?(@env[:url])
          @env[:ui].info I18n.t("vagrant.plugins.vbguest.download.with", :class => klass.to_s)
          @downloader = klass.new(@env[:ui])
          break
        end
      end

      # This line should never be reached, but we'll keep this here
      # just in case for now.
      raise Errors::BoxDownloadUnknownType if !@downloader

      @downloader.prepare(@env[:url]) if @downloader.respond_to?(:prepare)
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
      File.open(temp_filename, Platform.tar_file_options) do |tempfile|
        yield tempfile
      end
    end

    def temp_filename
      @env[:tmp_path].join(BASENAME + Time.now.to_i.to_s)
    end

    def download_to(f)
      @downloader.download!(@env[:url], f)
    end

    # fix bug when the vagrant version is higher than 1.2
    def default_downloaders
      if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.2.0')
        [Vagrant::Utils::Downloader]
      else
        [Vagrant::Downloaders::HTTP, Vagrant::Downloaders::File]
      end
    end

  end
end
