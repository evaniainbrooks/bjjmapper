require 'pathname'

Rake::Task["assets:precompile"].enhance do
  Rake::Task["rollfindr:unfingerprint"].invoke
end

namespace :rollfindr do
  logger = Logger.new($stderr)

  # Based on suggestion at https://github.com/rails/sprockets-rails/issues/49#issuecomment-20535134
  # but limited to files in umlaut's namespaced asset directories.
  task :unfingerprint => :"assets:environment"  do
    manifest_path = Dir.glob(File.join(Rails.root, 'public/assets/manifest-*.json')).first
    manifest_data = JSON.load(File.new(manifest_path))
    manifest_data["assets"].each do |logical_path, digested_path|
      logical_pathname = Pathname.new logical_path

      if RollFindr::Application.config.unfingerprint_assets.any? {|testpath| logical_pathname.fnmatch?(testpath, File::FNM_PATHNAME) }
        full_digested_path    = File.join(Rails.root, 'public/assets', digested_path)
        full_nondigested_path = File.join(Rails.root, 'public/assets', logical_path)

        logger.info "Copying to #{full_nondigested_path}"

        FileUtils.copy_file full_digested_path, full_nondigested_path, true
      end
    end

  end
end
