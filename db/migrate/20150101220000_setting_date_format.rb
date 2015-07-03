class SettingDateFormat < ActiveRecord::Migration
  if Rails.env.production?
    execute "ALTER DATABASE \"Phoenix_prodctn\" SET datestyle=\"SQL,DMY\";"
  else
    execute "ALTER DATABASE \"Phoenix_dev\" SET datestyle=\"SQL,DMY\";"
  end
end
