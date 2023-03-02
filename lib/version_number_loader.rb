# frozen_string_literal: true

class VersionNumberLoader
  def load!
    config.x.providentia_version = File.read(Rails.root.join('CURRENT_VERSION'))
  end

  def start
    if Rails.env.production?
      load!
    else
      updater = config.file_watcher.new([Rails.root.join('CURRENT_VERSION')]) { load! }
      app.reloaders << updater
      app.reloader.to_run { updater.execute_if_updated }
      updater.execute
    end
  end

  private
    def config
      app.config
    end

    def app
      Rails.application
    end
end
