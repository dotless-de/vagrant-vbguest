require 'uri'

module VagrantVbguest
  module Hosts
    class Base
      include VagrantVbguest::Helpers::VmCompatible

      attr_reader :env, :vm, :options

      def initialize(vm, options=nil)
        @vm = vm
        @env = vm.env
        @options = options
      end

      # Determinates the host's version
      #
      # @return [String] The version code of the *host*'s virtualisation
      def version
        @version ||= driver.version
      end

      def read_guest_additions_version
        driver.read_guest_additions_version
      end

      # Additions-file-detection-magig.
      #
      # Detection runs in those stages:
      # 1. Uses the +iso_path+ config option, if present and not set to +:auto+
      # 2. Look out for a local additions file
      # 3. Use the default web URI
      #
      # If the detected or configured path is not a local file and remote downloads
      # are allowed (the config option +:no_remote+ is NOT set) it will try to
      # download that file into a temp file using Vagrants Downloaders.
      # If remote downloads are prohibited (the config option +:no_remote+ IS set)
      # a +VagrantVbguest::IsoPathAutodetectionError+ will be thrown
      #
      # @return [String] A absolute path to the GuestAdditions iso file.
      #                  This might be a temp-file, e.g. when downloaded from web.
      def additions_file
        return @additions_file if @additions_file

        path = options[:iso_path]
        if !path || path.empty? || path == :auto
          path = local_path
          path = web_path if !options[:no_remote] && !path
        end
        raise VagrantVbguest::IsoPathAutodetectionError if !path || path.empty?

        path = versionize(path)

        if file_match? path
          @additions_file = path
        else
          # :TODO: This will also raise, if the iso_url points to an invalid local path
          raise VagrantVbguest::DownloadingDisabledError.new(:from => path) if options[:no_remote]
          @additions_file = download path
        end
      end

      # If needed, remove downloaded temp file
      def cleanup
        @download.cleanup if @download
      end

      protected

        # fix bug when the vagrant version is higher than 1.2, by moving method Vagrant::Vagrant::File.match? here
        def file_match?(uri)
          extracted = ::URI.extract(uri, "file")

          return true if extracted && extracted.include?(uri)

          return ::File.file?(::File.expand_path(uri))
        end

        # Default web URI, where "additions file" can be downloaded.
        #
        # @return [String] A URI template containing the versions placeholder.
        def web_path
          raise NotImplementedError
        end

        # Finds the "additions file" on the host system.
        # Returns +nil+ if none found.
        #
        # @return [String] Absolute path to the local "additions file", or +nil+ if not found.
        def local_path
          raise NotImplementedError
        end

        # replaces the veriosn placeholder with the additions
        # version string
        #
        # @param path [String] A path or URL (or any other String)
        #
        # @return [String] A copy of the passed string, with verision
        #                  placeholder replaced
        def versionize(path)
          path % {:version => version}
        end

        # Kicks off +VagrantVbguest::Download+ to download the additions file
        # into a temp file.
        #
        # To remove the created tempfile call +cleanup+
        #
        # @param path [String] The path or URI to download
        #
        # @return [String] The path to the downloaded file
        def download(path)
          @download = VagrantVbguest::Download.new(path, @env.tmp_path, :ui => @env.ui)
          @download.download!
          @download.destination
        end

    end
  end
end
