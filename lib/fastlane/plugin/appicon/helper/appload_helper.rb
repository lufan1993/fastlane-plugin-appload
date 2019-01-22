module Fastlane
  module Helper
    class ApploadHelper
      def self.check_input_image_size(image, size)
        UI.user_error!("Minimum width of input image should be #{size}") if image.width < size
        UI.user_error!("Minimum height of input image should be #{size}") if image.height < size
        UI.user_error!("Input image should be square") if image.width != image.height
      end

      def self.get_needed_loads(devices, needed_loads, is_android = false, custom_sizes = {})
        loads = []
        devices.each do |device|
          needed_loads[device].each do |scale, sizes|
            sizes.each do |size|
              if size.kind_of?(Array)
                size, role, subtype = size
              end

              if is_android
                width, height = size.split('x').map { |v| v.to_f }
              else
                width, height = size.split('x').map { |v| v.to_f * scale.to_i }
              end

              loads << {
                'width' => width,
                'height' => height,
                'size' => size,
                'device' => device.to_s.gsub('_', '-'),
                'scale' => scale,
                'role' => role,
                'subtype' => subtype
              }
              
            end
          end
        end
        
        # Add custom load sizes (probably for notifications)
        custom_sizes.each do |path, size|
          path = path.to_s
          width, height = size.split('x').map { |v| v.to_f }

          loads << {
            'width' => width,
            'height' => height,
            'size' => size,
            'basepath' => File.dirname(path),
            'filename' => File.basename(path)
          }
        end
        
        # Sort from the largest to the smallest needed load
        loads = loads.sort_by {|value| value['width']} .reverse
      end
    end
  end
end
