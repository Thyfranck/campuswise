# encoding: utf-8

class SchoolImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :scale => [1700, 600]

  def scale(width, height)
    left = 0
    top = 0
    manipulate! do |image|
      image.change_geometry!("#{width}x#{height}") { |cols, rows, img|
        if img.columns.to_i == width and img.rows.to_i == height
          return true
        else
          ration = width.to_f / height.to_f
          image_ratio = img.columns.to_f / img.rows.to_f
          if image_ratio < ration
            img.resize_to_fit!(width, 10000)
          elsif image_ratio > ration
            img.resize_to_fit!(10000, height)
          else
            img.resize_to_fit!(width, height)
          end

          left = ((img.columns.to_i - width)/2).to_i if img.columns.to_i > width
          top = ((img.rows.to_i - height)/2).to_i if img.rows.to_i > height
          img.crop!(left, top, width, height)
        end
      }
    end
  end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fit => [50, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def geometry
    @geometry ||= get_geometry
  end

  def get_geometry
    if @file
      img = ::Magick::Image::read(@file.file).first
      geometry = { :width => img.columns, :height => img.rows }
    end
  end
end
