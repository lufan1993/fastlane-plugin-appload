module Fastlane
  module Actions
    class ApploadAction < Action
      def self.needed_loads
        {
          iphone: {
            '2x' => ['640x960', '640x1136', '750x1334'],
            '3x' => ['1242x2208','1125x2436']
          },
          ipad: {
            '1x' => ['20x20', '29x29', '40x40', '76x76'],
            '2x' => ['20x20', '29x29', '40x40', '76x76', '83.5x83.5']
          },
          :ios_marketing => {
            '1x' => ['1024x1024']
          },
          :watch => {
            '2x' => [
                      ['24x24', 'notificationCenter', '38mm'],
                      ['27.5x27.5', 'notificationCenter', '42mm'],
                      ['29x29', 'companionSettings'],
                      ['40x40', 'appLauncher', '38mm'],
                      ['44x44', 'appLauncher', '40mm'],
                      ['50x50', 'appLauncher', '44mm'],
                      ['86x86', 'quickLook', '38mm'],
                      ['98x98', 'quickLook', '42mm'],
                      ['108x108', 'quickLook', '44mm']
                    ],
            '3x' => [['29x29', 'companionSettings']]
          },
          :watch_marketing => {
            '1x' => ['1024x1024']
          }
        }
      end

      def self.run(params)
        fname = params[:appload_image_file]
        basename = File.basename(fname, File.extname(fname))
        basepath = Pathname.new(File.join(params[:appload_path], params[:appload_name]))

        require 'mini_magick'
        image = MiniMagick::Image.open(fname)

        Helper::ApploadHelper.check_input_image_size(image, 1024)

        # Convert image to png
        image.format 'png'

        # remove alpha channel
        if params[:remove_alpha]
          image.alpha 'remove'
        end

        # Create the base path
        FileUtils.mkdir_p(basepath)

        images = []

        loads = Helper::ApploadHelper.get_needed_loads(params[:appload_devices], self.needed_loads, false)
        loads.each do |load|
          width = load['width']
          height = load['height']
          filename = "#{basename}-#{width.to_i}x#{height.to_i}.png"

          # downsize load
          image.resize "#{width}x#{height}"

          # Don't write change/created times into the PNG properties
          # so unchanged files don't have different hashes.
          image.define("png:exclude-chunks=date,time")

          image.write basepath + filename

          info = {
            'size' => load['size'],
            'idiom' => load['device'],
            'filename' => filename,
            'scale' => load['scale']
          }

          info['role'] = load['role'] unless load['role'].nil?
          info['subtype'] = load['subtype'] unless load['subtype'].nil?

          images << info
        end

        contents = {
          'images' => images,
          'info' => {
            'version' => 1,
            'author' => 'fastlane'
          }
        }

        require 'json'
        File.write(File.join(basepath, 'Contents.json'), JSON.pretty_generate(contents))
        UI.success("Successfully stored app load at '#{basepath}'")
      end

      def self.description
        "Generate required load sizes and loadset from a master application load"
      end

      def self.authors
        ["@NeoNacho"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :appload_image_file,
                                  env_name: "APPload_IMAGE_FILE",
                               description: "Path to a square image file, at least 1024x1024",
                                  optional: false,
                                      type: String,
                             default_value: Dir["fastlane/metadata/app_load.png"].last), # that's the default when using fastlane to manage app metadata
          FastlaneCore::ConfigItem.new(key: :appload_devices,
                                  env_name: "APPload_DEVICES",
                             default_value: [:iphone],
                               description: "Array of device idioms to generate loads for",
                                  optional: true,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :appload_path,
                                  env_name: "APPload_PATH",
                             default_value: 'Assets.xcassets',
                               description: "Path to the Asset catalogue for the generated loadset",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appload_name,
                                  env_name: "APPload_NAME",
                             default_value: 'Appload.apploadset',
                               description: "Name of the apploadset inside the asset catalogue",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :remove_alpha,
                                  env_name: "REMOVE_ALPHA",
                             default_value: false,
                               description: "Remove the alpha channel from generated PNG",
                                  optional: true,
                                      type: Boolean)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :macos, :caros, :rocketos].include?(platform)
      end
    end
  end
end
