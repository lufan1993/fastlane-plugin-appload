module Fastlane
  module Actions
    class AndroidApploadAction < Action
      def self.needed_loads
        {
          launcher: {
            :ldpi => ['36x36'],
            :mdpi => ['48x48'],
            :hdpi => ['72x72'],
            :xhdpi => ['96x96'],
            :xxhdpi => ['144x144'],
            :xxxhdpi => ['192x192']
          },
          notification: {
            :ldpi => ['18x18'],
            :mdpi => ['24x24'],
            :hdpi => ['36x36'],
            :xhdpi => ['48x48'],
            :xxhdpi => ['72x72'],
            :xxxhdpi => ['96x96'],
          }
        }
      end

      def self.run(params)
        fname = params[:appload_image_file]
        custom_sizes = params[:appload_custom_sizes]

        require 'mini_magick'
        image = MiniMagick::Image.open(fname)

        Helper::ApploadHelper.check_input_image_size(image, 512)

        # Convert image to png
        image.format 'png'

        loads = Helper::ApploadHelper.get_needed_loads(params[:appload_load_types], self.needed_loads, true, custom_sizes)
        loads.each do |load|
          width = load['width']
          height = load['height']

          # Custom loads will have basepath and filename already defined
          if load.has_key?('basepath') && load.has_key?('filename')
            basepath = Pathname.new(load['basepath'])
            filename = load['filename']
          else
            basepath = Pathname.new("#{params[:appload_path]}-#{load['scale']}")
            filename = "#{params[:appload_filename]}.png"
          end
          FileUtils.mkdir_p(basepath)

          image.resize "#{width}x#{height}"
          image.write basepath + filename
        end

        UI.success("Successfully stored launcher loads at '#{params[:appload_path]}'")
      end

      def self.get_custom_sizes(image, custom_sizes)

      end

      def self.description
        "Generate required load sizes from a master application load"
      end

      def self.authors
        ["@adrum"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :appload_image_file,
                                  env_name: "APPload_IMAGE_FILE",
                               description: "Path to a square image file, at least 512x512",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appload_load_types,
                                  env_name: "APPload_load_TYPES",
                             default_value: [:launcher],
                               description: "Array of device types to generate loads for",
                                  optional: true,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :appload_path,
                                  env_name: "APPload_PATH",
                             default_value: 'app/res/mipmap',
                               description: "Path to res subfolder",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appload_filename,
                                  env_name: "APPload_FILENAME",
                             default_value: 'ic_launcher',
                               description: "The output filename of each image",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appload_custom_sizes,
                               description: "Hash of custom sizes - {'path/load.png' => '256x256'}",
                             default_value: {},
                                  optional: true,
                                      type: Hash)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
